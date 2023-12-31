function [mascara,indexes,indexesii,mm,nn]=cut(Data,xpixn,ypixn)
sumM=sum(Data,2);
[m,~]=size(sumM);
index=(1:m)';

mascara=reshape(sumM,ypixn,xpixn);
indexesii=reshape(index,ypixn,xpixn);
indexes=indexesii;
zerocol=find(sum(mascara,1)==0);
zerorow=find(sum(mascara,2)==0);
mascara(:,zerocol)=[];
mascara(zerorow,:)=[];
indexes(:,zerocol)=[];
indexes(zerorow,:)=[];
[mm,nn]=size(indexes);