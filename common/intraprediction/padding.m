function paddedFrame = padding(frame, blockSize)
[height, width]  = size(frame);
if mod(width,blockSize)>0 && mod(height,blockSize)>0
    paddingHorizontal = blockSize-mod(width,blockSize);
    pad_h = zeros(height,paddingHorizontal);%horizontal padding block
    frame = cat(2,frame,pad_h);
    paddingVertical = blockSize-mod(height,blockSize);
    pad_v = zeros(paddingVertical,width+paddingHorizontal); %vertical padding block
    frame = cat(1,frame,pad_v);
    paddedFrame = frame;
elseif mod(width,blockSize)>0
    paddingHorizontal = blockSize-mod(width,blockSize);
    pad_h = zeros(height,paddingHorizontal);
    frame = cat(2,frame,pad_h);
    paddedFrame = frame;
elseif mod(height,blockSize)>0
    paddingVertical = blockSize-mod(height,blockSize);
    pad_v = zeros(paddingVertical,width);
    frame = cat(1,frame,pad_v);
    paddedFrame = frame;
else
    paddedFrame = frame;
end
end