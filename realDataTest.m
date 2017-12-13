close all; clear; clc;

dataset = '/Users/mbhutani/Documents/Datasets/data_ml_1m.mat';


load(dataset);
data_real_org = data_ml_1m;
fprintf('dealing with file data_ml_1m');
data_real.rows = data_real_org.cols; % Transpose operation % Movies
data_real.cols = data_real_org.rows; % Users as columns.
data_real.entries = data_real_org.entries; % Ratings
 
rng(10);

% Movies as rows. Replace movie ids by integers.
[rows_sorted, ~, IC] = unique(data_real.rows);
movie_ids = 1:length(rows_sorted);
tmp = movie_ids(IC);
data_real.rows = tmp;
 
 
%% Remove the ones with entries zero
rm_ind = find(data_real.entries == 0);
data_real.entries(rm_ind) =[];
data_real.rows(rm_ind) =[];
data_real.cols(rm_ind) =[];

%%Shuffle the data and do a test train split
shuffledIndices = randperm(length(data_real.rows));
data_real.rows = data_real.rows(shuffledIndices);
data_real.cols = data_real.cols(shuffledIndices);
data_real.entries = data_real.entries(shuffledIndices);

numElements = length(shuffledIndices);
num_element_test = ceil(0.2*numElements);
data_real_test.rows = data_real.rows(1:num_element_test);
data_real_test.col = data_real.cols(1:num_element_test);
data_real_test.entries = data_real.entries(1:num_element_test);
    
data_real_train.rows = data_real.rows(num_element_test+1 : numElements);
data_real_train.cols = data_real.cols(num_element_test+1 : numElements);
data_real_train.entries = data_real.entries(num_element_test+1 : numElements);

fprintf('Train-test split complete.\n')

% Mean subtraction: Ben Rechts paper.
 trainmean = mean(data_real_train.entries); % Training non-zero entries
 data_real_train.entries = data_real_train.entries - trainmean;
 data_real_test.entries = data_real_test.entries - trainmean;
 
fprintf('Mean subtraction complete.\n')

max_row_val = max(max(data_real_train.rows), max(data_real_test.rows));
max_col_val = max(max(data_real_train.cols), max(data_real_train.cols));

X_orig_train_masked = sparse(data_real_train.rows, data_real_train.cols, data_real_train.entries, max_row_val, max_col_val);
X_orig_test_masked =  sparse(data_real_test.rows, data_real_test.col, data_real_test.entries, max_row_val, max_col_val);
mask_train = sparse(data_real_train.rows, data_real_train.cols, ones(1, length(data_real_train.rows)), max_row_val, max_col_val);
mask_test = sparse(data_real_test.rows, data_real_test.col, ones(1, length(data_real_test.rows)), max_row_val, max_col_val);

%Adding the information about the test matrix
x_info_test_full.x = data_real_test.entries;
x_info_test_full.i = uint32(data_real_test.rows');
x_info_test_full.j = uint32(data_real_test.col);
x_info_test_full.num_entries = length(data_real_test.entries);

baselineNorm = norm(x_info_test_full.x, 'fro');
baselineError = (baselineNorm^2)/x_info_test_full.num_entries;
baselineRMSE = sqrt(baselineError);

fprintf('\n\nbaseline RMSE = %e\n\n', baselineRMSE);

fprintf('Mask generation complete.\n')

%Number of unique rows (total number in sparse matrix)
x_m = max(data_real.rows);

%Number of columns
x_n = max(data_real.cols);

%The rank we want in the decomposition. 
x_r = 10;

%Number of rows we want in decomposition. 
x_num_block_rows = 3;

%Number of columns we want in decomposition. 
x_num_block_columns = 3;


x_num_rows_per_block = x_m/x_num_block_rows;
x_num_cols_per_block = x_n/x_num_block_columns;

fprintf('x_m = %d\n', x_m)
fprintf('x_n = %d\n', x_n)
fprintf('x_num_block_rows = %d\n', x_num_block_rows)
fprintf('x_num_block_columns = %d\n', x_num_block_columns)
fprintf('x_num_rows_per_block = %d\n', x_num_rows_per_block)
fprintf('x_num_cols_per_block = %d\n', x_num_cols_per_block)

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
        fprintf('In loop (%d,%d)...', i, j)
        x_train_masked{i,j} = X_orig_train_masked(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        x_test_masked{i,j} = X_orig_test_masked(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        mask_train_cell{i,j} = mask_train(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
        mask_test_cell{i,j} = mask_test(x_num_rows_per_block*(i-1)+1 : x_num_rows_per_block*i, x_num_cols_per_block*(j-1)+1 : x_num_cols_per_block*j);
       
        x_info_train{i,j} = getInfoStruct(x_train_masked{i,j});
        x_info_test{i,j} = getInfoStruct(x_test_masked{i,j});
    end
end

fprintf('Cell generation complete.\n')

fprintf('rank x_r = %d\n', x_r)

fprintf('setting the config params.\n')
%Setting up configuration parameters 
configurationParams.max_iter = 30000; 40000000;
configurationParams.rho = 1e3;
configurationParams.step_size_param_a = 1e-4;
configurationParams.step_size_param_b = 1e-4;
%configurationParams.step_size_param_b = 5*1e-7;
configurationParams.record_metrics = true;
configurationParams.total_cost_inspection_granularity = 10000;
configurationParams.d_cost_inspection_granularity = 100;
configurationParams.use_hessian = false;
configurationParams.lambda = 10;

fprintf('\n\nbaseline RMSE = %e\n\n', baselineRMSE);

[u_cell, w_cell, optionalReturn] = matrixCompletion(x_info_train, x_info_test, mask_train_cell, mask_test_cell, x_r, configurationParams, x_info_test_full);

