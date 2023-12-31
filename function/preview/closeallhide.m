function closeallhide
figHandles = findall(0, 'Type', 'figure');
for i = 1:numel(figHandles)
    % 获取窗口的可见性属性值
    visibility = get(figHandles(i), 'Visible');
    
    % 判断窗口是否为隐藏状态
    if strcmp(visibility, 'off')
        % 关闭隐藏的窗口
        close(figHandles(i));
    end
end
end