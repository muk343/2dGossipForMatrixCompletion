function [u_left, u_right, w_upper, w_lower] = getBlocks(triangulation, u, w, i, j)
if triangulation == 1
    u_left  = u{i,j};
    u_right = u{i,j+1};
    w_upper = w{i,j};
    w_lower = w{i+1,j};
else
    %triangulation is 2, that means lower
    u_left  = u{i, j-1};
    u_right = u{i,j};
    w_upper = w{i-1, j};
    w_lower = w{i, j};
end
end 