function [left, top] = filter_reference_array(left, top,blockSize)
    %filter top reference
    %first element is filter using both reference arrays
    top = [top 0]; %add a zero padding at the end
    left = flip(left); %reverse the order of elements in the left reference and filter
    left = [0;left;top(1)];%add the top left element found in the top reference and a padding on the bottom
    if numel(left) == blockSize+2
        for i=2:blockSize+1
            left(i) = int16((left(i-1)+ 2*left(i)+ left(i+1))/4);
        end
        left = left(2:blockSize+1); %remove paddings
    else
        for i=2:2*blockSize+1
            left(i) = int16((left(i-1)+ 2*left(i)+ left(i+1))/4);
        end
        left = left(2:2*blockSize+1); %remove paddings
    end
    top(1) = int16((left(1) + 2*top(1) + top(2))/4);
    for i=2:2*blockSize+1
        top(i) = int16((top(i-1)+2*top(i)+top(i+1))/4);
    end
    top = top(1: 2*blockSize+1); % remove right padding on the top reference
    left = flip(left); %flip back the left reference array
end