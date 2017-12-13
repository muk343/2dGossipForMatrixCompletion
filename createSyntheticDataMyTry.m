function [I_train, J_train, S_train, I_test, J_test, S_test] = createSyntheticDataMyTry(d,T,truerank,OS, noiseFac)
    % Sample data generation
    M = OS*truerank*(d + T -truerank); % total entries
    
    % The left and right factors which make up our true data matrix Y.
    YL = randn(d, truerank);
    YR = randn(T, truerank);
    
    % Select a random set of M entries of Y.
    idx = unique(ceil(d*T*rand(1,(10*M))));
    idx = idx(randperm(length(idx)));
    
    num_element_test = ceil(0.2*length(idx));
    idx_test = idx(1:num_element_test);
    idx_train = idx(num_element_test+1 : length(idx));
    
    idx_train_sort = sort(idx_train);
    idx_test_sort = sort(idx_test);
    
    [I_test, J_test] = ind2sub([d, T],idx_test_sort);
    I_test = uint32(I_test');
    J_test = uint32(J_test');
    
    [I_train, J_train] = ind2sub([d, T],idx_train_sort);
    I_train = uint32(I_train');
    J_train = uint32(J_train');
    
    S_test = sum(YL(I_test,:).*YR(J_test,:), 2);
    S_train = sum(YL(I_train,:).*YR(J_train,:), 2);
    
    %{
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
    %}
end