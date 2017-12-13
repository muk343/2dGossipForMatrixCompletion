%Updates the total F_cost. We are given a cost matrix and we just update the
%required entry there. Total cost is updated by subtracting the older entry
%and adding the newer entry. 
function [updated_total_f_cost, updated_f_cost_matrix] = getAndUpdateFCost(total_f_cost, f_cost_matrix, triangulation ,i, j, u, w, x_info, lambda)

if triangulation == 1
    total_f_cost = total_f_cost - (f_cost_matrix(i,j) + f_cost_matrix(i,j+1) + f_cost_matrix(i+1,j));
    f_cost_matrix(i,j) = getFcost(u{i,j}, w{i,j}, x_info{i,j}) + getRegularizedComponent(lambda, u{i,j}) + getRegularizedComponent(lambda, w{i,j});
    f_cost_matrix(i,j+1) = getFcost(u{i,j+1}, w{i,j+1}, x_info{i,j+1}) + getRegularizedComponent(lambda, u{i,j+1}) + getRegularizedComponent(lambda, w{i,j+1});
    f_cost_matrix(i+1,j) = getFcost(u{i+1,j}, w{i+1,j}, x_info{i+1,j}) + getRegularizedComponent(lambda, u{i+1,j}) + getRegularizedComponent(lambda, w{i+1,j});
    total_f_cost = total_f_cost + (f_cost_matrix(i,j) + f_cost_matrix(i,j+1) + f_cost_matrix(i+1,j));
else
    total_f_cost = total_f_cost - (f_cost_matrix(i,j) + f_cost_matrix(i,j-1) + f_cost_matrix(i-1,j));
    %triangulation is 2, that means g_lower
    f_cost_matrix(i,j) = getFcost(u{i,j}, w{i,j}, x_info{i,j}) + getRegularizedComponent(lambda, u{i,j}) + getRegularizedComponent(lambda, w{i,j}) ;
    f_cost_matrix(i,j-1) = getFcost(u{i,j-1}, w{i,j-1}, x_info{i,j-1}) + getRegularizedComponent(lambda, u{i,j-1}) + getRegularizedComponent(lambda, w{i,j-1});
    f_cost_matrix(i-1,j) = getFcost(u{i-1,j}, w{i-1,j}, x_info{i-1,j}) + getRegularizedComponent(lambda, u{i-1,j}) + getRegularizedComponent(lambda, w{i-1,j});
    total_f_cost = total_f_cost + (f_cost_matrix(i,j) + f_cost_matrix(i,j-1) + f_cost_matrix(i-1,j));
end

updated_total_f_cost = total_f_cost;
updated_f_cost_matrix = f_cost_matrix;
end