function[u_cell, w_cell, optionalReturn] = matrixCompletion(x_train_info, x_test_info, mask_train, mask_test, r, configurationParams, x_info_test_full)

%%
%Default values of configurable parameters:
max_iter_default = 50000;
rho_default = 1e3;
step_size_para_a_default = 1e-4;
step_size_param_b_default = 1e-5;
record_metrics_default = false;
use_hessian_default = false;
total_cost_inspection_granularity_default = 1000;
d_cost_inspection_granularity_default = 100;
lambda_default = 1e1;

%%

argumentParser = inputParser;
addParameter(argumentParser,'max_iter', max_iter_default)
addParameter(argumentParser,'rho',rho_default)
addParameter(argumentParser,'step_size_param_a',step_size_para_a_default)
addParameter(argumentParser,'step_size_param_b',step_size_param_b_default)
addParameter(argumentParser,'record_metrics',record_metrics_default)
addParameter(argumentParser,'use_hessian',use_hessian_default)
addParameter(argumentParser,'total_cost_inspection_granularity',total_cost_inspection_granularity_default)
addParameter(argumentParser,'d_cost_inspection_granularity',d_cost_inspection_granularity_default)
addParameter(argumentParser,'lambda',lambda_default)

parse(argumentParser, configurationParams)


%%
%Now that we have parsed input parameters, let's set the values
max_iter = argumentParser.Results.max_iter;
rho = argumentParser.Results.rho;
step_size_param_a = argumentParser.Results.step_size_param_a;
step_size_param_b = argumentParser.Results.step_size_param_b;
record_metrics = argumentParser.Results.record_metrics;
total_cost_inspection_granularity = argumentParser.Results.total_cost_inspection_granularity;
d_cost_inspection_granularity = argumentParser.Results.d_cost_inspection_granularity;
use_hessian = argumentParser.Results.use_hessian;
lambda = argumentParser.Results.lambda;

fprintf('Going with the following parameters: \n max_iter: %e \n rho: %e \n step_size_param_a: %e \n step_size_param_b: %e \n record_metrics: %d \n use_hessian: %d \n lambda: %e \n', ...
    max_iter, rho, step_size_param_a, step_size_param_b, record_metrics, use_hessian, lambda);
%%
%Add validations to check if the values are valid ones.

%%
close all;
%%
%Lets calculate dimensions:
[num_block_rows, num_block_columns] = size(x_train_info);
fprintf('Dimensions of decomposition, num block rows: %d  num block columns: %d\n', num_block_rows, num_block_columns);
%Add a check for greater than 0. 

[num_rows_per_block, num_cols_per_block] = size(mask_train{1,1});
%Add a check for greater than 0. 

%Assuming all the blocks and rows are homogenous in size:
m = num_block_rows*num_rows_per_block;
n = num_block_columns*num_cols_per_block;
fprintf('Dimensions of matrix, num rows: %d  num columns: %d\n', m, n);

%%
u = cell(num_block_rows, num_block_columns);
w = cell(num_block_rows, num_block_columns);

%Lets precompute and squre the masks one and for all
mask_squared_train = cell(num_block_rows, num_block_columns);
mask_squared_test = cell(num_block_rows, num_block_columns);

%The coefficients or weights to be multipled with f_cost and d_cost
%while calculating the gradient. This is to normalize occurence of
%different blocks. 
[f_cost_coefficients, d_costU_coefficients, d_costW_coefficients] = populateCoefficients(num_block_rows, num_block_columns);

%Number of times that particular block was updated. For logging purposes. 
num_times_updated = zeros(num_block_rows, num_block_columns);

%%
for i = 1:num_block_rows
    for j = 1:num_block_columns
        u{i,j} = rand(num_rows_per_block, r);
        %u{i,j} = zeros(num_rows_per_block, r) + 0.001*rand(num_rows_per_block, r);
        w{i,j} = rand(num_cols_per_block, r);
        
        %w{i,j} = zeros(num_cols_per_block, r) + 0.001*rand(num_cols_per_block, r);
        mask_squared_train{i,j} = mask_train{i,j}.*mask_train{i,j};
        mask_squared_test{i,j} = mask_test{i,j}.*mask_test{i,j};
    end
end

%%
%Calculate the total cost (and also the cost matrix) in the begining.
[train_total_cost, train_cost_matrix, dcostu, dcostw] = getTotalCost(num_block_rows, num_block_columns, u, w, x_train_info, rho, lambda);
[test_total_cost, test_cost_matrix,dcostu, dcostw] = getTotalCost(num_block_rows, num_block_columns, u, w, x_test_info, rho, lambda);
[total_block_cost, block_cost_matrix] = getTotalBlockCost(num_block_rows, num_block_columns, u, w, x_test_info, lambda);
fprintf('Initial train total cost: %e  test total cost: %e\n test total block: %e \n', train_total_cost, test_total_cost, total_block_cost);
fprintf('Initial test total block: %e \n', total_block_cost);


%%
if (record_metrics == true)
    fprintf('Total cost inspection granularity: %d iterations.\nD cost inspection granularity %d iterations.\n',....
        total_cost_inspection_granularity, d_cost_inspection_granularity);
    %Allocate memory for total cost computations.
    totalCostRecord = zeros([1 (max_iter/total_cost_inspection_granularity) + 1]);
    totalCostRecord(1) = test_total_cost;

    %Allocate memory for dcost computations.
    dCostU = nan((max_iter/d_cost_inspection_granularity), num_block_rows, num_block_columns-1);
    dCostW = nan((max_iter/d_cost_inspection_granularity), num_block_rows-1, num_block_columns);
end
     
%% Stochastic gradients algorithm
for num_iter = 1:max_iter
    %Pick up a segment at random.
    [t, i, j] = getRandomBlock(num_block_rows, num_block_columns);
    
    %if one wants to see how many number of times a certain block was
    %updated, then uncomment the following line.
    %num_times_updated = getNumUpdates(num_times_updated, i,j,t);
    
    %The step size is currently being updated using A/(1 + B*num_iter)
    %strategy. More options can be looked into. 
    step_size = step_size_param_a/(1 + (step_size_param_b*num_iter));

    %Update the u's and w's corresponding to it.
    %Add hessian option to it as well. 
    [u, w] = updateMatrixMasked(x_train_info, mask_train, mask_squared_train, t, i, j, u, w, rho, step_size, ...
                                f_cost_coefficients, d_costU_coefficients, d_costW_coefficients,lambda);
    
    %{                        
    %Get the new cost of the segment. d_cost_u and d_cost_w are recorded
    %for plotting.                             
    [test_new_local_cost, test_d_cost_u, test_d_cost_w] = getCost(t ,i, j, u, w, x_test_info, rho, lambda);
    [train_new_local_cost, train_d_cost_u, train_d_cost_w] = getCost(t ,i, j, u, w, x_train_info, rho, lambda);
    
    %Update the total cost by updating the cost of the segment.
    [train_total_cost, train_cost_matrix] = updateTotalCost(train_total_cost, train_cost_matrix, t, i, j, train_new_local_cost);
    [test_total_cost, test_cost_matrix] = updateTotalCost(test_total_cost, test_cost_matrix, t, i, j, test_new_local_cost);
    [total_block_cost, block_cost_matrix] = getAndUpdateFCost(total_block_cost, block_cost_matrix, ...
                                                              t, i, j, u, w, x_test_info, lambda);
    

                                %}
                                
                                %     if mod(num_iter, 10) == 0
                                %         [train_total_cost, train_cost_matrix] = getTotalCost(num_block_rows, num_block_columns, u, w, x_train_info, rho, lambda);
                                %         [test_total_cost, test_cost_matrix, dcostu, dcostw] = getTotalCost(num_block_rows, num_block_columns, u, w, x_test_info, rho, lambda);
                                %         [total_block_cost, block_cost_matrix] = getTotalBlockCost(num_block_rows, num_block_columns, u, w, x_test_info, lambda);
                                %      %fprintf('Initial train total cost: %e  test total cost: %e\n test total block: %e \n', train_total_cost, test_total_cost, total_block_cost);
                                %     %fprintf('Initial test total block: %e \n', total_block_cost);
                                %         fprintf('Iter: %d, Train Tcost:%s, Test Tcost:%e, TotalBlockCost: %e step: %e dcostU = %e dcostw = %e\n', ...
                                %                 num_iter, train_total_cost, test_total_cost, total_block_cost, step_size, dcostu, dcostw);
                                %         %fprintf('Iteration %d\n', num_iter);
                                %     end
      
    %%
    if mod(num_iter, 10) == 0
        rmse = getRMSE(x_info_test_full, u, w);
        fprintf('Iteration %d RMSE: %f\n', num_iter, rmse);
    end
    %%
    %{
    % Record total cost and relative error for better plotting.
    if (record_metrics == true && mod(num_iter,total_cost_inspection_granularity) == 0)
        currRecordNumber = num_iter/total_cost_inspection_granularity;
        totalCostRecord(currRecordNumber+1) = total_block_cost;
    end
    
    % Store stats
    if (record_metrics == true && mod(num_iter,d_cost_inspection_granularity) == 0)
        currRecNo = num_iter/d_cost_inspection_granularity;        
        [dCostU, dCostW] = recordDCost(dCostU, dCostW, test_d_cost_u, test_d_cost_w, t, i, j, currRecNo);
    end
    %}
   
end

[summation_block_cost_last, summation_block_cost_matrix_last] = getTotalBlockCost(num_block_rows, num_block_columns, u, w, x_test_info, lambda);
[train_total_cost, train_cost_matrix] = getTotalCost(num_block_rows, num_block_columns, u, w, x_train_info, rho, lambda);
[test_total_cost, test_cost_matrix] = getTotalCost(num_block_rows, num_block_columns, u, w, x_test_info, rho, lambda);

fprintf('Final train cost: %e \n', test_total_cost)
fprintf('Final test cost: %e \n', train_total_cost)
fprintf('Final summation of block cost: %e \n', summation_block_cost_last)
    
u_cell = u;
w_cell = w;

if (record_metrics == true)
    optionalReturn.optionalReturnAvailable = true;
    optionalReturn.dCostU = dCostU;
    optionalReturn.dCostW = dCostW;
    optionalReturn.totalBlockCost = totalCostRecord;
end

end

function [dCostU, dCostW] = recordDCost(dCostU, dCostW, d_cost_u, d_cost_w, t, i, j, currRecNo)
    if t == 1
            %This is g_upper and thus we need to update d_u
        dCostU(currRecNo,i,j) = d_cost_u;
        dCostW(currRecNo,i,j) = d_cost_w;
   else
        %fprintf('For triangulation = %d i=%d j=%d d_cost_u=%d d_cost_w=%d \n',t, i, j, d_cost_u, d_cost_w);
        %triangulation is 2 and g_lower was used
        dCostU(currRecNo, i, j-1) = d_cost_u;
        dCostW(currRecNo, i-1, j) = d_cost_w;
   end
end