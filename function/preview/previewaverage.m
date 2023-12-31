function [rc_pack,lt,it]=previewaverage(currentFile,z,kind)
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
rows  = imzML.getWidth();
cols  = imzML.getHeight();
% kind=1时为遍历指定行；kind=2时为遍历指定列
banfengkuan=25;
infrequency=150;
rc_pack={};
if kind==1
    for k=1:rows
        try
            A=[];
            A(:,1) = imzML.getSpectrum(k,z).getmzArray();
            A(:,2) = imzML.getSpectrum(k,z).getIntensityArray();
            
            A=A(A(:,2)>0,:);
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
                del(del(:,2)<infrequency,:)=[];
                A(ismember(A(:,2),[0;del(:,1)]), :)=[];
            else
                A(A(:,2)==0, :)=[];
            end
            
            if ~isempty(A)
                % 将轮廓图转变为质心图
                asd = sortrows(A, -2);
                [m,~]=size(asd);
                ipeak=[];
                for i=1:m
                    if asd(i,2)>0
                        delta=10^-6*banfengkuan*asd(i,1);
                        ieq=find(abs(asd(:,1)-asd(i,1))<=delta);
                        ipeak=[ipeak;[asd(i,1),sum(asd(ieq,2))]];
                        asd(ieq,:)=0;
                    end
                end
            end
            ipeak = sortrows(ipeak, 1);
            rc_pack{k,1}=ipeak;
        catch
            rc_pack{k,1}=[];
        end
        
    end
elseif kind==2
    for j=1:cols
        try
            A=[];
            A(:,1) = imzML.getSpectrum(z,j).getmzArray();
            A(:,2) = imzML.getSpectrum(z,j).getIntensityArray();
            
            A=A(A(:,2)>0,:);
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
                del(del(:,2)<infrequency,:)=[];
                A(ismember(A(:,2),[0;del(:,1)]), :)=[];
            else
                A(A(:,2)==0, :)=[];
            end
            
            if ~isempty(A)
                % 将轮廓图转变为质心图
                asd = sortrows(A, -2);
                [m,~]=size(asd);
                ipeak=[];
                for i=1:m
                    if asd(i,2)>0
                        delta=10^-6*banfengkuan*asd(i,1);
                        ieq=find(abs(asd(:,1)-asd(i,1))<=delta);
                        ipeak=[ipeak;[asd(i,1),sum(asd(ieq,2))]];
                        asd(ieq,:)=0;
                    end
                end
            end
            ipeak = sortrows(ipeak, 1);
            
            
            rc_pack{j,1}=A;
        catch
            rc_pack{j,1}=[];
        end
    end
end

lt=length(rc_pack);

for i=1:lt
    ms= rc_pack{i};
    if isempty(ms)
        it(i)=0;
    else
        it(i)=sum(ms(:,2));
    end
end

end