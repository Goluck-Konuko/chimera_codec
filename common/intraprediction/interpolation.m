function [left, top] = interpolation(left, top, blockSize)
    extension_left = zeros(blockSize,1);
    extension_top = zeros(1,blockSize);
    if blockSize>4 %for larger blocks, extend both references to allow for 33 prediction modes
        if numel(top)==blockSize+1 && numel(left)==blockSize %only top and left references are available
            %extrapolate both references
            left = [left;extension_left];
            top = [top extension_top];
            left(blockSize+1: 2*blockSize) = left(blockSize);
            top(blockSize+2:2*blockSize+1) = top(blockSize+1);
        elseif numel(top)==2*blockSize+1 && numel(left)==blockSize %top and top-right references are available
            left = [left;extension_left];
            left(blockSize+1: 2*blockSize) = left(blockSize); %only the left reference is extended
        else
            printf('Invalid reference samples');
        end
    else %for small blocks, extend only the top reference to allow for 9 prediction modes
        if numel(top)== blockSize+1
            top = [top extension_top];
            top(blockSize+2:2*blockSize+1) = top(blockSize+1);
        end
    end
end