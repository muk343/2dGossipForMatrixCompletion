%Gives the total cost of the matrix. This cost comprises of all the
%segments g_upper and g_lower. Which in turn comprise of f_costs and
%d_costs. Note: that in this initial version, few f_costs and d_costs may
%be counted more than onece. 
%In future we can have appropriate factors to compensate for this double
%counting. 
%{
   Total cost is expressed as sum of different segments (g_lower and
   g_upper). This method calculates totalCost but calculating all the 
   individul costs. 

   In essence, this method can be used to calculate cost initially. After
   than just updating the appropriate value in cost matrix, one would be
   able to update the total cost, without computing the whole thing again. 
 
%}

%lets fill Gupper only
%The pivot block of a segment is defined as the top left most block for
%g_upper and bottom right most block for g_lower. 
function [total_cost,cost_matrix,dcostU, dcostW] = getTotalCost(num_block_rows, num_block_columns, u, w, x_test_info, rho, lambda)

total_cost = 0;

%The third dimension is for considering triangulation. 
cost_matrix = zeros(num_block_rows, num_block_columns, 2);

%TODO: add checks for num_block_rows and num_block_columns > 2

%The pivot block for g_upper can go from 1:num_block_rows - 1 in terms of rows and 
%from 1:num_block_cols -1 in terms of columns. 
%lets fill g_upper first.
triangulation = 1;
for  curr_row = 1:num_block_rows-1
    for curr_column = 1:num_block_columns-1
        
        %We are storing only what getCost returns as "TotalCost". In the
        %current implementation of getCost, this value is f_cost comprising
        %of the three blocks which form our structure for gossip in GUpper.
        [cost_matrix(curr_row, curr_column, triangulation), dcostU, dcostW] = getCost(triangulation, curr_row, curr_column, u, w, x_test_info, rho, lambda);
        total_cost = total_cost + cost_matrix(curr_row, curr_column, triangulation);
    end
end

%The pivot block for g_lower can go from 2:num_block_rows in terms of rows and 
%from 2:num_block_cols in terms of columns. 
%lets fill g_lower now
triangulation = 2;
for  curr_row = 2:num_block_rows
    for curr_column = 2:num_block_columns
        [cost_matrix(curr_row, curr_column, triangulation), dcostU, dcostW] = getCost(triangulation, curr_row, curr_column, u, w, x_test_info, rho, lambda);
        total_cost = total_cost + cost_matrix(curr_row, curr_column, triangulation);
    end
end