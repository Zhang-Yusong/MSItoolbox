function [tic,maximImg,medianImg,mzMax,mzMin,all_class]=PreviewIntensity
currentFile=evalin('base','importMSv.load.currentFile;');
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
rows = imzML.getWidth();
cols = imzML.getHeight();
numscan  = rows * cols;
% 初始化
mzmin = zeros(numscan,1);
mzmax = mzmin;
medianI = mzmin;
maximI = mzmin;
tic=mzmin;
all_class=zeros(1,2);
% 创建进度条
h = waitbar(0,'Initializing waitbar...');

for j = 1:cols
    for k = 1:rows
        A=[];
        % 扫描索引，si为像素点的序号，按行方向读
        si = k + (j-1) * rows;
        % 每100条输出一次
        if rem(si,100)==0
            disp(['Reading imzML file, scan ' num2str(si)]);
        end
        
        %进度条相关设置
        perc = si*100/numscan;
        percc=perc/100;
        waitbar(percc,h,sprintf('%d%% along...',round(perc)));
        
        % 跳过空扫描      continue:将控制权传递给 for 或 while 循环的下一迭代
        %if isempty(imzML.getSpectrum(k,j)), continue; end
        
        % 获取该像素的mz和intensity信息
        try
            A(:,1) = imzML.getSpectrum(k,j).getmzArray();
            A(:,2) = imzML.getSpectrum(k,j).getIntensityArray();
        catch ME %#ok<NASGU>
            A= [];
        end
        
        %判断该矩阵是否为空
        if ~isempty(A)
            if any(A(:,1))
                % 将所有 intensity 值为0的m/z设置为空
                A(A(:,2)==0,:)=[];
                % 更新m/z的最大值和最小值
                mzmin(si) = min(A(:,1));
                mzmax(si) = max(A(:,1));
                % 获取该像素的强度中位数和最大值
                medianI(si) = median(A(:,2));
                maximI(si) = max(A(:,2));
                % 获取像素点总强度
                try
                    TICstr = imzML.getSpectrum(k,j).getCVParam(mzML.Spectrum.totalIonCurrentID).getValue();
                    TIC    = str2double(TICstr);
                catch ME %#ok<NASGU>
                    TIC = 0;
                end
                if isempty(TIC) || (TIC < 1)
                    tic(si) = sum(A(:,2));
                else
                    tic(si) = TIC;
                end
                %{
                % 进行统计和分类
                class=tabulate(A(:,2));
                class=class(:,1:2);
                all_class=[all_class;class];
                a = unique(all_class(:,1),'stable');
                b = arrayfun(@(x) sum(all_class(all_class(:,1) == a(x),2)),1:length(a));
                all_class = [a,b'];
                %}
            end
        end
    end
end

% output
mzmin(mzmin==0)=[];
medianI(medianI==0)=[];

mzMax = ceil (max(mzmax)); % ceil 向上取整
mzMin = floor(min(mzmin)); % floor 向下取整 
medianImg=median(medianI);
maximImg = max(maximI);
% 关闭进度条，并输出end
waitbar(1,h,'Finished');
close(h);
%{
%画频率图
all_class=all_class(2:101,:);
all_class = sortrows(all_class,2,'descend');

figure
bar(all_class(:,1),all_class(:,2),1)
xlabel('Intensity')
ylabel('Frequency')
title({'Intensity ranking of the top 100 frequencies' ;  '(Slide the mouse wheel to enlarge the chart)'; ''});
%}
%{
figure
plot(log(all_class(:,2)),all_class(:,1))
xlabel('log(Frequency)')
ylabel('Intensity')
%}
disp('end')
end