function pure_2022
evalin('base','mcr_als.InitEstim.pureDirection=2;');
d=evalin('base','importMSv.ROIplotGUI.current_MSroi;');
nr=evalin('base','mcr_als.CompNumb.nc;');
f=evalin('base','mcr_als.InitEstim.pureNoiseLevel;');
d=d';
[nrow,ncol]=size(d);

% calculation of the purity spectrum
f=f/100;
s=std(d);
m=mean(d);
ll=s.*s+m.*m;
f=max(m)*f;
p=s./(m+f);

[mp,imp(1)]=max(p);

l=sqrt((s.*s+(m+f).*(m+f)));

for j=1:ncol
    dl(:,j)=d(:,j)./l(j);
end
c=(dl'*dl)./nrow;

% calculation of the weights
% first weight
w(1,:)=ll./(l.*l);
p(1,:)=w(1,:).*p(1,:);
s(1,:)=w(1,:).*s(1,:);

% next weights
for i=2:nr
    for j=1:ncol
        [dm]=wmat(c,imp,i,j);
        w(i,j)=det(dm);
        p(i,j)=p(1,j).*w(i,j);
        s(i,j)=s(1,j).*w(i,j);
    end

    % next purest and standard deviation spectrum

    [mp(i),imp(i)]=max(p(i,:));
%     disp('next purest variable: ');disp(imp(i))
end

for i=1:nr
    impi=imp(i);
    sp(1:nrow,i)=d(1:nrow,impi);
end

sp=normv2(sp');

for i=1:length(imp)
    Scell(i)={imp(i)};
end

% list of purest variables
assignin('base','imp',imp);
evalin('base','mcr_als.InitEstim.indices=imp;');
evalin('base','clear imp');

assignin('base','sp',sp);
evalin('base','mcr_als.InitEstim.iniesta=sp;');
evalin('base','clear sp');

% OK
evalin('base','mcr_als.aux.estat=2;');
evalin('base','mcr_als.InitEstim.method=''Pur'';');
%排序
indexs=evalin('base','mcr_als.InitEstim.indices;');
sp=evalin('base','mcr_als.InitEstim.iniesta;');
[x,i]=sort(indexs);
sp=sp(i,:);
assignin('base','sp',sp);
evalin('base','mcr_als.InitEstim.iniesta=sp;');
evalin('base','clear sp');