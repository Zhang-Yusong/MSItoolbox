%鼠标选中特定区域（支持多个区域选取）
function [mask]=Free_select(I)
figure,imagesc(I);
axis tight image off;
colormap(flipud(hot));
colorbar
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
        line([m(k-1) m(k)],[n(k-1) n(k)],'color','b');
        k=k+1;
        c=c1;
    else
        break
    end
end
line([m(k-1) m(1)],[n(k-1) n(1)],'color','b');
B{row}=[m;n];
m=[];n=[];
end
BW=zeros(size(I));
BW=logical(BW);
for i=1:(row-1)  
    BW_temp = roipoly(I,B{i}(1,:),B{i}(2,:));
    BW=BW|BW_temp;
end
mask=uint8(BW);
close
%{
figure,imagesc(mask);
axis tight;
axis image;
axis off;
%}
end
