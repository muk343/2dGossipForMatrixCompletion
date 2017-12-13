%Initialize our original matrix X.
%The variable names are so chosen so that they don't mess up
%other scripts/functions unintentionally. 
close all; clear; clc;

%random seed
rng(10);

%Number of rows
x_m = 100000;

%Number of columns
x_n = 100000;

%The rank we want in the decomposition. 
x_r = 5;

%Number of rows we want in decomposition. 
x_num_block_rows = 5;

%Number of columns we want in decomposition. 
x_num_block_columns = 5;

%Degree of sparsity of training matrix.
OS = 5;
training_sparsity_percentage = OS*(x_m*x_r + x_n*x_r - x_r^2)/(x_m*x_n);

%Degree of sparsity of testing matrix.
test_sparsity_percentage = 0.1;

x_num_rows_per_block = x_m/x_num_block_rows;
x_num_cols_per_block = x_n/x_num_block_columns;

%{
[ mask_train, mask_test ] = getMasks( x_m, x_n, training_sparsity_percentage, test_sparsity_percentage );

%Randomly initializing our original matrix. 
X_initial = randn(x_m, x_r)* randn(x_r, x_n);
X_orig_train_masked = sparse(mask_train.*X_initial);
X_orig_test_masked = sparse(mask_test.*X_initial);


[I_train, J_train, S_train, I_test, J_test, S_test] = createSyntheticData(x_m, x_n, x_r, OS, 0);
X_orig_train_masked = sparse(double(I_train), double(J_train), S_train);
X_orig_test_masked = sparse(double(I_test), double(J_test), S_test);
mask_train = sparse(double(I_train), double(J_train), ones(1, length(I_train)));
mask_test = sparse(double(I_test), double(J_test), ones(1, length(I_test)));
%}

[I, J, S, I_test, J_test, S_test] = createSyntheticData(x_m, x_n, x_r, OS, 0);
X_orig_train_masked = sparse(double(I), double(J), S);
X_orig_test_masked = sparse(double(I_test), double(J_test), S_test);
mask_train = sparse(double(I), double(J), ones(1, length(I)));
mask_test = sparse(double(I_test), double(J_test), ones(1, length(I_test)));


%x_initial is the the original matrix (X_initial) decomposed into 
%cells. 
x_train_masked = cell(x_num_block_rows, x_num_block_columns);
x_test_masked = cell(x_num_block_rows, x_num_block_columns);
mask_train_cell = cell(x_num_block_rows, x_num_block_columns);
mask_test_cell = cell(x_num_block_rows, x_num_block_columns);

x_info_train = cell(x_num_block_rows, x_num_block_columns);
x_info_test = cell(x_num_block_rows, x_num_block_columns);


for i = 1:x_num_block_rows
    for j = 1:x_num_block_columns
        fprintf('In loop (%d,%d)', i, j)
        x_train_masked{i,j} = X_orig_train_masked(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        x_test_masked{i,j} = X_orig_test_masked(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        mask_train_cell{i,j} = mask_train(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        mask_test_cell{i,j} = mask_test(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
       
        x_info_train{i,j} = getInfoStruct(x_train_masked{i,j});
        x_info_test{i,j} = getInfoStruct(x_test_masked{i,j});
    end
end

fprintf('setting the config params')
%Setting up configuration parameters 
configurationParams.max_iter = 400000;
configurationParams.rho = 1e3;
configurationParams.step_size_param_a = 5*1e-4;
configurationParams.step_size_param_b = 5*1e-7;
configurationParams.record_metrics = true;
configurationParams.total_cost_inspection_granularity = 10000;
configurationParams.d_cost_inspection_granularity = 100;
configurationParams.use_hessian = false;

[u_cell, w_cell, optionalReturn] = matrixCompletion(x_info_train, x_info_test, mask_train_cell, mask_test_cell, x_r, configurationParams);

%{

%% Plots
dCostU = optionalReturn.dCostU;
dCostW = optionalReturn.dCostW;
totalBlockCost = optionalReturn.totalBlockCost;
max_iter = configurationParams.max_iter;
d_cost_inspection_granularity = configurationParams.d_cost_inspection_granularity;
num_segments = 2*(x_num_block_rows-1)*(x_num_block_columns -1);

fs = 20;
figure
storedCostU = dCostU(:,2,2);
semilogy(storedCostU(~isnan(storedCostU)),'-O','Color','b','LineWidth',2, 'MarkerSize',5);
ax1 = gca;
set(ax1,'FontSize',fs);
title('D cost of U for: (2,2)')
ylabel('dCost of U')
xlabel(['Every ',num2str(round(2*max_iter/(d_cost_inspection_granularity*num_segments))),' values recorded'])

figure
storedCostW = dCostW(:,2,2);
semilogy(storedCostW(~isnan(storedCostW)),'-O','Color','b','LineWidth',2, 'MarkerSize',5);
ax1 = gca;
set(ax1,'FontSize',fs);
title('D cost of W for: (2,2)')
ylabel('dCost of W')
xlabel(['Every ',num2str(round(2*max_iter/(d_cost_inspection_granularity*num_segments))),' values recorded'])

fs = 20;
figure
semilogy(totalBlockCost,'-O','Color','b','LineWidth',2, 'MarkerSize',5);
ax1 = gca;
set(ax1,'FontSize',fs);
title('Total block cost')
ylabel('Cost')
xlabel(['Iterations x', num2str(round(configurationParams.total_cost_inspection_granularity))])

%}




