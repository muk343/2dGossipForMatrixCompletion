%Updates the total cost. We are given a cost matrix and we just update the
%required entry there. Total cost is updated by subtracting the older entry
%and adding the newer entry. 
function [updated_total_cost, updated_cost_matrix] = updateTotalCost(total_cost, cost_matrix, triangulation, row_to_update, column_to_update, new_local_cost)
earlier_local_cost = cost_matrix(row_to_update, column_to_update, triangulation);
cost_matrix(row_to_update, column_to_update, triangulation) = new_local_cost;
updated_cost_matrix = cost_matrix;
updated_total_cost = total_cost - earlier_local_cost + new_local_cost;
end