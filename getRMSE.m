function rmse = getRMSE(x_test_info_full, u, w)

globalU = getGlobalU(u);
globalW = getGlobalW(w);

error = x_test_info_full.x - myspmaskmult(globalU, globalW', x_test_info_full.i, x_test_info_full.j);
frobenius_norm = norm(error, 'fro');
cost = (frobenius_norm^2)/x_test_info_full.num_entries;

rmse = sqrt(cost);
end