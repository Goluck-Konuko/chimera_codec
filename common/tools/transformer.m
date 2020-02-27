function transformBlock = transformer(residualBlock,tuSize)
[height, width] = size(residualBlock);
transformBlock = zeros(height, width);
%scan the TU blocks and perform dct transform
for x=1:tuSize:height
    for y=1:tuSize:width
        transformBlock(x:(x+tuSize-1),y:(y+tuSize-1)) = dct2(residualBlock(x:(x+tuSize-1),y:(y+tuSize-1)));
    end
end
end