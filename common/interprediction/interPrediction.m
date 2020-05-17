function [residualBlock, mvf] = interPrediction(currentFrame,referenceFrame,blockSize,searchStrategy,searchWindow, intraMode)
    %TODO pad the current  and reference frames to fit the block dimensions
    currentFrame = padding(currentFrame,blockSize);
    referenceFrame = padding(referenceFrame,blockSize);     
    %compute the motion vectors
    [mvf, intra_pred_blocks, intra_pred_blocks_locations] = motion_estimation(currentFrame, referenceFrame,blockSize, blockSize,searchStrategy,searchWindow);
    %perform motion compensation
    motionCompenstatedFrame = motion_compensation(referenceFrame, mvf);
    %substitute the intra pred block
    if length(intra_pred_blocks_locations)>0 && intraMode == 1
        for i=1:2:length(intra_pred_blocks_locations)
            r = intra_pred_blocks_locations(i);
            c = intra_pred_blocks_locations(i+1);
            motionCompenstatedFrame(r:r+blockSize-1,c:c+blockSize-1) = intra_pred_blocks(i);
        end
    end
    %calculate the block residuals
    residualBlock = currentFrame-motionCompenstatedFrame;
end