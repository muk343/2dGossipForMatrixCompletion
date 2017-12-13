%{
Calculates the total cost of the current segment. For gossip in both u's and w's
 the segment consists of 3 different blocks. The total cost of the segment
 is given by two type of costs. The 'f_cost' which tells the distance
 between x and u*w' and the d_cost which captures the consensus between
 adjacent u's and w's. 

@Return
We are returning these three costs:
1. Total cost of the whole segment. 
2. d_cost between the adjacent u's.
3. d_cost between the adjacent w's. 
%}
function [total_cost, d_cost_u, d_cost_w] = getCost(triangulation, i, j, u, w, x_test_info, rho, lambda)

% The three f_costs. 
cost_of_individual_blocks = getBlockCosts(triangulation, i, j, u, w, x_test_info);

% d_costs (capturing the consensus). 
[d_cost_u, d_cost_w] = getAdjacentDiffCost(triangulation,i,j,u,w);
regularizedCost = total_regularized_cost_segment(triangulation,i,j,u,w,lambda);
cost_of_adjacent_difference = rho*(d_cost_u + d_cost_w);

% total cost is summation of these two types of costs. 
total_cost = cost_of_individual_blocks + regularizedCost; % + cost_of_adjacent_difference;
end

%{
   Our segments can be of two types. We call them g_upper and g_lower.
   Corresponding to these different configuration, different blocks are
   taken to calculate the d_cost. 
%}
function [d_cost_u, d_cost_w] = getAdjacentDiffCost(triangulation,i,j,u,w)
   
%Triangulation is 1, that means g_upper type of segment. 
if triangulation == 1
    u_left  = u{i,j};
    u_right = u{i,j+1};
    w_upper = w{i,j};
    w_lower = w{i+1,j};
else
    %Triangulation is 2, that means g_lower type of segment. 
    u_left  = u{i, j-1};
    u_right = u{i,j};
    w_upper = w{i-1, j};
    w_lower = w{i, j};
end

%Multiplying rho for regularization. 
d_cost_u = d_cost(u_left, u_right);
d_cost_w = d_cost(w_upper, w_lower);
end

%Calculating the 'f_costs' for each of the three blocks in the segment. 
function total_cost = getBlockCosts(triangulation,i,j,u,w, x_test_info)
%triangulation = 1 means g_upper type of segment. 
if triangulation == 1
    total_cost = getFcost(u{i,j}, w{i,j}, x_test_info{i,j}) + getFcost(u{i,j+1}, w{i,j+1}, x_test_info{i,j+1}) + getFcost(u{i+1,j}, w{i+1,j}, x_test_info{i+1,j});
else
    %triangulation is 2, that means g_lower
    total_cost = getFcost(u{i,j}, w{i,j}, x_test_info{i,j}) + getFcost(u{i,j-1}, w{i,j-1}, x_test_info{i,j-1}) + getFcost(u{i-1,j}, w{i-1,j}, x_test_info{i-1,j});
end
end

function cost = total_regularized_cost_segment(triangulation,i,j,u,w,lambda)

if triangulation == 1
    cost = getRegularizedComponent(lambda, u{i,j}) + getRegularizedComponent(lambda, u{i,j+1}) + getRegularizedComponent(lambda, u{i+1,j}) + ...
           getRegularizedComponent(lambda, w{i,j}) + getRegularizedComponent(lambda, w{i,j+1}) + getRegularizedComponent(lambda, w{i+1,j});
else
    cost = getRegularizedComponent(lambda, u{i,j}) + getRegularizedComponent(lambda, u{i,j-1}) + getRegularizedComponent(lambda, u{i-1,j}) + ...
           getRegularizedComponent(lambda, w{i,j}) + getRegularizedComponent(lambda, w{i,j-1}) + getRegularizedComponent(lambda, w{i-1,j});
end
end

%Calculating d_cost
function cost = d_cost(mat1, mat2)
mat_diff = mat1-mat2;
frobenius_norm = norm(mat_diff, 'fro');
cost = frobenius_norm^2;
end