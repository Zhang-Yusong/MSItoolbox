function [MSroi,mzroi,roicell] =RunROI
noFiles=evalin('base','importMSv.load.noFiles;');
% 获得像素点个数
nrows=0;
for z=1:noFiles
    peaksIMG=evalin('base',['importMSv.summary.img_',num2str(z),'.no_pixels;']);
    nrows=nrows+peaksIMG;
    clear peaksIMG;
end
% 创建一个形状与大结构体相同的全1矩阵
pixels=ones(nrows,1);

% 导入ROI参数
% inits
thresh=evalin('base','importMSv.msroi.ROI_threshold');
factorThresh=evalin('base','importMSv.msroi.factorThresh');
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
nruns=1;

disp(' ');
disp(' *********************************************************');
disp('number of spectra (elution times) to process is: ');disp(nrows)
mzroi=[];
MSroi=[];
roicell{1,1}=[];
roicell{1,2}=[];
roicell{1,3}=[];
roicell{1,4}=[];
nmzroi=1;
errorSort=0;
filteredpeaks=0;

% looking for mzroi values
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
                disp('MS spectrum (pixel) being processed is: ');disp(irow)
            end
            
            % 跳过空扫描
            % if isempty(imzML.getSpectrum(k,j)), continue; end
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
            if length(A)>0
                
                if mzTargeted==1
                    B=A;
                    A=[];
                    for tt=1:length(target)
                        C=B(find(B(:,1)>=tmz(tt,1) & B(:,1)<=tmz(tt,2)),:);
                        A=[A;C];
                    end
                    ipeak=find(A(:,2)>thresh);
                else
                    if mzFilter==1
                        lowMZ=evalin('base','importMSv.targ.lowMZ;');
                        highMZ=evalin('base','importMSv.targ.highMZ;');
                        if lowMZ>highMZ
                            if errorSort==0;warndlg('Error in the mz range. Values are changed');errorSort=1;end
                            axmz=lowMZ;lowMZ=highMZ;highMZ=axmz;
                        end
                        
                        A=A(find(A(:,1)>=lowMZ & A(:,1)<=highMZ),:);
                        ipeak=find(A(:,2)>thresh);
                    else
                        ipeak=find(A(:,2)>thresh);
                    end
                    
                end
                
                if isfinite(ipeak)
                    mz=A(ipeak,1);
                    MS=A(ipeak,2);
                    if irow==1,mzroi=mz(1);end
                    
                    nmz=size(mz);
                    
                    for i=1:nmz
                        
                        if strcmp(units,'daltons')
                            ieq=find(abs(mzroi-mz(i))<=mzerror);
                        elseif strcmp(units,'ppm')
                            delta=10^-6*mzerror*mz(i);
                            ieq=find(abs(mzroi-mz(i))<=delta);
                        end
                        
                        if isfinite(ieq)
                            
                            for h=1:length(ieq)
                                kieq=ieq(h);
                                roicell{kieq,1}=[roicell{kieq,1},mz(i)];
                                roicell{kieq,2}=[roicell{kieq,2},pixels(irow)];
                                roicell{kieq,3}=[roicell{kieq,3},MS(i)];
                                roicell{kieq,4}=[roicell{kieq,4},irow];
                                
                                if strcmp(weighted,'default: mean')
                                    roicell{kieq,5}=mean(roicell{kieq,1});
                                elseif strcmp(weighted,'median')
                                    roicell{kieq,5}=median(roicell{kieq,1});
                                elseif strcmp(weighted,'weighted')
                                    mzsint=[roicell{kieq,1}' roicell{kieq,3}'];
                                    roicell{kieq,5}=sum(prod(mzsint'))/sum(mzsint(:,2));
                                elseif strcmp(weighted,'max')
                                    mzsint=[roicell{kieq,1}' roicell{kieq,3}'];
                                    [~,indexMax]=max(mzsint(:,2));
                                    roicell{kieq,5}=mzsint(indexMax,1);
                                end
                                
                                mzroi(kieq)=roicell{kieq,5};
                                
                            end
                            
                            
                        else
                            
                            %disp('roi expansion'),
                            nmzroi=nmzroi+1;
                            roicell{nmzroi,1}=mz(i);
                            roicell{nmzroi,2}=pixels(irow);
                            roicell{nmzroi,3}=MS(i);
                            roicell{nmzroi,4}=irow;
                            roicell{nmzroi,5}=mz(i);
                            mzroi(nmzroi)=mz(i);
                            
                        end
                    end
                end
            else
            end
        end
    end
end

if nmzroi>1
    %{
    disp('initial mz ROI values'),disp(mzroi)
    disp(' ');
    disp(' ');
    disp(' ');
    disp(' *********************************************************');
    disp('initial nr of ROI'),disp(nmzroi-1)
    %}
    [mzroi,isort]=sort(mzroi);
    
    for i=1:nmzroi,for j=1:5,roicellsort{i,j}=roicell{isort(i),j};end,end
    roicell=roicellsort;
    %disp('');disp('');
    
    
    % last filtes ROI < tolerance
    check_error=1;
    while check_error==1
        for i=2:length(mzroi)
            error_mzroi(i-1)=abs(mzroi(i-1)-mzroi(i));
        end
        
        if strcmp(units,'daltons')
            valor=find(error_mzroi<mzerror);
        elseif strcmp(units,'ppm')
            delta=10^-6*mzerror*mzroi(i-1);
            valor=find(error_mzroi<delta);
        end
        
        
        if isempty(valor)
            check_error=0;
        else
            % ho fem 1 a 1
            roicell{valor(1),1}=[roicell{valor(1),1} roicell{valor(1)+1,1}];
            roicell{valor(1),2}=[roicell{valor(1),2} roicell{valor(1)+1,2}];
            roicell{valor(1),3}=[roicell{valor(1),3} roicell{valor(1)+1,3}];
            roicell{valor(1),4}=[roicell{valor(1),4} roicell{valor(1)+1,4}];
            
            if strcmp(weighted,'default: mean')
                roicell{valor(1),5}=mean(roicell{valor(1),1});
            elseif strcmp(weighted,'median')
                roicell{valor(1),5}=median(roicell{valor(1),1});
            elseif strcmp(weighted,'weighted')
                mzsint=[roicell{valor(1),1}' roicell{valor(1),3}'];
                roicell{kieq,5}=sum(prod(mzsint'))/sum(mzsint(:,2));
            elseif strcmp(weighted,'max')
                mzsint=[roicell{kieq,1}' roicell{kieq,3}'];
                [~,indexMax]=max(mzsint(:,2));
                roicell{kieq,5}=mzsint(indexMax,1);
            end
            
            roicell(valor(1),:)=[];
            
            mzroi(valor(1))=roicell{valor(1),5};
            mzroi(valor(1)+1)=[];
            clear valor error_mzroi;
        end
    end
    % *****************************
    % update nmzroi
    nmzroi=length(mzroi);
    
    % disp('nr of ROI after check tolerance'),disp(nmzroi)
    
    % Now, filter those having a minimum number of pixels
    % and a maximum value higher than thresh
    
    for i=1:nmzroi
        if isempty(roicell{i,3}),roicell{i,3}=0;end
        maxroi(i)=max(roicell{i,3});
    end
    
    for i=1:nmzroi
        if isempty(roicell{i,4}),roicell{i,4}=0;end
        minPix(i)=length(unique(roicell{i,4}));
    end
    
    iroi=find(maxroi>(thresh*factorThresh) & minPix>minPixels);
    
    mzroi=mzroi(iroi);
    nmzroi=length(mzroi);
    
    % number of pixels
    %{
    disp('final nr of ROI (thresh*factor, minpixels)'),disp(nmzroi)
    disp('final mz ROI values'),disp(mzroi)
    disp(' ');
    disp(' ');
    disp(' *********************************************************');
    %}
    
    roicell=roicell(iroi,:);
    
    % pause
    
    % Evaluation of MS values from roicell{nmzroi,3}
    % Now evaluating MS matrix only for thes mzroi values
    % Defining first the backgound
    
    MSroi=zeros(nrows,nmzroi);
    
    for i=1:nmzroi
        nval=length(roicell{i,4});
        for j=1:nval
            irow=roicell{i,4}(j);
            MSI=roicell{i,3}(j);
            MSroi(irow,i)=MSroi(irow,i)+MSI;
        end
    end
    
    if nmzroi>0
        % 出图
        %{
        disp('displaying MS spectra only ROI mz values - sum(MSroi)')
        figure
        bar(mzroi,sum(MSroi),mzerror)
        
        disp('displaying chromatograms only at ROI mz values')
        figure
        plot([1:nrows],MSroi)
        %}
    else
        warndlg('No ROIs survived after cleaning');
    end
    %{
    disp(' ');
    disp(' *********************************************************');
    disp(' ');
    disp('final number of mz roi values considered is: '),disp(nmzroi)
    
    
    disp(' ');
    disp(' *********************************************************');
    %}
    disp(' ************************** FINISH *******************************');
else
    warndlg('Number of detected ROIs is 0. Use a lower threshold');
end