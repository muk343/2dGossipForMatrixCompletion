function u_global = getGlobalU(UCell)

[m, n] = size(UCell);
u_global_temp = cell(1, m);

for i = 1:m
    concatenatedU = cat(3, UCell{i, :});
    u_global_temp{1, i} = mean(concatenatedU, 3);
end

u_global = cat(1, u_global_temp{1,:});
end