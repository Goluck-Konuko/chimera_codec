function decodedInterFrame = inter_frame_decoder(inverseTransformBlock,referenceFrame, mvf, blockSize)
    %motion compenstation
    motionCompenstatedFrame = motion_compensation(referenceFrame,mvf);
    %add residuals
    decodedInterFrame = motionCompenstatedFrame + inverseTransformBlock;
end