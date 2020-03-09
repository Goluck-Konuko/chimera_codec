function [nalu_frame] = entropy_coder_mvfs(inputBlock,blockSize)
nalu_frame = [];
[height, width] = size(inputBlock(:,:,1));
for i=1:2
    %raster scan
    mvf = inputBlock(:,:,i);
    nalu_mvf = [];
    %scan for TUs within the motion vector space
    for x=1:blockSize:height-blockSize
        for y=1:blockSize:width-blockSize
            target_tu = mvf(x:x+blockSize-1,y:y+blockSize-1)';
            %flatten
            sequence = target_tu(:)';
            [values, runs] = run_length_encoder(sequence);
            %exp_golomb code
            values_bits = exp_golomb(values);
            runs_bits = exp_golomb(runs);
            nalu_mvf = [nalu_mvf values_bits runs_bits];
        end
    end
    nalu_frame = [nalu_frame nalu_mvf];
end
end