function [g_ineq,g_eq]=mycons(t,c,s,imaxmin,ioptim,ig,clos,cknown,sknown,nexp)

global g
global nconstr

[~,nsign]=size(c);
gnorm=[];gcneg=[];gsneg=[];
snew=t*s;
cnew=c/t;
for i=1:nsign
    gnorm=[gnorm;1-norm(snew(i,:),'fro')];	% nsign spectra normalization constraints
    gcneg=[gcneg;-cnew(:,i)];gsneg=[gsneg;-snew(i,:)']; % nsign*nrow + nsign*ncol concentration + spectra non-negativity constraints
end
% set final vector of constraints
g_eq=gnorm;
g_ineq=[gcneg;gsneg];
nconstr=[length(gnorm),length(gcneg),length(gsneg),length(g)];
g=[g_eq;g_ineq];