function [mzroi,roicell]=new_peakviewroi(pack)
mzroi=[];
mzerror=0.01;
thresh=0;
%min(cellfun(@(x) min(x(x(:,2)>0,2)), pack(:,1)));
%
roicell={};
for ipix=1:length(pack)
    A=pack{ipix};
    if ~isempty(A)
        % 确保 m/z 单调递增
        if ~issorted(A,'rows')
            A = sortrows(A,1);
        end
        if ~any(A(:,1))
            A = [];
        end
    end
    A=double(A);
    if ~isempty(A)
        ipeak=find(A(:,2)>thresh);
        if isfinite(ipeak)
            mzroi=[mzroi,A(ipeak,1)'];
            % 预存矩阵
            roicell_cache={};
            roicell_cache(:,1:2)=num2cell(A(ipeak,:));
            roicell_cache(:,3)=num2cell(ipix);
            roicell_cache(:,4)=roicell_cache(:,1);
            % 合并
            roicell=[roicell;roicell_cache];
            % 排序 费时间
            [mzroi,isort]=sort(mzroi);
            roicell=roicell(isort,:);
            %整合
            check_error=1;
            while check_error==1
                % 算误差
                error_mzroi=abs(diff(mzroi));
                valor=find(error_mzroi<mzerror);
                valor(:,(find(abs(diff(valor))==1)+1))=[];
                
                if isempty(valor)
                    check_error=0;
                else
                    roicell(valor,1:3)= cellfun(@(x, y) [x,y], roicell(valor,1:3), roicell(valor+1,1:3), 'UniformOutput', false);
                    mzroi(valor) = cellfun(@(x) mean(x), roicell(valor,1));
                    roicell(valor,4) = num2cell(mzroi(valor));
                    
                    roicell(valor+1,:)=[];
                    mzroi(:,valor+1)=[];
                    
                    clear valor error_mzroi;
                end
            end
        end
    end
end
% 查验
[mzroi,isort]=sort(mzroi);
roicell=roicell(isort,:);
check_error=1;
while check_error==1
    error_mzroi=abs(diff(mzroi));
    valor=find(error_mzroi<mzerror);
    valor(:,(find(abs(diff(valor))==1)+1))=[];
    
    if isempty(valor)
        check_error=0;
    else
        roicell(valor,1:3)= cellfun(@(x, y) [x,y], roicell(valor,1:3), roicell(valor+1,1:3), 'UniformOutput', false);
        roicell(valor,4) = num2cell(cellfun(@(x) mean(x), roicell(valor,1)));
        
        roicell(valor+1,:)=[];
        mzroi=cell2mat(roicell(:,4))';
        
        clear valor error_mzroi;
    end
end
