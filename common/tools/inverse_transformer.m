function inverseTransformBlock = inverse_transformer(reconstructedBlock,tuSize)
[height, width] = size(reconstructedBlock);
inverseTransformBlock = zeros(height, width);
%scan the TU blocks and perform idct transform
for x=1:tuSize:height
    for y=1:tuSize:width
        inverseTransformBlock(x:(x+tuSize-1),y:(y+tuSize-1)) = idct2(reconstructedBlock(x:(x+tuSize-1),y:(y+tuSize-1)));
    end
end
end