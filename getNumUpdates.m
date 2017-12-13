function updated_num_times_updated = getNumUpdates(num_times_updated, i,j,triangulation)
    %Triangulation is 1, that means g_upper type of segment. 
if triangulation == 1
    num_times_updated(i,j)  = num_times_updated(i,j) + 1;
    num_times_updated(i,j+1)  = num_times_updated(i,j+1) + 1;
    num_times_updated(i+1,j)  = num_times_updated(i+1,j) + 1;
else
    %Triangulation is 2, that means g_lower type of segment. 
    num_times_updated(i,j)  = num_times_updated(i,j) + 1;
    num_times_updated(i,j-1)  = num_times_updated(i,j-1) + 1;
    num_times_updated(i-1,j)  = num_times_updated(i-1,j) + 1;
end

updated_num_times_updated = num_times_updated;

end