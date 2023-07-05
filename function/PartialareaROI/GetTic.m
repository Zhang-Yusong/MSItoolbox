function [tic]=GetTic(currentFile)
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
rows = imzML.getWidth();
cols = imzML.getHeight();
numscan  = rows * cols;
% 初始化
tic=zeros(numscan,1);
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
            % 将所有 m/z 值为零的像素点设置为空
            if any(A(:,1))
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
            end
        end
    end
end

% output
% 关闭进度条，并输出end
waitbar(1,h,'Finished');
close(h);
disp('end')
end