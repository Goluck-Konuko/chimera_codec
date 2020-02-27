function [predOut,selectedMode] = mode_selection(left, top, original_pu, blockSize,selectedMode)
if nargin==4 %call during encoding loop
    lambda = 0.1;
    rate = 100;
    minCost = 1500000;
    predOut = zeros(blockSize);
    selectedMode = 5;
    for i=1:3
        if i==1 %perform DC prediction
            pred = dc_prediction(left, top,blockSize); %perform prediction
        elseif i==2 %perform Planar prediction
            pred = planar_prediction(left, top,blockSize);
        elseif i==3 %perform vertical prediction
            pred = angular_prediction(left, top,blockSize,i);
        else %perform horizontal prediction
            pred = angular_prediction(left, top,blockSize,i);
        end
        %calculate prediction cost
        error =  sum((original_pu(:) - double(pred(:))).^2);
        cost = error + lambda*rate;
        if cost< minCost
            selectedMode = i;
            minCost = cost; %update the R(D) cost
            predOut  = pred;
        end
    end
else %call during decoding loop
    if selectedMode==1 %perform DC prediction
        predOut = dc_prediction(left, top,blockSize); %perform prediction
    elseif selectedMode==2 %perform Planar prediction
        predOut = planar_prediction(left, top,blockSize);
    elseif selectedMode==3 %perform vertical prediction
        predOut = angular_prediction(left, top,blockSize,selectedMode);
    else %perform horizontal prediction
        predOut = angular_prediction(left, top,blockSize,selectedMode);
    end
end
end