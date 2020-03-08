function bitstream = entropy_coder(quatizedTransformBlock,tuSize)
    [height, width] = size(quatizedTransformBlock);
    bitstream = [];
    for x=1:tuSize:height-tuSize
        for y=1:tuSize:width-tuSize
            sample = quatizedTransformBlock(x:x+tuSize-1,y:y+tuSize-1);
            %flatten the current sample
            sample = sample(:)';
            %pass sample to entropy coder
            tu_code = exp_golomb(sample);
            bitstream = [bitstream tu_code];
        end
    end

end