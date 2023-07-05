function [allpixel,cols,rows]=Allpixel
currentFile=evalin('base','importMSv.load.currentFile;');
MSi.Filename=evalin('base',['importMSv.load.img_',num2str(currentFile),'.fileName']);
MSi.Pathname=evalin('base',['importMSv.load.img_',num2str(currentFile),'.pathName;']);
% 判断 .ibd 文件与 .imzML 文件是否在同一文件夹里
[~,fname] = fileparts(MSi.Filename); 
if isempty(dir([MSi.Pathname fname '.ibd']))
    errordlg({['''' fname '.ibd'''] 'not found in the same directory.'}, ...
        'Load imzML File','modal');
    return;
end
% 添加Java到工作路径
javaclasspath(['\imzMLConverter' filesep 'imzMLConverter.jar']);
% 读取数据形状
imzML = imzMLConverter.ImzMLHandler.parseimzML([MSi.Pathname MSi.Filename]);
rows  = imzML.getWidth();
cols  = imzML.getHeight();
allpixel  = rows * cols;
% 确保文件的行列数是合理的（行或列不为0）
if (cols == 0) || (rows == 0)
    errordlg({'''Spots per line'' and/or ''number of lines'' parameters'
        'cannot be found in the file.'},'Load imzML file','modal');
    return;
end
%检测程序是否能正常运行————执行对(1,1)像素点的扫描并删除
try
    imzML.getSpectrum(1,1);
    clear ans
catch ME
end