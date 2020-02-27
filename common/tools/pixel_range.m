function scaledFrame = pixel_range(currentFrame)
    max_val = max(currentFrame,[],'all');
    min_val = min(currentFrame,[],'all');
    scaledFrame = ((currentFrame-min_val)/(max_val-min_val))*255 ;
end