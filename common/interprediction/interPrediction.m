function [residualBlock, mvf] = interPrediction(currentFrame,referenceFrame,blockSize)
    %TODO pad the current  and reference frames to fit the block dimensions
    currentFrame = padding(currentFrame,blockSize);
    referenceFrame = padding(referenceFrame,blockSize); 
    %[height_p, width_p] = size(currentFrame);
    %initialize the residual block
    %residualBlock = zeros(height_p,width_p);
    %compute the motion vectors
    [mvf, MAD] = motion_estimation(currentFrame, referenceFrame,blockSize, blockSize);
    %perform motion compensation
    motionCompenstatedFrame = motion_compensation(referenceFrame, mvf);
    %calculate the block residuals
    residualBlock = currentFrame-motionCompenstatedFrame;
end