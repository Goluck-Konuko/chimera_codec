function [predOut,selectedMode] = mode_selection(left, top, original_pu, blockSize,class,selectedMode)
if nargin==5 %call during encoding loop
    lambda = 0.1;
    rate = 10000;
    minCost = 15000000;
    predOut = zeros(blockSize);
    selectedMode = 0;
    if strcmp(class,'luma')
        for i=1:11
            if i==1 %perform DC prediction
                pred = dc_prediction(left, top,blockSize); %perform prediction
            elseif i==2 %perform Planar prediction
                pred = planar_prediction(left, top,blockSize);
                %         elseif i==3 %perform vertical prediction
                %             pred = angular_prediction(left, top,blockSize,i-1);
            else %perform angular prediction
                pred = angular_prediction(left, top,blockSize,i-1);
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
    else
        %perform prediction for the chroma samples
        %only 4 modes allowed: DC, Planar, Horizontal, Vertical
        for i=1:4
            if i==1 %perform DC prediction
                pred = dc_prediction(left, top,blockSize); %perform prediction
            elseif i==2 %perform Planar prediction
                pred = planar_prediction(left, top,blockSize);
            elseif i==3 %perform horizontal prediction
                pred = angular_prediction(left, top,blockSize,10);
            else %perform vertical prediction
                pred = angular_prediction(left, top,blockSize,26);
            end
            %calculate prediction cost
            error =  sum((original_pu(:) - double(pred(:))).^2);
            cost = error + lambda*rate;
            if cost< minCost
                if i==3
                    selectedMode = 10;
                elseif i==4
                    selectedMode = 26;
                else
                    selectedMode = i;
                end
                minCost = cost; %update the R(D) cost
                predOut  = pred;
            end
        end
    end
    
else %call during decoding loop
    if selectedMode==1 %perform DC prediction
        predOut = dc_prediction(left, top,blockSize); %perform prediction
    elseif selectedMode==2 %perform Planar prediction
        predOut = planar_prediction(left, top,blockSize);
    else %perform angular prediction
        predOut = angular_prediction(left, top,blockSize,selectedMode);
    end
end
end