function plotcopt(n)
% type of plot
typePlot=evalin('base','mcr_als.aux.typePlot_image;');
% flip y-axis
valorFLIP=evalin('base','mcr_als.aux.flip;');
mdis=evalin('base','mcr_als.aux.mdis;');
nn=evalin('base','mcr_als.alsOptions.nComponents;');
%
range_mode=evalin('base','mcr_als.cache.range_mode;');
strength=evalin('base','mcr_als.cache.strength;');

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
if typePlot==1
    if valorFLIP==1
        for i=1:n
            subplot(jj,kk,i),
            original_data=mdis{1,i};
            data=set_range(original_data,range_mode,strength);
            imagesc(data);
            axis ('xy','tight','image','off');
            colormap(flipud(hot));
        end
    else
        for i=1:n
            subplot(jj,kk,i),
            original_data=mdis{1,i};
            data=set_range(original_data,range_mode,strength);
            imagesc(data);
            axis ('tight','image','off');
            colormap(flipud(hot));
        end
    end
elseif typePlot==2
    if valorFLIP==1
        for i=1:n
            subplot(jj,kk,i),
            original_data=mdis{1,i};
            data=set_range(original_data,range_mode,strength);
            contour(data,50);
            axis ('xy','tight','image','off');
            colormap(flipud(hot));
        end
    else
        for i=1:n
            subplot(jj,kk,i),
            original_data=mdis{1,i};
            data=set_range(original_data,range_mode,strength);
            contour(data,50);
            axis ('tight','image','off');
            colormap(flipud(hot));
        end
    end
end
end