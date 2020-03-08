function [nalu] = entropy_coder(inputBlock,currentNAL)
    %Main start code ==> 
    %flatten the input block into a raster scan array
    in_sequence = inputBlock';
    sequence = in_sequence(:)';
    %run_length encoding of the input sequence
    [values, runs] = run_length_encoder(sequence);
    
    %exp_golomb code
    values_bits = exp_golomb(values);
    runs_bits = exp_golomb(runs);
    nalu = strcat('0x000001b6', values_bits ,'0x000001b6',runs_bits);
end