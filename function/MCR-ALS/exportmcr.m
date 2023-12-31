function exportmcr
SVDnumber=evalin('base','mcr_als.alsOptions.nComponents;');
sopt_xxx=evalin('base','mcr_als.alsOptions.resultats.optim_specs;');
mzroi=evalin('base','importMSv.ROIplotGUI.current_mzroi');
% type of plot
typePlot=evalin('base','mcr_als.aux.typePlot_image;');
% flip y-axis
valorFLIP=evalin('base','mcr_als.aux.flip;');
mdis=evalin('base','mcr_als.aux.mdis;');
nn=evalin('base','mcr_als.alsOptions.nComponents;');
%
range_mode=evalin('base','mcr_als.cache.range_mode;');
strength=evalin('base','mcr_als.cache.strength;');
colorll=evalin('base','importMSv.summary.color;');


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


for i=1:SVDnumber
    figure;
    %sopt
    subplot(2,1,2)
    [mz,y]=SupplementZero(mzroi,sopt_xxx(i,:));
    plot(mz,y);
    axis([minmz maxmz minim1 maxim1]);
    title('SOPT');
    
    %copt
    subplot(2,1,1)
    original_data=mdis{1,i};
    %original_data=rot90(mdis{1,i});
    data=set_range(original_data,range_mode,strength);
    
    if typePlot==1
        imagesc(data);
        if valorFLIP==1
            axis ('xy','tight','image','off');colormap(colorll);colorbar;
        else
            axis ('tight','image','off');colormap(colorll);colorbar;
        end
    elseif typePlot==2
        contour(data,50);
        if valorFLIP==1
            axis ('xy','tight','image','off');colormap(colorll);colorbar;
        else
            axis ('tight','image','off');colormap(colorll);colorbar;
        end
    end
    title('COPT');
    sgtitle(['Component:',num2str(i)])
end