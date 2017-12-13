function [cost] = getRegularizedComponent(lambda, matrix)
    cost = 0.5*lambda*(norm(matrix, 'fro')^2);
end