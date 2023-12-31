function exportcluster
currentFile=evalin('base','importMSv.kmean.currentFile;');
class=evalin('base','importMSv.kmean.class;');
cidxn=evalin('base','importMSv.kmean.cidxn;');
MSroi=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.MSroi;']);
x=evalin("base",'importMSv.ROIplotGUI.current_mzroi');
Allpixel=evalin('base','importMSv.kmean.Allpixel;');
m=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.x_cut;']);
n=evalin('base',['importMSv.ROIplotGUI.img_',num2str(currentFile),'.y_cut;']);
cmap=evalin('base','importMSv.kmean.cmap;');
name_short=evalin('base',['importMSv.summary.img_',num2str(currentFile),'.name_short;']);
cidxn=cidxn(Allpixel(currentFile)+1:Allpixel(currentFile+1),:);

% 寻找y最大值
mean_ya=[];
for ii=1:class
    mean_ys = mean(MSroi(cidxn==ii,:),1);
    mean_ya=[mean_ya;mean_ys];
    ymaxx(ii)=max(mean_ys);
end
xmin=min(x);xmax=max(x);ymax=max(ymaxx);%ymax=max(mean(MSroi,1));

runpartialareaROI=evalin('base',['importMSv.summary.img_',num2str(currentFile),'.runpartialareaROI;']);
if runpartialareaROI==2
    MSicut=evalin('base',['importMSv.Partialarea.img_',num2str(currentFile),'.MSicut;']);
    if MSicut==2
        mask=evalin('base',['importMSv.Partialarea.img_',num2str(currentFile),'.mask;']);
        mascaran=reshape(double(mask),[],1);
        mascaran(mascaran==1)=cidxn;
        cidxn=mascaran;
        cmap=cmap(2:end,:);
    end
end

for i=1:class
    figure;
    % 分布图
    subplot(2,1,1)
    cidxni=cidxn;
    cidxni(cidxni~=i)=0;
    if max(cidxni(:))==0
        coo=[1,1,1];
    else
        coo=[1,1,1;cmap(i,:)];
    end
    
    imagesc(reshape(cidxni,m,n));
    %imagesc(rot90(reshape(cidxni,m,n),3));
    axis('tight','image');colormap(coo);
    title('Spatial distribution')
    
    % 平均谱
    subplot(2,1,2)
    mean_y = mean_ya(i,:);
    [xx,yy]=SupplementZero(x,mean_y);
    plot(xx,yy,'LineWidth',2);axis([xmin xmax 0 ymax]);
    title('Average mass spectrum');
    sgtitle([strcat('Data:',name_short),'   Class',num2str(i)],'Interpreter','none');
    %suptitle([strcat('Data:',name_short),'   Class',num2str(i)],'Interpreter','none');
end
end