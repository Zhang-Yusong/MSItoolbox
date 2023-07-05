function Preview
currentFile=evalin('base','importMSv.load.currentFile;');
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
% si=evalin('base','all');
j=evalin('base','x');
k=evalin('base','y');

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

x=pack(:,1)';
y=pack(:,2)';
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
%补0
[xx,yy]=SupplementZero(x,y);
figure,plot(xx,yy,'LineWidth',2);
%
xlabel('m/z') 
ylabel('Intensity')
xticklabels('auto')
axis([xmin xmax ymin ymax]);
title({['Location of pixels:   x= ',num2str(j),' , ','y= ',num2str(k)]});
set(gca,'FontSize',16);
end