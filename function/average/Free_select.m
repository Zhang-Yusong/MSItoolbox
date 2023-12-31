%鼠标选中特定区域（支持多个区域选取）
function [mask,kk,B,noreg]=Free_select(I)
colorll=evalin('base','importMSv.summary.color;');
figure,imagesc(I);
axis tight image;colormap(colorll);colorbar;
hold on

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
kk(row)=k;
m=[];n=[];
end
noreg=row;
[mm,nn,~]=size(I);
BW=zeros(mm,nn);
BW=logical(BW);
for i=1:(row-1)  
    BW_temp = roipoly(I,B{i}(1,:),B{i}(2,:));
    BW=BW|BW_temp;
end
mask=uint8(BW);
close
%{
figure,imagesc(mask);
axis tight image off;
%}
end
