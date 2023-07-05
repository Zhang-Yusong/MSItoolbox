function images_initialization(xxxx)
% Pixels in X direction * 
currentFile=xxxx;
x_pixs=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.x_cut;']);
y_pixs=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.y_cut;']);

Pix=x_pixs * y_pixs;
PixIn=(1:Pix);

assignin('base','x_pixs',x_pixs);
assignin('base','y_pixs',y_pixs);
assignin('base','PixIn',PixIn);

evalin('base','mcr_als.aux.x=x_pixs;');
evalin('base','mcr_als.aux.y=y_pixs;');
evalin('base','mcr_als.aux.z=1;');
evalin('base','mcr_als.aux.pixin=PixIn;');
evalin('base','mcr_als.aux.pixout=0;');

evalin('base','clear y_pixs x_pixs PixIn');

sopt=evalin('base','mcr_als.alsOptions.resultats.optim_specs;');
[~,cs]=size(sopt);
longWave=(1:cs);
assignin('base','longWave',longWave);
evalin('base','mcr_als.aux.long=longWave;');
evalin('base','clear longWave');


%OK
copt=evalin('base',['mcr_als.alsOptions.resultats.img_',num2str(currentFile),'.copt;']);
sopt=evalin('base','mcr_als.alsOptions.resultats.optim_specs;');
[m,n]=size(copt);

% x
x=evalin('base','mcr_als.aux.x;');
% y
y=evalin('base','mcr_als.aux.y;');
% z -> number of images
z=evalin('base','mcr_als.aux.z;');

% pixin
pixin=evalin('base','mcr_als.aux.pixin;');
% pixout
pixout=evalin('base','mcr_als.aux.pixout;');

% if nargin <=6
%     pixout=0;
%     pixin=[1:m];
% end

mdis=cell(z,n);
quantc=zeros(z,n);
ctot=zeros(m,n);
ctot(pixin,:)=copt;

if pixout~=0
    ctot(pixout,:)=min(min(copt));
end

% reshaping conc profiles into maps frommultisets with images equally sized
if length( x)==1 & length(y)==1
    for j=0:z-1
        clayer=ctot((x*y)*j+1:(x*y)*(j+1),:);
        for i=1:n
            quantc(j+1,i)=100*(sum(sum(clayer(:,i)*sopt(i,:))))/(sum(sum(clayer*sopt)));
            mdis{j+1,i}=reshape(clayer(:,i),x,y);
%           figure(j+1),subplot(n,1,i),imagesc(mdis{j+1,i},[minc maxc]),axis('square')
            assignin('base','mdisIMG',mdis);
            evalin('base','mcr_als.aux.mdis=mdisIMG;');
            evalin('base','clear mdisIMG');
            
            assignin('base','quantcIMG',quantc);
            evalin('base','mcr_als.aux.quantc=quantcIMG;');
            evalin('base','clear quantcIMG');

        end
    end
end
% reshaping conc profiles into maps from multisets with images with different sizes
if length(x)>1 & length(y)>1
    ptot=0;
    for j=0:z-1
        clayer=ctot(ptot+1:ptot+x(j+1)*y(j+1),:);
        ptot=sum([ptot x(j+1)*y(j+1)]);
        for i=1:n
            quantc(j+1,i)=100*(sum(sum(clayer(:,i)*sopt(i,:))))/(sum(sum(clayer*sopt)));
            mdis{j+1,i}=reshape(clayer(:,i),x(j+1),y(j+1));
%           figure(j+1),subplot(n,1,i),imagesc(mdis{j+1,i},[minc maxc]),axis('square')
            assignin('base','mdisIMG',mdis);
            evalin('base','mcr_als.aux.mdis=mdisIMG;');
            evalin('base','clear mdisIMG');
 
            assignin('base','quantcIMG',quantc);
            evalin('base','mcr_als.aux.quantc=quantcIMG;');
            evalin('base','clear quantcIMG');

        end
    end
end