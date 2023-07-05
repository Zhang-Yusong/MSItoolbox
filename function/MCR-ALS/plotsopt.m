function plotsopt(sopt_xxx)
SVDnumber=evalin('base','mcr_als.alsOptions.nComponents;');
mzroi=evalin('base','importMSv.ROIplotGUI.current_mzroi');
aa=sqrt (SVDnumber);
bb=aa-fix(aa);
if (0<bb) && (bb<0.5)
    row=fix(aa);
    col=row+1;
else
    row=ceil(aa);
    col=row;
end

maxmz=max(mzroi);
minmz=min(mzroi);
maxim=max(max(sopt_xxx));
minim=min(min(sopt_xxx));

if maxim > 0
    maxim1=maxim+0.2*maxim;
else
    maxim1=maxim-0.2*abs(maxim);
end

if minim > 0
    minim1=minim-0.2*minim;
else
    minim1=minim-0.2*abs(minim);
end

if (minim == 0 & maxim == 0)
    minim1=minim-1;
    maxim1=maxim+1;
end

figure('Name','Spectra')

for i=1:SVDnumber
    subplot(row,col,i),
    [mz,y]=SupplementZero(mzroi,sopt_xxx(i,:));
    plot(mz,y,'LineWidth',2);
    axis([minmz maxmz minim1 maxim1]);
    % 设置刻度
    if i-(row-1)*col<=0
        set(gca,'xtick',[])
    end
    set(gca,'ytick',0:1:1);
    if rem((i-1),col)~=0
        set(gca,'ytick',[])
    end
    
    %
end

suptitle('MS spectra');
end