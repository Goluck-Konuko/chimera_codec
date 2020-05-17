function [mvf,intra_pred_blocks,intra_pred_blocks_locations] = motion_estimation(currentFrame, referenceFrame, brow, bcol, searchStrategy, searchWindow)
%ME Motion estimation using the specified search strategy
%    MVF = ME(cur, ref, brow, bcol, searchStrategy, searchWindow);
%    searchStrategy==0 --> full search; in that case, need also a search window
%    searchStrategy==1 --> hexagon search
%    Computes a motion vector field between the current and reference
%    image, using a given block size
%    [MVF MEANCOST] = ME(...)
%    Returns the mean cost associated to the output MVF
%    Author: Goluck and Corentin
% if nargin==5
%     searchStrategy = 1; % hexagon search is set by default
%     searchWindow = 0;
% end
% if nargin==6 % Search window is not mentioned; only used for full search
%     searchWindow = 16;
% end

[rows, cols]=size(currentFrame);
totalcost = 0;
avgmvf = zeros(2);
mvf = zeros(rows,cols,2);
intra_pred_blocks = [];
intra_pred_blocks_locations = [];
% Value of tuned regularization parameter 
lambda = 0.1;                        % SHOULD IT BE AN ARGUMENT OF THE FUNCTION? --> Not yet

% Apply the desired search strategy
% Full search
if (searchStrategy==0)
    % Macroblocks scan
    cur = currentFrame;
    ref = referenceFrame;
    average_min_cost = 0; %average mincost interprediction
    block_count = 1; %number of blocks per frame
    
    for r=1:brow:rows
        for c=1:bcol:cols     
            % Macroblock from current image
            B=cur(r:r+brow-1,c:c+bcol-1);
            % Initializations
            dcolmin=0; drowmin=0;
            % Best cost initialized at the highest possible value
            costmin=brow*bcol*256*256;
            % Average of neighboring up and left vectors 
            if ((r==1)&&(c~=1))
              avgmvf(1) = mvf(r,c-bcol,1);
              avgmvf(2) = mvf(r,c-bcol,2);
            elseif ((r~=1)&&(c==1))
              avgmvf(1) = mvf(r-brow,c,1);
              avgmvf(2) = mvf(r-brow,c,2);
            elseif ((r~=1)&&(c~=1)) 
              avgmvf(1) = 0.5* (mvf(r,c-bcol,1)+mvf(r-brow,c,1));
              avgmvf(2) = 0.5* (mvf(r,c-bcol,2)+mvf(r-brow,c,2));
            end
            % loop on candidate motion vector v = (dcol,drow) 
            for dcol=-searchWindow:searchWindow
                for drow=-searchWindow:searchWindow
                    % Check: inside image
                    if ((r+drow>0)&&(r+drow+brow-1<=rows)&& ...
                            (c+dcol>0)&&(c+dcol+bcol-1<=cols))
                        % Reference macroblock
                        R=ref(r+drow:r+drow+brow-1, c+dcol:c+dcol+bcol-1);
                        SAD=sum(sum(abs(B-R)));
                        % Regularization 
                        vd(1) = drow-avgmvf(1); 
                        vd(2) = dcol-avgmvf(2);
                        vd2 = vd(1).^2 + vd(2).^2;
                        RegTerm = lambda*vd2;
                        if ((r==1)&&(c==1))
                          RegTerm = 0;
                        end
                        % Function to minimize 
                        cost = SAD+RegTerm;
                        % If current candidate is better than previous
                        % best candidate, than update the best candidate
                        if (cost<costmin) 
                            costmin=cost;
                            if cost > 1.5 * average_mincost && average_cost ~=0 
                                %perform intrapred on block and check SAD
                                target_block = currentFrame(r:brow-1,c:bcol-1);
                                left = currentFrame(r:r+brow-1, c-1);
                                top = currentFrame(r-1, c-1:c+bcol-1);
                                [pred, mode] = mode_selection(left, top, target_block, brow,'luma');
                                intraSAD = sum(sum(abs(pred-target_block)));
                                %if SAD is lower then Include predicted
                                if intraSAD < SAD
                                    intra_pred_blocks = [intra_pred_blocks pred];
                                    intra_pred_blocks_locations = [intra_pred_blocks_locations [r,c]];
                                end
                            else
                                average_mincost = (average_mincost + costmin)/block_count;
                            end
                            dcolmin=dcol;
                            drowmin=drow;
                        end
                    end
                end % 
            end % loop on candidate vectors
            % Store the best MV and the associated cost
            mvf(r:r+brow-1,c:c+bcol-1,1)=drowmin;
            mvf(r:r+brow-1,c:c+bcol-1,2)=dcolmin;
            totalcost = totalcost + costmin;
        end  
    end % loop on macroblocks
end


% Hexagon search
if (searchStrategy==1)
    % Macroblocks scan
    average_mincost = 0; %average mincost interprediction
    for r=1:brow:rows
        for c=1:bcol:cols        
            % Macroblock from current image
            B=currentFrame(r:r+brow-1,c:c+bcol-1);
            % Initializations
            dcolmin=0; drowmin=0;
            dcolmin_new=0; drowmin_new=0; 
            % Best cost initialized at the highest possible value
            costmin=brow*bcol*256*256;       
            % That's where hexagon search comes in:
            % Large hexagon pattern 
            LHP = [0 0; 0 -2; -2 -1; -2 1; 0 2; 2 1; 2 -1];      
            % Average of neighboring up and left vectors 
            if ((r==1)&&(c~=1))
              avgmvf(1) = mvf(r,c-bcol,1);
              avgmvf(2) = mvf(r,c-bcol,2);
            elseif ((r~=1)&&(c==1))
              avgmvf(1) = mvf(r-brow,c,1);
              avgmvf(2) = mvf(r-brow,c,2);
            elseif ((r~=1)&&(c~=1)) 
              avgmvf(1) = 0.5* (mvf(r,c-bcol,1)+mvf(r-brow,c,1));
              avgmvf(2) = 0.5* (mvf(r,c-bcol,2)+mvf(r-brow,c,2));
            end
            % loop on candidate motion vector v = (dcol,drow), first iteration 
            for i = 1:7
                drow = LHP(i,1);
                dcol = LHP(i,2);
                % Check: inside image
                if r+drow>0 &&r+drow+brow-1<=rows && c+dcol>0 && c+dcol+bcol-1<=cols
                     % Reference macroblock
                     R=referenceFrame(r+drow:r+drow+brow-1, c+dcol:c+dcol+bcol-1);
                     SAD=sum(sum(abs(B-R)));
                     % Regularization 
                     vd(1) = drow-avgmvf(1); 
                     vd(2) = dcol-avgmvf(2);
                     vd2 = vd(1).^2 + vd(2).^2;
                     RegTerm = lambda*vd2;
                     if ((r==1)&&(c==1))
                       RegTerm = 0;
                     end 
                     % Function to minimize 
                     cost = SAD+RegTerm;
                     % If current candidate is better than previous
                     % best candidate, than update the best candidate
                     if (cost<costmin) 
                         costmin=cost;
                         dcolmin=dcol;
                         drowmin=drow;
                     end
                end %  
            end % loop on candidate vectors
            % Iterate this step as long as central is not the optimal
            % --> In the case the best candidate is not the central one ...
            ... then consider the same search with some new candidates according to the case
            exploration_path = find(LHP(:,1)==drowmin & LHP(:,2)==dcolmin);

            while (exploration_path~=1) % i.e. central is not the best:
                if (exploration_path==2)
                    LHP = [drowmin dcolmin; drowmin dcolmin-2; drowmin-2 dcolmin-1; drowmin dcolmin; drowmin dcolmin; drowmin dcolmin; drowmin+2 dcolmin-1]; 
                elseif (exploration_path==3)
                    LHP = [drowmin dcolmin; drowmin dcolmin-2; drowmin-2 dcolmin-1; drowmin-2 dcolmin+1; drowmin dcolmin; drowmin dcolmin; drowmin dcolmin];
                elseif (exploration_path==4)
                    LHP = [drowmin dcolmin; drowmin dcolmin; drowmin-2 dcolmin-1; drowmin-2 dcolmin+1; drowmin dcolmin+2; drowmin dcolmin; drowmin dcolmin];
                elseif (exploration_path==5)
                    LHP = [drowmin dcolmin; drowmin dcolmin; drowmin dcolmin; drowmin-2 dcolmin+1; drowmin dcolmin+2; drowmin+2 dcolmin+1; drowmin dcolmin];       
                elseif (exploration_path==6)
                    LHP = [drowmin dcolmin; drowmin dcolmin; drowmin dcolmin; drowmin dcolmin; drowmin dcolmin+2; drowmin+2 dcolmin+1; drowmin+2 dcolmin-1];
                elseif (exploration_path==7)
                    LHP = [drowmin dcolmin; drowmin dcolmin-2; drowmin dcolmin; drowmin dcolmin; drowmin dcolmin; drowmin+2 dcolmin+1; drowmin+2 dcolmin-1];
                end
            % Choice is made to keep all LHPs arrays of shape 7 so that it eases the code writing       
                for i = 2:7
                    if (LHP(i,1)~=drowmin || LHP(i,2)~=dcolmin)
                        drow = LHP(i,1);
                        dcol = LHP(i,2);
                        % Check: inside image
                        if r+drow>0 && r+drow+brow-1<=rows && c+dcol>0 && c+dcol+bcol-1<=cols
                             % Reference macroblock
                             R=referenceFrame(r+drow:r+drow+brow-1, c+dcol:c+dcol+bcol-1);
                             SAD=sum(sum(abs(B-R)));
                             % Regularization 
                             vd(1) = drow-avgmvf(1); 
                             vd(2) = dcol-avgmvf(2);
                             vd2 = vd(1).^2 + vd(2).^2;
                             RegTerm = lambda*vd2;
                             if ((r==1)&&(c==1))
                               RegTerm = 0;
                             end 
                             % Function to minimize 
                             cost = SAD+RegTerm;
                             % If current candidate is better than previous
                             % best candidate, than update the best candidate
                             if (cost<costmin) 
                                 costmin=cost;
                                 dcolmin_new=dcol;
                                 drowmin_new=drow;
                             end
                        end   
                    end
                end
                if (drowmin_new~=drowmin || dcolmin_new~=dcolmin)
                    drowmin = drowmin_new;
                    dcolmin = dcolmin_new;
                    exploration_path = find(LHP(:,1)==drowmin & LHP(:,2)==dcolmin);
                else
                    exploration_path = 1; % avoids potential problems in while conditional statement
                end
            end
            % Final loop on candidate motion vector v = (dcol,drow)
            % Small hexagon pattern
            SHP = [drowmin dcolmin; drowmin dcolmin-1; drowmin-1 dcolmin; drowmin dcolmin+1; drowmin+1 dcolmin];
            for j = 2:5
                 drow = SHP(j,1);
                 dcol = SHP(j,2);

                 % Check: inside image
                 if r+drow>0 && r+drow+brow-1<=rows && c+dcol>0 && c+dcol+bcol-1<=cols
                     % Reference macroblock
                     R=referenceFrame(r+drow:r+drow+brow-1, c+dcol:c+dcol+bcol-1);
                     SAD=sum(sum(abs(B-R)));
                     % Regularization 
                     vd(1) = drow-avgmvf(1); 
                     vd(2) = dcol-avgmvf(2);
                     vd2 = vd(1).^2 + vd(2).^2;
                     RegTerm = lambda*vd2;
                     if ((r==1)&&(c==1))
                       RegTerm = 0;
                     end 
                     % Function to minimize 
                     cost = SAD+RegTerm;
                     % If current candidate is better than previous
                     % best candidate, than update the best candidate
                     if (cost<costmin)
                         costmin=cost;
                         dcolmin=dcol;
                         drowmin=drow;
                         if cost > 3 * average_mincost && average_mincost ~= 0 && c > 1 && r > 1
                             %perform intrapred on block and check SAD
                             %target_block = currentFrame(r:brow-1,c:bcol-1);
                             left = currentFrame(r:r+brow-1, c-1);
                             top = currentFrame(r-1, c-1:c+bcol-1);
                             [pred, mode] = mode_selection(left, top, B, brow,'luma');
                             intraSAD = sum(sum(abs(pred-B)));
%                              fprintf("IntraSAD: %.3f",intraSAD);
                             %if SAD is lower then include intra-predicted
                             %block
                             if intraSAD < SAD
                                 intra_pred_blocks = [intra_pred_blocks pred];
                                 intra_pred_blocks_locations = [intra_pred_blocks_locations [r,c]];
                             end
                         else
                             average_mincost = (average_mincost + costmin)/2;
                         end
                     end
                 end
            end
            % Store the best MV and the associated cost
            mvf(r:r+brow-1,c:c+bcol-1,1)=drowmin;
            mvf(r:r+brow-1,c:c+bcol-1,2)=dcolmin;
            totalcost = totalcost + costmin; %% add all cost functions for each block
        end  
    end % loop on macroblocks
end
meancost = totalcost /rows /cols;