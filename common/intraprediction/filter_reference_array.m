function [left, top] = filter_reference_array(left_ref, top_ref,blockSize)
    %filter top reference
    %first element is filter using both reference arrays
    left_ref = flip(left_ref)'; %reverse the order of elements in the left reference and filter
    ref_array = [0 left_ref top_ref 0];
    filter_array = [];
    for i=2:length(ref_array)-1
        filter_array(i) = int16((ref_array(i-1)+ 2*ref_array(i)+ ref_array(i+1))/4);
    end
    left = flip(filter_array(2:blockSize+1))';
    top = filter_array(blockSize+1:2*blockSize+1);
end