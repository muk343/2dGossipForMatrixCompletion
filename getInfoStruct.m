function [infoStruct] = getInfoStruct(x_test)
%     %{Let's fill xInfo too...
%         temp_i = [];
%         temp_j = [];
%         infoStruct.x = [];
%         
%         [m_local, n_local] = size(x_test);
%         for k = 1:m_local
%             for l = 1:n_local
%                 if (x_test(k,l) ~= 0)
%                     temp_i(end+1) = k;
%                     temp_j(end+1) = l;
%                     infoStruct.x(end+1) = x_test(k,l);
%                 end
%             end
%         end
      
        [i,j,x_temp] = find(x_test);
        
        infoStruct.i = uint32(i);
        infoStruct.j = uint32(j);
        infoStruct.x = x_temp;
end
