%Returns a random block which can serve as a pivot block of a segment.
%The triangulation and the indices of the block are selected to produce a
%valid pivot block.
function [triangulation, i, j] = getRandomBlock(num_block_rows, num_blocks_column)
    %validations about both of these to be >1 to be added.
    i = randi(num_block_rows - 1);
    j = randi(num_blocks_column - 1);
    triangulation = randi(2);
    
    % triangulation 1 means upper triangulation and 2 means lower triangulation
    if triangulation == 2
        %the case where we have got triangulation as
        %lower. Since now the indices can just go from 2 to num_blocks
        %we would just add 1 to whatever we got.
        i = i+1;
        j = j+1;
    end
    
end