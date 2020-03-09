function [nalu_frame] = entropy_coder_modes(inputBlock,colorspace)
if strcmp(colorspace,'y')  
    nalu_frame = []; 
    %raster scan
    target_tu = inputBlock';
    %flatten
    sequence = target_tu(:)';
    [values, runs] = run_length_encoder(sequence);
    %exp_golomb code
    values_bits = exp_golomb(values);
    runs_bits = exp_golomb(runs);
    nalu_frame = [nalu_frame values_bits runs_bits];   
else
   %Main start code ==>     
    %run_length encoding of the input sequence
    nalu_frame = [];
    %the input block should have 3 channels 
    for i=1:3
        target_tu = inputBlock(:,:,i)'; %one of the channel residuals
        %raster scan
        target_tu = target_tu';
        %flatten
        sequence = target_tu(:)';
        [values, runs] = run_length_encoder(sequence);
        %exp_golomb code
        values_bits = exp_golomb(values);
        runs_bits = exp_golomb(runs);
        nalu_frame = [nalu_frame values_bits runs_bits];
    end
end
end