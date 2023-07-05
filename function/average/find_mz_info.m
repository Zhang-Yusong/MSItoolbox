function mz_info_found = find_mz_info(mz, KDP, library, col)

% mz 是实验得到的想要对库的质荷比
% KDP （keep decimal places）保留小数点后几位数字
% path 是数据库所在位置的绝对路径
% col 是数据库中质荷比所在列数 (根据不同数据库更改)

% 输出 mz_info_found 是一个表格，此表中每一列的数字分别对应如下信息：
%   第一列 m/z 是实验得到的质荷比数值
%   第二列 数据库中的质荷比数值
%   第三列 质荷比的差值（实验所得质荷比减去数据库的质荷比的到的差值）
%   第四列 数据库中质荷比的序号（此序号+1 为excel中的行数。因为excel中表头为第一行）
%   第五烈 蛋白质注释
%   第六列 母蛋白编号
%   第七列 在母蛋白中的位置
basemz = table2array(library(:,col));
mz_found = [];
info_found = table;

for i = 1:length(mz)
    a = mz(i);
    for j = 1:length(basemz)
        matrix = [];
        b = basemz(j);
        
        if isequal(floor(a*(10^KDP)),floor(b*(10^KDP))) == 1
            
            info_found = [info_found;library(j,:)];
            matrix = [a,b,a-b,j];
            mz_found = [mz_found;matrix];
            
            %disp(i)
        end
    end
end
if isempty(mz_found)==1
    disp('The substance was not found in the library')
    mz_info_found=[];
else
    t = table(mz_found(:,1),mz_found(:,2),mz_found(:,3),mz_found(:,4),...
        'VariableNames',{'m/z','m/z in library','Delta m/z','row in library'});
    info_found(:,col) = [];
    mz_info_found = [t,info_found];
end

end




