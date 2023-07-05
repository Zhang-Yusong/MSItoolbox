function [mascara,indexes,indexesii,mm,nn]=cut(Data,xpixn,ypixn)
sumM=sum(Data,2);
[m,~]=size(sumM);
index=(1:m)';

mascaraii=reshape(sumM,ypixn,xpixn);
indexesii=reshape(index,ypixn,xpixn);

mascarai=[];
indexesi=[];
for ii=1:ypixn
    if mascaraii(ii,:)==0
        continue
    else
        mascarai=[mascarai;mascaraii(ii,:)];
        indexesi=[indexesi;indexesii(ii,:)];
    end
end
mascara=[];
indexes=[];
for jj=1:xpixn
    if mascarai(:,jj)==0
        continue
    else
        mascara=[mascara,mascarai(:,jj)];
        indexes=[indexes,indexesi(:,jj)];
    end
end
[mm,nn]=size(indexes);