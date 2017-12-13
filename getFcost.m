%Calculating the f_cost
function cost = getFcost(u, w, x_info)
mat_diff = x_info.x - myspmaskmult(u, w', x_info.i, x_info.j);
frobenius_norm = norm(mat_diff, 'fro');
cost = frobenius_norm^2;
end