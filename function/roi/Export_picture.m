function Export_picture(list,currentFile,mzerror,units,savepath,range_mode,strength)
x_pixels=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.x_cut;']);
y_pixels=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.y_cut;']);
MSroi=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.MSroi;']);
mzroi=evalin('base','importMSv.ROIplotGUI.current_mzroi');
name=evalin('base',['importMSv.summary.img_',num2str(currentFile),'.name_short;']);

mz_selet=list(:,1);
mzlength=length(mz_selet);

t=0;tic
for h=1:mzlength 
    
    mzi=mz_selet(h);
    [~,n]=min(abs(mzroi-mzi));
    mz=mzroi(n);
    
    % 取精确度范围
    if strcmp(units,'Th')
        ieq=find(abs(mzroi-mz)<=mzerror);
        thnu=mzerror;
        pmnu=(mzerror*10^6)/mz;
    elseif strcmp(units,'ppm')
        delta=10^-6*mzerror*mz;
        ieq=find(abs(mzroi-mz)<=delta);
        thnu=delta;
        pmnu=mzerror;
    end
    
    %取数据
    closeallhide
    set(gcf, 'Visible', 'off');
    original_data=sum(MSroi(:,ieq),2);
    
    runpartialareaROI=evalin('base',['importMSv.summary.img_',num2str(currentFile),'.runpartialareaROI;']);
    if runpartialareaROI==2
        MSicut=evalin('base',['importMSv.Partialarea.img_',num2str(currentFile),'.MSicut;']);
        if MSicut==2
            mask=evalin('base',['importMSv.Partialarea.img_',num2str(currentFile),'.mask;']);
            mascaran=reshape(double(mask),[],1);
            mascaran(mascaran==1)=original_data;
            original_data=mascaran;
        end
    end
    
    data=set_range(original_data,range_mode,strength);
    imagesc(reshape(data,x_pixels,y_pixels))
    axis('tight','image') ;colormap('jet');colorbar;
    title({strcat('name : ',name);['m/z : ',num2str(mz),' ± ',num2str(sprintf('%0.4f',thnu)),' Th',' (',num2str(pmnu),'ppm)']},'Interpreter','none');
    
    % 保存
    save_image=frame2im(getframe(gcf));
    imwrite(save_image,[savepath,'\',strrep(num2str(mz), '.', '_'),'.png'] );
    disp(['***********************Saved to ',num2str(h),'/',num2str(mzlength),'*****************************'])
end
t=t+toc;
disp(['The time taken for this export is:',num2str(t),'s'])
end