function [codeword] = exp_golomb(Values)
% Exp_golomb coding for each element in a list of values
% Goluck and Corentin

codeword = '';

% Determines the maximum codeword length to be considered (not necessary)
% A = {ceil(log2(M+1)),ceil(log2(-(m-1)))};
% length_max = max(A);

for j=1:length(Values)
    %length_value = ceil( log2(  (2*(Values(j)>0)-1)   *(Values(j) + (2*(Values(j)>0)-1)  ) ) );
    length_value = length(dec2bin(abs(Values(j))));
    % Beginning of the codeword --> only zeros 
    if Values(j)==0
        codeword = strcat(codeword, '1');
    else
        for i=1:length_value
            codeword = strcat(codeword, '0');
        end

%     % Then always a 1
%   codeword = strcat(codeword, '1');

    % Finally, 
        if (Values(j)<0)
            a = dec2bin(-2*Values(j)+1);
        elseif (Values(j)>=0)
            a = dec2bin(2*Values(j));         
        end
        codeword = strcat(codeword, a);
    end
end


        
        



