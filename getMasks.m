function [ mask_train, mask_test ] = getMasks( num_row, num_col, training_sparsity_percentage, test_sparsity_percentage )

%Add some basic checks like num_row > 0 and num_col > 0
%Replace this implementation with more optimized ones in the future. 
mask_train = zeros(num_row, num_col);
num_total_elements = num_row*num_col;

%check that training_sparsity_percentage (and also testing) is indeed in (0,1)
num_non_zero_elements = training_sparsity_percentage*num_total_elements;
mask_train(randperm(num_total_elements, num_non_zero_elements)) = 1.0;

%Now generate testing mask. 
%This only has approximate ratio as test_sparsiy_percentage and 
%not exact percentage. 
mask_train_complementary = ones(num_row, num_col) - mask_train;
num_zero_elements_test = (1-test_sparsity_percentage)*num_total_elements;
mask_train_complementary(randperm(num_total_elements, num_zero_elements_test)) = 0;
mask_test = mask_train_complementary;

mask_test = sparse(mask_test);
mask_train = sparse(mask_train);
%just check for the mask_test matrix to be non-zero 
end

