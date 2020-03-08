function [codeword] = exp_golomb(Values)
% Exp_golomb coding for each element in a list of values
% Goluck and Corentin

codeword = '';

% Determines the maximum codeword length to be considered (not necessary)
% A = {ceil(log2(M+1)),ceil(log2(-(m-1)))};
% length_max = max(A);

for j=1:length(Values)
    length_value = ceil( log2(  (2*(Values(j)>0)-1)   *(Values(j) + (2*(Values(j)>0)-1)  ) ) );
    % Beginning of the codeword --> only zeros 
    for i=1:length_value
        codeword = strcat(codeword, '0');
    end
    % Then always a 1
    codeword = strcat(codeword, '1');
    a = de2bi(2*abs(Values(j)));
    for i=(numel(a)-1):-1:1
        codeword = strcat(codeword, int2str(a(i)) );
    end
    if (Values(j)<0)
        last_bit = length(codeword);
        codeword(last_bit) = '1';
    end
end


        
        



