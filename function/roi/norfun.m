function A=norfun
A.fun1 = @origin;  % 原图
A.fun2 = @norEuc;  % 欧氏距离
A.fun3 = @norTIC;  % TIC
A.fun4 = @norVec;  % vecnorm
A.fun5 = @zscstd;  % zscore_std
A.fun6 = @norm2;   % norm_2
A.fun7 = @scastd;  % scale_std
A.fun8 = @rantwo; % range_二元
A.fun9 = @cenmea; % center_mean
A.fun10 = @cenmed; % center_median
%
A.fun11 = @norminf; % norm_inf
A.fun12 = @zscrob;  % zscore_robust
A.fun13 = @scamad; % scale_mad
A.fun14 = @scafir; % scale_first
end

% 1
function [nordata,nortitle]=origin(data)
nordata=data;
nordata= max(nordata,0);
nortitle='未normalization';
end
% 2
function [nordata,nortitle]=norEuc(data)
sr=sqrt(sum((data.^2),2));
sn=data./sr;
nordata= max(sn,0);
nortitle='欧氏距离';
end
% 3
function [nordata,nortitle]=norTIC(data)
TIC=sum(data,2);
TIC=sum(TIC);
nordata=data./TIC;
nordata = max(nordata,0);
nortitle='TIC';
end
% 4
function [nordata,nortitle]=norVec(data)
sr=sqrt(vecnorm(data,2,2));
sn=data./sr;
nordata = max(sn,0);
nortitle='范数';
end
% 5
function [nordata,nortitle]=zscstd(data)
nordata=normalize(data,2,'zscore','std');
nordata= max(nordata,0);
nortitle='zscore-std';
end
% 6
function [nordata,nortitle]=norm2(data)
nordata=normalize(data,2,'norm',2);
nordata= max(nordata,0);
nortitle='norm-2';
end
% 7
function [nordata,nortitle]=scastd(data)
nordata=normalize(data,2,'scale','std');
nordata= max(nordata,0);
nortitle='scale-std';
end
% 8
function [nordata,nortitle]=rantwo(data)
nordata=normalize(data,2,'range');
nordata= max(nordata,0);
nortitle='range-二元';
end
% 9
function [nordata,nortitle]=cenmea(data)
nordata=normalize(data,2,'center','mean');
nordata= max(nordata,0);
nortitle='center-mean';
end
% 10
function [nordata,nortitle]=cenmed(data)
nordata=normalize(data,2,'center','median');
nordata= max(nordata,0);
nortitle='center-median';
end




% 11
function [nordata,nortitle]=norminf(data)
nordata=normalize(data,2,'norm','Inf');
nordata= max(nordata,0);
nortitle='norm-inf';
end
% 12
function [nordata,nortitle]=zscrob(data)
nordata=normalize(data,2,'zscore','robust');
nordata= max(nordata,0);
nortitle='zscore_robust';
end
% 13
function [nordata,nortitle]=scamad(data)
nordata=normalize(data,2,'scale','mad');
nordata= max(nordata,0);
nortitle='scale_mad';
end
% 14
function [nordata,nortitle]=scafir(data)
nordata=normalize(data,2,'scale','first');
nordata= max(nordata,0);
nortitle='scale_first';
end

