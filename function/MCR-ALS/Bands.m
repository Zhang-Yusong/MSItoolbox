function Bands

%****************************************************************************************
% 数据导入
%****************************************************************************************

c=evalin('base','mcr_als.alsOptions.resultats.optim_concs');
s=evalin('base','mcr_als.alsOptions.resultats.optim_specs');
evalin('base','mcr_bands.Data.conc=mcr_als.alsOptions.resultats.optim_concs;');
evalin('base','mcr_bands.Data.spec=mcr_als.alsOptions.resultats.optim_specs;');
[~,ydim]=size(c);
t0=eye(ydim);
[nsign,~]=size(s);
[~,~,v]=svd(c*s);
tnorm=norm(c*s,'fro');

%****************************************************************************************
% 优化运算 Optimize
%****************************************************************************************

global g
global nconstr

%初始化
nconstr=0;g=[];tband=[];tbandsvd=[];sband=[];cband=[];fband=[];normband=[];

% evaluation of initial determinants
options = optimset('Display','iter',...
    'Diagnostics','on',...
    'TolCon',0.0001,...
    'MaxIter',5000,...
    'Algorithm','active-set',...
    'Tolx',0.000001,...
    'DiffMinChange',0.00001,...
    'DiffMaxChange',0.1,...
    'MaxFunEvals',10000);

for ioptim=1:nsign
    % calculation of the maximum/outer band
    [tmax,fbandmax,exitflagmax]=fmincon(@fmaxmin,t0,[],[],[],[],[],[],@mycons,options,c,s,1,ioptim,[],[],[],[],1);
    fbandmax=-fbandmax;
    % calculation of the minimum/inner band
    [tmin,fbandmin,exitflagmin]=fmincon(@fmaxmin,t0,[],[],[],[],[],[],@mycons,options,c,s,2,ioptim,[],[],[],[],1);
    
    % values to keep for the optimization of each species band
    smax=tmax*s;
    cmax=c/tmax;
    smin=tmin*s;
    cmin=c/tmin;
    tmaxsvd=smax*v(:,1:nsign);
    tminsvd=smin*v(:,1:nsign);
    
    exitflag(ioptim,:)=[exitflagmax,exitflagmin];
    for ix=1:nsign
        tmaxsvd(ix,:)=tmaxsvd(ix,:)./tmaxsvd(ix,ix);
        tminsvd(ix,:)=tminsvd(ix,:)./tminsvd(ix,ix);
    end
    
    tband=[tband;tmax;tmin];
    tbandsvd=[tbandsvd;tmaxsvd;tminsvd];
    sband=[sband;smax(ioptim,:);smin(ioptim,:)];
    cband=[cband,cmax(:,ioptim),cmin(:,ioptim)];
    fband=[fband,[fbandmax;fbandmin]];
    %**************************************************************************
    normmin(ioptim)=norm(cmin(:,ioptim)*smin(ioptim,:),'fro')/tnorm;
    normmax(ioptim)=norm(cmax(:,ioptim)*smax(ioptim,:),'fro')/tnorm;
    normband=[normband;normmax(ioptim);normmin(ioptim)];
    
    % Calculation of initial function values for comparison with th eoptimized ones
    [finic(ioptim)]=fmaxmin(eye(nsign),c,s,2,ioptim,1);
    pause(1);
end

%****************************************************************************************
% 最终结果
%****************************************************************************************

assignin('base','nconstr',nconstr);
assignin('base','sband',sband);
assignin('base','nsign',nsign);
assignin('base','cband',cband);
assignin('base','tband',tband);
assignin('base','tbandsvd',tbandsvd);
assignin('base','fband',fband);
assignin('base','finic',finic);
assignin('base','exitflag',exitflag);
assignin('base','normband',normband);

evalin('base','mcr_bands.Results.nconstr=nconstr;');
evalin('base','mcr_bands.Results.sband=sband;');
evalin('base','mcr_bands.Results.nsign=nsign;');
evalin('base','mcr_bands.Results.cband=cband;');
evalin('base','mcr_bands.Results.tband=tband;');
evalin('base','mcr_bands.Results.tbandsvd=tbandsvd;');
evalin('base','mcr_bands.Results.fband=fband;');
evalin('base','mcr_bands.Results.finic=finic;');
evalin('base','mcr_bands.Results.exitflag=exitflag;')
evalin('base','mcr_bands.Results.normband=normband;');

evalin('base','clear sband cband nsign nconstr tband tbandsvd fband finic exitflag normband');

MCR_bands
end