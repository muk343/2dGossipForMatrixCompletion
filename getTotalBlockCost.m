%Just gives the f_cost corresponding to all the blocks. 
%total_f_cost is just the summation of f_cost of all the individual blocks
%specified in f_cost_matrix
function [total_block_cost, block_cost_matrix] = getTotalBlockCost(num_block_rows, num_block_columns, u, w, x_test_info, lambda)

total_block_cost = 0;

%The third dimension is for considering triangulation. 
block_cost_matrix = zeros(num_block_rows, num_block_columns);

for  curr_row = 1:num_block_rows
    for curr_column = 1:num_block_columns
        block_cost_matrix(curr_row, curr_column) = getFcost(u{curr_row, curr_column}, w{curr_row, curr_column}, x_test_info{curr_row, curr_column})...  
                                                   + getRegularizedComponent(lambda, u{curr_row, curr_column})...
                                                   + getRegularizedComponent(lambda, w{curr_row, curr_column});
        
        total_block_cost = total_block_cost + block_cost_matrix(curr_row, curr_column);
    end
end

end

