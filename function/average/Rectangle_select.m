%MATLAB手动选取roi区域
function [out_roi,row,col,high,width] = Rectangle_select(a,indexes)
colorll=evalin('base','importMSv.summary.color;');

figure,imagesc(a);
axis tight image;colormap(colorll);colorbar
b=imrect;
h=getPosition(b); %在图片上画roi区域  

%一般图片有三个维度（行，列，三通道）  round函数是四舍五入取整
row=round(h(2));    %左上角的点所在的行
col=round(h(1));    %左上角的点所在的列
high=round(h(4));   %roi区域的高度
width=round(h(3));  %roi区域的宽度
out_roi=indexes(row:row+high,col:col+width,:  );
close
%{
figure,imagesc(out_roi);
axis tight;
axis image;
axis off;
colormap('jet');
colorbar
%}
end
