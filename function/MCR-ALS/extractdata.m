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
    imp{i,1}=data;
    [sda(i,1),~]=size(data);
end
% 找到最大矩阵形状,并获取对应形状
xsize=max(sda(:,1));
number=find(sda(:,1)==xsize);
number=number(1,1);
photox=evalin('base',['importMSv.ROIplotGUI.img_',num2str(number),'.x_cut;']);
photoy=evalin('base',['importMSv.ROIplotGUI.img_',num2str(number),'.y_cut;']);

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
        datacache=[datacache;zeros(m,yc)];
    end
    
    photo(:,:,k)=datacache;
end


end