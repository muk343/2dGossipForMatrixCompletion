%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Updates the matrix after performing one iteration of SGD.
@params
triangulation: (1 or 2) tells if the segment is of type g_upper(1) or
                g_lower(2).
i,j : indices of the pivot block of the segment.
u,w,x_masked: the matrices on which we are working
rho: regularizer
step_size: the step_size to use.
mask: the mask which is to be used.
%}
function [u, w] = updateMatrixMasked(x_info, mask, mask_squared, triangulation, i, j, u, w, rho, step_size, f_cost_coefficients, d_costU_coefficients, d_costW_coefficients, lambda)
     
    if triangulation == 1
        %Lets update all the Us & Ws and keep them in temp variable.
        
        %For block (i,j)
        common_gradient_component_ij = getCommonGradientComponent(u{i,j}, w{i,j}, x_info{i,j}, mask_squared{i,j});
        u_ij_new = u{i,j} - step_size*(f_cost_coefficients(i,j)*getFGradientU(w{i,j}, common_gradient_component_ij, mask{i,j}) + (d_costU_coefficients(i,j)*rho*getDGradient(u{i,j}, u{i,j+1})) + (f_cost_coefficients(i,j)*getRegularizedGradient(lambda, u{i,j})));
        w_ij_new = w{i,j} - step_size*(f_cost_coefficients(i,j)*getFGradientW(u{i,j}, common_gradient_component_ij, mask{i,j}) + (d_costW_coefficients(i,j)*rho*getDGradient(w{i,j}, w{i+1,j})) + (f_cost_coefficients(i,j)*getRegularizedGradient(lambda, w{i,j})));
        
        %For block (i+1, j)
        %According to our conventins we would take lower block for
        %dcostW coefficient.
        common_gradient_component_i_1_j = getCommonGradientComponent(u{i+1,j}, w{i+1,j}, x_info{i+1,j}, mask_squared{i+1,j});
        u_i_1_j_new = u{i+1,j} - step_size*(f_cost_coefficients(i+1,j)*getFGradientU(w{i+1,j}, common_gradient_component_i_1_j, mask{i+1, j}) + (f_cost_coefficients(i+1,j)*getRegularizedGradient(lambda, u{i+1,j})));
        w_i_1_j_new = w{i+1,j} - step_size*(f_cost_coefficients(i+1,j)*getFGradientW(u{i+1,j}, common_gradient_component_i_1_j, mask{i+1, j}) + (d_costW_coefficients(i,j)*rho*getDGradient(w{i+1,j}, w{i,j})) + (f_cost_coefficients(i+1,j)*getRegularizedGradient(lambda, w{i+1,j})));
        
        %For block (i, j+1)
        %According to our conventins we would take left most block for
        %dcostU coefficient.
        common_gradient_component_i_j_1 = getCommonGradientComponent(u{i,j+1}, w{i,j+1}, x_info{i,j+1}, mask_squared{i,j+1});
        u_i_j_1_new = u{i,j+1} - step_size*(f_cost_coefficients(i,j+1)*getFGradientU(w{i,j+1}, common_gradient_component_i_j_1, mask{i, j+1}) + (d_costU_coefficients(i,j)*rho*getDGradient(u{i,j+1}, u{i,j})) + (f_cost_coefficients(i,j+1)*getRegularizedGradient(lambda, u{i,j+1})));
        w_i_j_1_new = w{i,j+1} - step_size*(f_cost_coefficients(i,j+1)*getFGradientW(u{i,j+1}, common_gradient_component_i_j_1, mask{i, j+1}) + (f_cost_coefficients(i,j+1)*getRegularizedGradient(lambda, w{i,j+1})));
                
        %Lets assign all the new values now
        u{i,j} = u_ij_new;
        u{i+1,j} = u_i_1_j_new;
        u{i, j+1} = u_i_j_1_new;
        
        w{i,j} = w_ij_new;
        w{i+1,j} = w_i_1_j_new;
        w{i, j+1} = w_i_j_1_new;
    else
        %Lets update all the Us & Ws and keep them in temp variable.
        
        %For block (i,j)
        common_gradient_component_ij = getCommonGradientComponent(u{i,j}, w{i,j}, x_info{i,j}, mask_squared{i,j});
        u_ij_new = u{i,j} - step_size*(f_cost_coefficients(i,j)*getFGradientU(w{i,j}, common_gradient_component_ij, mask{i,j}) + (d_costU_coefficients(i,j)*rho*getDGradient(u{i,j}, u{i,j-1})) + (f_cost_coefficients(i,j)*getRegularizedGradient(lambda, u{i,j})));
        w_ij_new = w{i,j} - step_size*(f_cost_coefficients(i,j)*getFGradientW(u{i,j}, common_gradient_component_ij, mask{i,j}) + (d_costW_coefficients(i,j)*rho*getDGradient(w{i,j}, w{i-1,j})) + (f_cost_coefficients(i,j)*getRegularizedGradient(lambda, w{i,j})));
        
        %For block (i-1,j)
        common_gradient_component_i_1_j = getCommonGradientComponent(u{i-1,j}, w{i-1,j}, x_info{i-1,j}, mask_squared{i-1,j});
        u_i_1_j_new = u{i-1,j} - step_size*(f_cost_coefficients(i-1,j)*getFGradientU(w{i-1,j}, common_gradient_component_i_1_j, mask{i-1, j}) + (f_cost_coefficients(i-1,j)*getRegularizedGradient(lambda, u{i-1,j})));
        w_i_1_j_new = w{i-1,j} - step_size*(f_cost_coefficients(i-1,j)*getFGradientW(u{i-1,j}, common_gradient_component_i_1_j, mask{i-1, j}) + (d_costW_coefficients(i,j)*rho*getDGradient(w{i-1,j}, w{i,j})) + (f_cost_coefficients(i-1,j)*getRegularizedGradient(lambda, w{i-1,j})));
        
        
        common_gradient_component_i_j_1 = getCommonGradientComponent(u{i,j-1}, w{i,j-1}, x_info{i,j-1}, mask_squared{i,j-1});
        u_i_j_1_new = u{i,j-1} - step_size*(f_cost_coefficients(i,j-1)*getFGradientU(w{i,j-1}, common_gradient_component_i_j_1, mask{i, j-1}) + (d_costU_coefficients(i,j)*rho*getDGradient(u{i,j-1}, u{i,j})) + (f_cost_coefficients(i,j-1)*getRegularizedGradient(lambda, u{i,j-1})));
        w_i_j_1_new = w{i,j-1} - step_size*(f_cost_coefficients(i,j-1)*getFGradientW(u{i,j-1}, common_gradient_component_i_j_1, mask{i, j-1}) + (f_cost_coefficients(i,j-1)*getRegularizedGradient(lambda, w{i,j-1})));
        
        %Lets assign all the new values now
        u{i,j} = u_ij_new;
        u{i-1,j} = u_i_1_j_new;
        u{i, j-1} = u_i_j_1_new;
        
        w{i,j} = w_ij_new;
        w{i-1,j} = w_i_1_j_new;
        w{i, j-1} = w_i_j_1_new;
    end
end

%Helper functions

%Gives the gradient wrt U for any of the f_cost term.
function u_gradient = getFGradientU(w, common_component, mask)
    
    sparseMatStructure = mask;
    mysetsparseentries(sparseMatStructure, common_component)
    %sparseMatStructure = sparseMatStructure';
    u_gradient = 2*sparseMatrixMultiplicationLeft(sparseMatStructure, w);
end

%Gives the gradient wrt W for any of the f_cost term.
function w_gradient = getFGradientW(u, common_component, mask)
    sparseMatStructure = mask;
    mysetsparseentries(sparseMatStructure, common_component)
    %sparseMatStructure = sparseMatStructure';
    w_gradient = 2*sparseMatrixMultiplicationRight(sparseMatStructure, u')';
end

%Gives the gradient of the d terms for any of the two matrices involved.
function matUpdated = getDGradient(mat1,mat2)
    matUpdated = 2*(mat1-mat2);
end

function matrix_product = sparseMatrixMultiplicationLeft(sparse_matrix, non_sparse_matrix)
    %Have a better/efficient implementation here
    matrix_product = sparse_matrix*non_sparse_matrix;
end

function matrix_product = sparseMatrixMultiplicationRight(sparse_matrix, non_sparse_matrix)
    %Have a better/efficient implementation here
    matrix_product = non_sparse_matrix*sparse_matrix;
end

function common_gradient_component = getCommonGradientComponent(u, w, x_info, mask_squared)
    %see how to actually deal with mask_squared
    common_gradient_component =  myspmaskmult(u, w', x_info.i, x_info.j) - x_info.x;
end

function common_gradient_component = getCommonGradientComponent2(u, w, x_info, mask_squared)
    %see how to actually deal with mask_squared
    common_gradient_component =  myspmaskmult(u, w', x_info.i, x_info.j) - x_info.x;
    fprintf('common gradient')
    common_gradient_component'
    fprintf('input I:')
    x_info.i'
    fprintf('input J:')
    x_info.j'
    maskTemp = mask_squared';
    fprintf('before begeining')
    mysetsparseentries(maskTemp, common_gradient_component);
    fprintf('exploded version')
    maskTemp = maskTemp';
    maskTemp
end

function gradient = getRegularizedGradient(lambda, mat)
    gradient = lambda*mat;
end
