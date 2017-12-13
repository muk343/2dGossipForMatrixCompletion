function w_global = getGlobalW(WCell)

[m, n] = size(WCell);
w_global_temp = cell(n, 1);

for i = 1:n
    concatenatedW = cat(3, WCell{:, i});
    w_global_temp{i, 1} = mean(concatenatedW, 3);
end

w_global = cat(1, w_global_temp{:,1});
end