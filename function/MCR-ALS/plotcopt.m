function plotcopt
SVDnumber=evalin('base','mcr_als.alsOptions.nComponents;');
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

aa=sqrt (nn);
bb=aa-fix(aa);
if (0<bb) && (bb<0.5)
    jj=fix(aa);
    kk=jj+1;
else
    jj=ceil(aa);
    kk=jj;
end

figure('Name','Conc distribution')
suptitle('Concentration distribution');
for i=1:SVDnumber
    subplot(jj,kk,i),
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
end
end