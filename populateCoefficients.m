%{
    We have seen that owning to the structure of our basic decomposed
    block, a few blocks have a bit higher probably of being selected and
    being updated that other. To eliminate this, we are normalizing by the
    probablity of the block being selected. See the associated READ.me for
    better understanding. 
%}
function [f_cost_coefficients, d_costU_coefficients, d_costW_coefficients] = populateCoefficients(num_block_rows, num_block_columns)

f_cost_coefficients = populate_f_coefficients(num_block_rows, num_block_columns);
d_costU_coefficients = populate_d_coefficientU(num_block_rows, num_block_columns);
d_costW_coefficients = populate_d_coefficientW(num_block_rows, num_block_columns);
end

function [f_cost_coefficients] = populate_f_coefficients(num_block_rows, num_block_columns)
f_cost_coefficients(1:num_block_rows, 1:num_block_columns) = 1/6;
f_cost_coefficients(1,1) = 1;
f_cost_coefficients(num_block_rows, num_block_columns) = 1;
f_cost_coefficients(1,num_block_columns) = 1/2;
f_cost_coefficients(num_block_rows,1) = 1/2;

for i = 2:num_block_columns-1
    f_cost_coefficients(1,i) = 1/3;
    f_cost_coefficients(num_block_rows,i) = 1/3;
end

for i = 2:num_block_rows-1
    f_cost_coefficients(i,1) = 1/3;
    f_cost_coefficients(i,num_block_columns) = 1/3;
end

end

function [d_costU_coefficients] = populate_d_coefficientU(num_block_rows, num_block_columns)
d_costU_coefficients(1:num_block_rows, 1:num_block_columns) = 1/2;

for i = 1:num_block_columns
    d_costU_coefficients(1, i) = 1;
    d_costU_coefficients(num_block_rows, i) = 1;
end
end

function [d_costW_coefficients] = populate_d_coefficientW(num_block_rows, num_block_columns)
d_costW_coefficients(1:num_block_rows, 1:num_block_columns) = 1/2;

for i = 1:num_block_rows
    d_costW_coefficients(i, 1) = 1;
    d_costW_coefficients(i, num_block_columns) = 1;
end
end