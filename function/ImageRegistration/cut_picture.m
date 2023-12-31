function [out_roi] = cut_picture(a)
figure,imshow(a,[],'Interpolation','bilinear')
c=1;row=0;B={};
while(c==1)
row=row+1;
[x,y,c]=ginput(1);
m(1)=x;
n(1)=y;
k=2;
while(c==1)
    [x1,y1,c1]=ginput(1);
    if c1==1
        m(k)=x1;n(k)=y1;
        line([m(k-1) m(k)],[n(k-1) n(k)],'color','r','LineWidth',2);
        k=k+1;
        c=c1;
    else
        break
    end
end
line([m(k-1) m(1)],[n(k-1) n(1)],'color','r','LineWidth',2);
B{row}=[m;n];
m=[];n=[];
end
[mm,nn,~]=size(a);
BW=zeros(mm,nn);
BW=logical(BW);
for i=1:(row-1)  
    BW_temp = roipoly(a,B{i}(1,:),B{i}(2,:));
    BW=BW|BW_temp;
end
indix=uint8(BW);
out_roi=a.*indix;
close
% b=imrect;
% h=getPosition(b); %在图片上画roi区域，一般图片有三个维度（行，列，三通道）  round函数是四舍五入取整
% row=round(h(2));    %左上角的点所在的行
% col=round(h(1));    %左上角的点所在的列
% high=round(h(4));   %roi区域的高度
% width=round(h(3));  %roi区域的宽度
% out_roi=a(row:row+high,col:col+width,:  );
% close
% %
% % figure,imshow(out_roi,[],'Interpolation','bilinear')
% %}
end