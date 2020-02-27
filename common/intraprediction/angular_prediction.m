function pred_out = angular_prediction(left, top, blockSize, mode)
    [left_1, top_1] = interpolation(left,top, blockSize);
    [left_2, top_2] = filter_reference_array(left_1, top_1, blockSize);
    pred_out = zeros(blockSize);
    if mode==3%pure vertical
        for x=1:blockSize
            for y=1:blockSize
                pred_out(x,y) = top_2(y+1);
            end
        end
    else %pure horizontal
        for x=1:blockSize
            for y=1:blockSize
                pred_out(x,y)= left_2(y);
            end
        end
    end
end