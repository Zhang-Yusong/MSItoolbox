function als_2022

% initial estimation initialization from mcr-main
% ******************************************************************
iniesta=evalin('base','mcr_als.InitEstim.iniesta;');
assignin('base','iniesta',iniesta);
evalin('base','mcr_als.alsOptions.iniesta=iniesta;');
matdad=evalin('base','importMSv.ROIplotGUI.current_MSroi;');

% check dimensions of initial estimates
[nrow,ncol]=size(matdad);
[nrow2,ncol2]=size(iniesta);

if nrow2==nrow,	nsign=ncol2; ils=1;end
if ncol2==nrow, nsign=nrow2; iniesta=iniesta'; ils=1; end

if ncol2==ncol, nsign=nrow2; ils=2;end
if nrow2==ncol, nsign=ncol2; iniesta=iniesta'; ils=2; end

if ils==1
    conc=iniesta;
    assignin('base','conc',conc);
    [~,nsign]=size(conc);
    assignin('base','nComponents',nsign);
    evalin('base','mcr_als.alsOptions.nComponents=nComponents;');
    evalin('base','clear nComponents');
    
    abss=conc\matdad;
    assignin('base','abss',abss);
    %{
    % pca reproduction
    disp('   *********** Results obtained after application of PCA to the data matrix ***********');
    disp(' ');
    [u,s,v,d,sd]=pcarep(matdad,nsign);
    disp(' ');
    disp('   ************************************************************************************');
    disp(' ');
    disp(' ');
    
    % modificacio pel pca
    assignin('base','u_pca',u);
    evalin('base','mcr_als.alsOptions.pca.u_pca=u_pca;');
    
    assignin('base','s_pca',s);
    evalin('base','mcr_als.alsOptions.pca.s_pca=s_pca;');
    
    assignin('base','v_pca',v);
    evalin('base','mcr_als.alsOptions.pca.v_pca=v_pca;');
    
    assignin('base','d_pca',d);
    evalin('base','mcr_als.alsOptions.pca.d_pca=d_pca;');
    
    assignin('base','sd_pca',sd);
    evalin('base','mcr_als.alsOptions.pca.sd_pca=sd_pca;');
    
    evalin('base','clear u_pca s_pca v_pca d_pca sd_pca');
    %}
end

if ils==2
    abss=iniesta;
    assignin('base','abss',abss);
    [nsign,~]=size(abss);
    assignin('base','nComponents',nsign);
    evalin('base','mcr_als.alsOptions.nComponents=nComponents;');
    evalin('base','clear nComponents');
    
    conc=matdad/abss;
    assignin('base','conc',conc);
    %{
    % pca reproduction
    disp('   *********** Results obtained after application of PCA to the data matrix ***********');
    disp(' ');
    [u,s,v,d,sd]=pcarep(matdad,nsign);
    disp(' ');
    disp('   ************************************************************************************');
    disp(' ');
    disp(' ');
    
    % pca modification
    
    assignin('base','u_pca',u);
    evalin('base','mcr_als.alsOptions.pca.u_pca=u_pca;');
    
    assignin('base','s_pca',s);
    evalin('base','mcr_als.alsOptions.pca.s_pca=s_pca;');
    
    assignin('base','v_pca',v);
    evalin('base','mcr_als.alsOptions.pca.v_pca=v_pca;');
    
    assignin('base','d_pca',d);
    evalin('base','mcr_als.alsOptions.pca.d_pca=d_pca;');
    
    assignin('base','sd_pca',sd);
    evalin('base','mcr_als.alsOptions.pca.sd_pca=sd_pca;');
    
    evalin('base','clear u_pca s_pca v_pca d_pca sd_pca');
    %}
end
% 以上为计算
evalin('base','clear conc abss iniesta');
% 以下为点击continue内容
% nexp为线性问题
evalin('base','mcr_als.alsOptions.nexp=1;');
%row
evalin('base','mcr_als.alsOptions.nonegC.noneg=1;');
evalin('base','mcr_als.alsOptions.unimodC.unimodal=0;');
evalin('base','mcr_als.alsOptions.cselcC.cselcon=0;');
%column
evalin('base','mcr_als.alsOptions.nonegS.noneg=1;');
evalin('base','mcr_als.alsOptions.unimodS.unimodal=0;');
evalin('base','mcr_als.alsOptions.sselcS.sselcon=0;');
%row与column共用
evalin('base','mcr_als.alsOptions.closure.closure=0;');
%未知
evalin('base','mcr_als.alsOptions.trilin.appTril=0;');
evalin('base','mcr_als.alsOptions.weighted.appWeight=0;');
evalin('base','mcr_als.alsOptions.correlation.appCorrelation=0;');
evalin('base','mcr_als.alsOptions.correlation.checkSNorm=0;');
evalin('base','mcr_als.alsOptions.kinetic.appKinetic=0;');
evalin('base','mcr_als.alsOptions.multi.datamod=0;');

%Row
evalin('base','mcr_als.alsOptions.nonegC.ialg=2;');
evalin('base','mcr_als.alsOptions.nonegC.ncneg=0;');

dim=evalin('base','min(size(mcr_als.alsOptions.iniesta))');
form_cneg= ones(1,dim);
cneg(1,:)=form_cneg;
assignin('base','cneg',cneg);
evalin('base','mcr_als.alsOptions.nonegC.cneg=cneg;');
evalin('base','clear cneg');

%Constraints
evalin('base','mcr_als.alsOptions.nonegS.ialgs=2;');
evalin('base','mcr_als.alsOptions.nonegS.nspneg=0;');

dim=evalin('base','min(size(mcr_als.alsOptions.iniesta))');
form_spneg= ones(dim,1);
spneg(:,1)=form_spneg;
assignin('base','spneg',spneg);
evalin('base','mcr_als.alsOptions.nonegS.spneg=spneg;');
evalin('base','clear spneg nspneg');

%Spectra divided by Euclidean norm
evalin('base','mcr_als.alsOptions.closure.inorm=2;');
closX='Spectra equal lenght - divided by Frobenius norm';
assignin('base','closX',closX);
evalin('base','mcr_als.alsOptions.closure.type=closX;');
evalin('base','clear closX');

% als_parameters
evalin('base','mcr_als.alsOptions.out.out_conc=''copt'';');
evalin('base','mcr_als.alsOptions.out.out_spec=''sopt'';');
evalin('base','mcr_als.alsOptions.out.out_rat='''';');
evalin('base','mcr_als.alsOptions.out.out_res='''';');
evalin('base','mcr_als.alsOptions.out.out_std='''';');
evalin('base','mcr_als.alsOptions.out.out_area='''';');
evalin('base','mcr_als.alsOptions.opt.gr=''n'';');

end