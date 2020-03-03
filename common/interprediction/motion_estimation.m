function [mvf,MAD] = motion_estimation(currentFrame, referenceFrame, brow, bcol)
%ME Motion estimation using hexagon search 
%    MVF = ME(cur, ref, brow, bcol, search);
%    Computes a motion vector field between the current and reference
%    image, using a given block size and search area
%    [MVF MSE] = ME(...)
%    Returns the MAD associated to the output MVF
%    Author: Goluck and Corentin
[rows, cols]=size(currentFrame);
totalSAD = 0;
alpha= 0.01;
rate = 10000;
% Macroblocks scan
for r=1:brow:rows
    for c=1:bcol:cols        
        % Macroblock from current image
        B=currentFrame(r:r+brow-1,c:c+bcol-1);
        % Initializations
        dcolmin=0; drowmin=0;
        dcolmin_new=0; drowmin_new=0; 
        % Best cost initialized at the highest possible value
        SADmin=brow*bcol*256*256; 
%         costMin = 1500000;
        % That's where hexagon search comes in:
        % Large hexagon pattern 
        LHP = [0 0; 0 -2; -2 -1; -2 1; 0 2; 2 1; 2 -1];      
 
        % loop on candidate motion vector v = (dcol,drow), first iteration 
        for i = 1:7
            drow = LHP(i,1);
            dcol = LHP(i,2);
            % Check: inside image
            if r+drow>0 &&r+drow+brow-1<=rows && c+dcol>0 && c+dcol+bcol-1<=cols
                 % Reference macroblock
                 R=referenceFrame(r+drow:r+drow+brow-1, c+dcol:c+dcol+bcol-1);
                 SAD=sum(sum(abs(B-R)));
                 MSE = ((abs(B-R))^2)/(rows*cols);
                 cost = MSE + alpha*rate;
                 % If current candidate is better than previous
                 % best candidate, than update the best candidate
%                  if (SAD<costMin) 
%                      costMin=cost;
%                      dcolmin=dcol;
%                      drowmin=drow;
%                  end
                  if (SAD<SADmin)
                       SADmin=SAD;
                       dcolmin_new=dcol;
                       drowmin_new=drow;
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
                         MSE = ((abs(B-R))^2)/(rows*cols);
                         cost = MSE + alpha*rate;
                         % If current candidate is better than previous
                         % best candidate, than update the best candidate
%                          if (cost<costMin)
%                              costMin=cost;
%                              dcolmin=dcol;
%                              drowmin=drow;
%                          end
                         if (SAD<SADmin) 
                             SADmin=SAD;
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
                 MSE = ((abs(B-R))^2)/(rows*cols);
                 cost = MSE + alpha*rate;
                 % If current candidate is better than previous
                 % best candidate, than update the best candidate
%                  if (cost<costMin) 
%                      costMin=cost;
%                      dcolmin=dcol;
%                      drowmin=drow;
%                  end
                 if (SAD<SADmin)
                     SADmin=SAD;
                     dcolmin=dcol;
                     drowmin=drow;
                 end
             end
        end
        % Store the best MV and the associated cost
        mvf(r:r+brow-1,c:c+bcol-1,1)=drowmin;
        mvf(r:r+brow-1,c:c+bcol-1,2)=dcolmin;
        totalSAD = totalSAD + SADmin;
    end  
end % loop on macroblocks
MAD = totalSAD /rows /cols;