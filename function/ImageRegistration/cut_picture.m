function [out_roi] = cut_picture(a)
figure,imshow(a,[],'Interpolation','bilinear')
b=imrect;
h=getPosition(b); %在图片上画roi区域，一般图片有三个维度（行，列，三通道）  round函数是四舍五入取整
row=round(h(2));    %左上角的点所在的行
col=round(h(1));    %左上角的点所在的列
high=round(h(4));   %roi区域的高度
width=round(h(3));  %roi区域的宽度
out_roi=a(row:row+high,col:col+width,:  );
close
%
% figure,imshow(out_roi,[],'Interpolation','bilinear')
%}
end