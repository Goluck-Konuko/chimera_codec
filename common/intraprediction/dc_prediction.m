function pred_out = dc_prediction(left, top, blockSize)
    pred_out = zeros(blockSize, blockSize);
    pred_out_dc = (1/(2*blockSize))*(sum(left)+sum(top(2:end))+blockSize);
    pred_out(:) = int16(pred_out_dc);
end
