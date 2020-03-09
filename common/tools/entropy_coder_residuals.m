function [nalu_frame] = entropy_coder_residuals(inputBlock,tuSize,colorspace)
if strcmp(colorspace,'y')
    [height,width] = size(inputBlock);
    nalu_frame = [];
    %scan the Residual block and encode each TU
    for x=1:tuSize:height-tuSize
        for y=1:tuSize:width-tuSize
            target_tu = inputBlock(x:x+tuSize-1,y:y+tuSize-1);
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
else
   %Main start code ==> 
    [height,width] = size(inputBlock(:,:,1));
    %flatten the input block into a raster scan array
     %initialize the bitstring for current NAL
    %run_length encoding of the input sequence
    nalu_frame = [];
    %the input block should have 3 channels 
    for i=1:3
        in_channel = inputBlock(:,:,i); %one of the channel residuals
        %scan the Residual block and encode each TU
        nalu_channel = [];
        for x=1:tuSize:height-tuSize
            for y=1:tuSize:width-tuSize
                target_tu = in_channel(x:x+tuSize-1,y:y+tuSize-1);
                %raster scan
                target_tu = target_tu';
                %flatten
                sequence = target_tu(:)';
                [values, runs] = run_length_encoder(sequence);
                %exp_golomb code
                values_bits = exp_golomb(values);
                runs_bits = exp_golomb(runs);
                nalu_channel = [nalu_channel values_bits runs_bits];
            end
        end
        nalu_frame = [nalu_frame nalu_channel];
    end 
end
end