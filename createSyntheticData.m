function [I, J, S, I_test, J_test, S_test] = createSyntheticData(d,T,truerank,OS, noiseFac)
    % Sample data generation
    M = OS*truerank*(d + T -truerank); % total entries
    
    fprintf('Total number of entries: %d', M)
    
    % The left and right factors which make up our true data matrix Y.
    YL = randn(d, truerank);
    YR = randn(T, truerank);
    
    % Select a random set of M entries of Y.
    idx = unique(ceil(d*T*rand(1,(10*M))));
    idx = idx(randperm(length(idx)));
    idxM_sort = sort(idx(1:M));
    [I, J] = ind2sub([d, T],idxM_sort);
    I = uint32(I');
    J = uint32(J');
    
    % Values of Y at the locations indexed by I and J.
    S = sum(YL(I,:).*YR(J,:), 2);
    S_noiseFree = S;
   
    % Add noise.
    noise = noiseFac*max(S)*randn(size(S));
    S = S + noise;
    
    % Test data
    idx_test = unique(ceil(d*T*rand(1,(10*M))));
    idx_test = idx_test(randperm(length(idx_test)));
    [I_test, J_test] = ind2sub([d, T],idx_test(1:M));
    I_test = uint32(I_test');
    J_test = uint32(J_test');
    
    % Values of Y at the locations indexed by I_test and J_test.
    S_test = sum(YL(I_test,:).*YR(J_test,:), 2);
end