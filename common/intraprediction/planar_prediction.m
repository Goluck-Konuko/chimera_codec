function pred_out = planar_prediction(left, top, blockSize)
    h_values = zeros(blockSize);
    v_values = zeros(blockSize);
    pred_out = zeros(blockSize);
    for x=1:blockSize
        for y=1:blockSize
            v_values(x,y) = (blockSize-1-y)*top(x+1) + (y+1)*left(blockSize);
        end
    end
    for x=1:blockSize
        for y=1:blockSize
            h_values(x,y) = (blockSize-1-x)*left(y) + (x+1)*top(blockSize+1);
        end
    end
    for i=1:blockSize
        for j=1:blockSize
            pred_out(i,j) = (v_values(i,j)+h_values(i,j)+ blockSize)/(2*blockSize);
        end
    end
%     pred_out = pixel_range(pred_out);
end