function data=set_range(original_data,range_mode,strength)
if range_mode==1
    mm=original_data(original_data>0);
    m=median(mm);
    data=original_data;
    data(data>m)=m;
elseif range_mode==2
    data=original_data;
elseif range_mode==3
    data=original_data;
    data(data>strength)=strength;
elseif range_mode==4
    data=original_data;
    mm=original_data(original_data>0);
    m=quantile(mm,strength,1);
    data(data>m)=m;
end
end
