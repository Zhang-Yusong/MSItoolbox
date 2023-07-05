function [xx,yy]=SupplementZero(x,y)
xx=[];
yy=[];
% 设置步长
accuracy=0.001;

a=-log10(accuracy);
%
for jjjj=(2:length(x))
    iiii=jjjj-1;
    x1=x(1,iiii);
    x2=x(1,jjjj);
    y1=y(1,iiii);
    di_x=x2-x1;
    if di_x>accuracy
        inte_x=round(x1,a);
        x_new=(inte_x+accuracy:accuracy:inte_x+di_x);
        xx=[xx x1 x_new];
        new_length=length(x_new);
        y_new=zeros(1,new_length);
        yy=[yy y1 y_new];
    else
        xx=[xx x1];
        yy=[yy y1];
    end
end