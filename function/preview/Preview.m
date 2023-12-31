function Preview(x,y)
currentFile=evalin('base','importMSv.load.currentFile;');
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
name_short=evalin('base',['importMSv.summary.img_',num2str(currentFile),'.name_short;']);
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
% si=evalin('base','all');
j=x;
k=y;

%rows = imzML.getWidth();
%{
k=rem(si,cols);
j=1+(si-k)/cols;
if k == 0
    k=cols;
    j=j-1;
end
%}
pack(:,1) = imzML.getSpectrum(k,j).getmzArray();
pack(:,2) = imzML.getSpectrum(k,j).getIntensityArray();

%bar(pack(:,1),pack(:,2),10);
%msviewer(pack(:,1),pack(:,2))
%补0
x=pack(:,1)';
y=pack(:,2)';

[xx,yy]=SupplementZero(x,y);
%xx=x;yy=y;
xmin=min(xx);xmax=max(xx);ymin=min(y);ymax=max(y);

figure,plot(xx,yy,'LineWidth',2);
xlabel('m/z');ylabel('Intensity')
xticklabels('auto');axis([xmin xmax ymin ymax]);
title({['Name: ',name_short];['Location of pixels:   x= ',num2str(j),' , ','y= ',num2str(k)]},'Interpreter','none');
set(gca,'FontSize',16);
end