function [photo,photox,photoy,nslice]=extractdata(n)

% 提取所需矩阵
%{
mzlist=importMSv.ROIplotGUI.current_mzroi;
[~,n]=min(abs(mzlist-mzvalue));
mz=mzlist(n);
sda=[];
%}
nslice=evalin('base','importMSv.load.noFiles;');
for i=1:nslice
    %eval(['data.imp',num2str(i),'=importMSv.ROIplotGUI.img_',num2str(i),'.MSroi;']);
    data=evalin('base',['importMSv.mcr_als.alsOptions.resultats.img_',num2str(i),'.copt;']);
    phox=evalin('base',['importMSv.ROIplotGUI.img_',num2str(i),'.x_cut;']);
    phoy=evalin('base',['importMSv.ROIplotGUI.img_',num2str(i),'.y_cut;']);
    
    runpartialareaROI=evalin('base','importMSv.summary.runpartialareaROI;');
    if runpartialareaROI==2
        MSicut=evalin('base',['importMSv.Partialarea.img_',num2str(i),'.MSicut;']);
        if MSicut==2
            mask=evalin('base',['importMSv.Partialarea.img_',num2str(i),'.mask;']);
            mascaran=reshape(double(mask),[],1);
            loc=find(mascaran~=0);
            [~,n]=size(data);
            m=phox*phoy;
            ctot=zeros(m,n);
            ctot(loc,:)=data;
            data=ctot;
        end
    end
    
    imp{i,1}=data;
    sda(i,1)=phox;
    sda(i,2)=phoy;
end
% 找到最大矩阵形状,并获取对应形状
photox=max(sda(:,1));
photoy=max(sda(:,2));

% 串联成三维矩阵
photo= zeros(photox,photoy,nslice);
for k = 1:nslice
    datacache=imp{k,1};
    datacache=datacache(:,n,:);
    sizex=evalin('base',['importMSv.ROIplotGUI.img_',num2str(k),'.x_cut;']);
    sizey=evalin('base',['importMSv.ROIplotGUI.img_',num2str(k),'.y_cut;']);
    
    datacache=reshape(datacache,sizex,sizey);
    
    xc=(photox-sizex);
    if xc>0
        datacache=[datacache;zeros(xc,sizey)];
    end
    
    [m,~]=size(datacache);
    yc=(photoy-sizey);
    if yc>0
        datacache=[datacache,zeros(m,yc)];
    end
    
    photo(:,:,k)=datacache;
end


end