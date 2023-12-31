function [mzroi,roicell,nrows,nmzerror] =nn_RunROI
noFiles=evalin('base','importMSv.load.noFiles;');
% 获得像素点个数
nrows=0;
for z=1:noFiles
    peaksIMG=evalin('base',['importMSv.summary.img_',num2str(z),'.no_pixels;']);
    nrows=nrows+peaksIMG;
    clear peaksIMG;
end
% 导入ROI参数
thresh=evalin('base','importMSv.msroi.ROI_threshold');
renum=evalin('base','importMSv.msroi.factorThresh');
mzerror=evalin('base','importMSv.msroi.ROI_error');
weighted=evalin('base','importMSv.msroi.weighted');
units=evalin('base','importMSv.msroi.ROI_units');
minPixels=evalin('base','importMSv.msroi.minPixels');
mzFilter=evalin('base','importMSv.targ.mzFilter;');% 判断是否进行mz过滤
mzTargeted=evalin('base','importMSv.targ.mzTargeted;');% 判断是否进行针对性分析

% *******************************************************
%针对性分析部分加载参数
if mzTargeted==1
    target=evalin('base','importMSv.targ.target;');
    targError=evalin('base','importMSv.targ.targError;');
    
    tmz=[];
    for t=1:length(target)
        tmz(t,:)=[target(t)-targError;target(t)+targError];
    end
end
% ****************************
%初始化输出矩阵，并预测将分析的像素点个数
disp(' ');
disp(' *********************************************************');
disp('number of spectra (elution times) to process is: ');disp(nrows)
roicell={};
mzroi=[];
errorSort=0;
filteredpeaks=0;
warning('off', 'all');
%开始对谱图进行筛选
for si=1:noFiles
    MSi.Filename=evalin('base',['importMSv.load.img_',num2str(si),'.fileName']);
    MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(si),'.pathName;']);
    % 添加Java到工作路径
    javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
    %引用imzMLConverter导入数据,并识别行列数
    imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
    cols  = imzML.getWidth();
    rows  = imzML.getHeight();
    
    % 判断单张质谱的精确度
    erj=ceil(rows/2);
    erk=ceil(cols/2);
    prenum=0;
    premzerror=[];
    for jj=erj-5:erj+5
        for kk=erk-5:erk+5
            try
                pick(:,1) = imzML.getSpectrum(kk,jj).getmzArray();
                pick(:,2) = imzML.getSpectrum(kk,jj).getIntensityArray();
            catch ME %#ok<NASGU>
                pick = [];
            end
            if ~isempty(pick)
                % 去噪
                prenum=prenum+1;
                pick = sortrows(pick,1);
                del=tabulate(pick(pick(:,2)>0,2));
                pick(ismember(pick(:,2),[0;del((del(:,2)>renum),1)]), 2)=0;
                
                if sum(pick(:,2))~=0
                    [~,a]=max(pick(:,2));
                    maxmz=pick(a,1);
                    star = find(pick(1:a,2) == 0,1, 'last')+1;  % 在指定值之后查找第一个为0的索引
                    last= a+find(pick(a:end,2) == 0, 1, 'first')-2;  % 在指定值之后查找第一个为0的索引
                    if ~isempty(star | last) % 如果索引不为空
                        premzerror(prenum)=max([maxmz-pick(star,1);pick(last,1)-maxmz])/maxmz*10^6;
                    else
                        premzerror(prenum)=0;
                    end
                else
                    premzerror(prenum)=0;
                end
                pick=[];
            end
        end
    end
    % 如果中间部分没像素点，则设置为25ppm
    if isempty(premzerror)
        nmzerror(si)=25;
    elseif sum(premzerror)==0
        nmzerror(si)=25;
    else
        premzerror= rmoutliers(premzerror);
        nmzerror(si)=mean(premzerror);
    end
    
    % 算出矩阵像素点数
    q=si+1;
    numscan(1)=0;
    numscan(q)  = numscan(si)+rows * cols;
    for j = 1:rows
        for k = 1:cols
            % 对中间值A的初始化
            A=[];
            % 扫描索引，irow为像素点的序号，按行方向读
            irow =numscan(si) + k + (j-1) * cols;
            if rem(irow,100)==0
                disp(['MS spectrum (pixel) being processed is: ',num2str(irow),'/',num2str(nrows)])
            end
            % 获取该像素的 mz 和 intensity
            try
                A(:,1) = imzML.getSpectrum(k,j).getmzArray();
                A(:,2) = imzML.getSpectrum(k,j).getIntensityArray();
            catch ME %#ok<NASGU>
                A = [];
            end
            
            if isempty(A)
                filteredpeaks=filteredpeaks+1;
            else
                % 确保 m/z 单调递增
                if ~issorted(A,'rows')
                    A = sortrows(A,1);
                end
                % 将所有 m/z 值为零的像素点设置为空
                if ~any(A(:,1))
                    A = [];
                end
                
            end
            A=double(A);
            % ROI运算
            if ~isempty(A)
                % 是否有靶向mz
                if mzTargeted==1
                    B=A;
                    A=[];
                    for tt=1:length(target)
                        C=B(find(B(:,1)>=tmz(tt,1) & B(:,1)<=tmz(tt,2)),:);
                        A=[A;C];
                    end
                else
                    % 是否规定mz范围
                    if mzFilter==1
                        lowMZ=evalin('base','importMSv.targ.lowMZ;');
                        highMZ=evalin('base','importMSv.targ.highMZ;');
                        if lowMZ>highMZ
                            if errorSort==0;warndlg('Error in the mz range. Values are changed');errorSort=1;end
                            axmz=lowMZ;lowMZ=highMZ;highMZ=axmz;
                        end
                        A=A(find(A(:,1)>=lowMZ & A(:,1)<=highMZ),:);
                    end
                end
                % 阈值筛选
                A=A(A(:,2)>thresh,:);
                % 单个质谱预处理
                % 拉基线
                try
                    zi= msbackadj(A(:,1),A(:,2),...
                        'WindowSize',200,...
                        'StepSize',200,...
                        'RegressionMethod','pchip',...
                        'EstimationMethod','quantile',...
                        'SmoothMethod','none',...
                        'QuantileValue',0.1,...
                        'PreserveHeights',0);
                    zi(zi < 0) = 0;
                    A(:,2)=zi;
                catch
                end
                
                % 统计数据中重复出现的intensity 并删除超过频次阈值的
                del=tabulate(A(A(:,2)>0,2));
                
                if ~isempty(del)
                    del(del(:,2)<renum,:)=[];
                    A(ismember(A(:,2),[0;del(:,1)]), :)=[];
                else
                    A(A(:,2)==0, :)=[];
                end
                
                if ~isempty(A)
                    asd = sortrows(A, -2);
                    ipeak = asd;
                    % 将轮廓图转变为质心图
%                     [m,~]=size(asd);
%                     ipeak=[];
%                     for i=1:m
%                         if asd(i,2)>0
%                             delta=10^-6*nmzerror(si)*asd(i,1);
%                             ieq=find(abs(asd(:,1)-asd(i,1))<=delta);
%                             ipeak=[ipeak;[asd(i,1),sum(asd(ieq,2))]];
%                             asd(ieq,:)=0;
%                         end
%                     end
                    
                    if isfinite(ipeak)
                        ipeak = sortrows(ipeak, 1);
                        % 更改
                        mzroi=[mzroi;ipeak(:,1)];
                        % 预存矩阵
                        roicell_cache={};
                        roicell_cache(:,1:2)=num2cell(ipeak);
                        roicell_cache(:,3)=num2cell(irow);
                        roicell_cache(:,4)=roicell_cache(:,1);
                        % 合并
                        roicell=[roicell;roicell_cache];
                        % 排序
                        [mzroi,isort]=sort(mzroi);
                        roicell=roicell(isort,:);
                        % 融合
                        merge=1;
                        while merge==1
                            error_mzroi=abs(diff(mzroi));
                            if strcmp(units,'daltons')
                                valor=find(error_mzroi<mzerror);
                            elseif strcmp(units,'ppm')
                                delta=10^-6*mzerror*mzroi(1:end-1,1);
                                valor=find(error_mzroi<delta);
                            end
                            
                            valor((find(abs(diff(valor))==1)+1),:)=[];
                            
                            if isempty(valor)
                                merge=0;
                            else
                                % 最费时
                                roicell(valor,1:3)= cellfun(@(x, y) [x;y], roicell(valor,1:3), roicell(valor+1,1:3), 'UniformOutput', false);
                                
                                if strcmp(weighted,'default: mean')
                                    mzroi(valor) = cellfun(@(x) sum(x)/length(x), roicell(valor,1));
                                elseif strcmp(weighted,'median')
                                    mzroi(valor) = cellfun(@(x) median(x), roicell(valor,1));
                                elseif strcmp(weighted,'weighted')
                                    mzroi(valor)=cellfun(@(x,y) sum(x.*y)/sum(y),roicell(valor,1),roicell(valor,2));
                                elseif strcmp(weighted,'max')
                                    mzroi(valor)=cellfun(@(x,y) mean(x(find(y==max(y)))),roicell(valor, 1),roicell(valor,2));
                                end
                                
                                roicell(valor,4) = num2cell(mzroi(valor));
                                
                                roicell(valor+1,:)=[];
                                mzroi(valor+1,:)=[];
                                
                                clear valor error_mzroi finmz;
                            end
                        end
                    end
                end
            end
        end
    end
end
nmzroi=length(mzroi);
if nmzroi>1
    [mzroi,isort]=sort(mzroi);
    roicell=roicell(isort,:);
    
    % last filtes ROI < tolerance
    check_error=1;
    while check_error==1
        error_mzroi=abs(diff(mzroi));
        
        if strcmp(units,'daltons')
            valor=find(error_mzroi<mzerror);
        elseif strcmp(units,'ppm')
            delta=10^-6*mzerror*mzroi(1:end-1,1);
            valor=find(error_mzroi<delta);
        end
        
        valor((find(abs(diff(valor))==1)+1),:)=[];
        
        if isempty(valor)
            check_error=0;
        else
            roicell(valor,1:3)= cellfun(@(x, y) [x,y], roicell(valor,1:3), roicell(valor+1,1:3), 'UniformOutput', false);
            
            if strcmp(weighted,'default: mean')
                mzroi(valor) = cellfun(@(x) sum(x)/length(x), roicell(valor,1));
            elseif strcmp(weighted,'median')
                mzroi(valor) = cellfun(@(x) median(x), roicell(valor,1));
            elseif strcmp(weighted,'weighted')
                mzroi(valor)=cellfun(@(x,y) sum(x.*y)/sum(y),roicell(valor,1),roicell(valor,2));
            elseif strcmp(weighted,'max')
                mzroi(valor)=cellfun(@(x,y) mean(x(find(y==max(y)))),roicell(valor, 1),roicell(valor,2));
            end
            
            roicell(valor,4) = num2cell(mzroi(valor));
            
            roicell(valor+1,:)=[];
            mzroi(valor+1,:)=[];
            clear valor error_mzroi;
        end
    end
    % *****************************
    % update nmzroi
    roicell(find(cellfun(@(x) isempty(x),roicell(:,2))==1),2)={0};
    %     maxroi =cellfun(@(x) max(x), roicell(:,2))';
    
    roicell(find(cellfun(@(x) isempty(x),roicell(:,3))==1),3)={0};
    minPix =cellfun(@(x) length(unique(x)), roicell(:,3))';
    
    iroi=find(minPix>minPixels);%maxroi>(thresh*factorThresh) &
    
    mzroi=mzroi(iroi)';
    nmzroi=length(mzroi);
    roicell=roicell(iroi,:);
    % pause
    
    if nmzroi>0
    else
        warndlg('No ROIs survived after cleaning');
    end
else
    warndlg('Number of detected ROIs is 0. Use a lower threshold');
end