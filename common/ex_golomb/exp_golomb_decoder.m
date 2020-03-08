function decodedSequence = exp_golomb_decoder(Sequence)
% Decoding "exp_golombed" Sequence to retrieve the initial number sequence
% Goluck and Corentin
parsed_stream_index = 1;
decodedSequence = [];
% Number of elements to the left of the given desired '1'
number_left_zeros = 0;
while (parsed_stream_index <= length(Sequence))
    if (Sequence(parsed_stream_index)=='1')
        % Distinction btw negative and positive integers
        if (Sequence(parsed_stream_index+number_left_zeros)=='0')
            decodedNumber = bin2dec(Sequence(parsed_stream_index:parsed_stream_index+number_left_zeros))/2;
        elseif (Sequence(parsed_stream_index+number_left_zeros)=='1')
            decodedNumber = -(bin2dec(Sequence(parsed_stream_index:parsed_stream_index+number_left_zeros))-1)/2;
        % USE BIN2DEC
        end
        decodedSequence = [decodedSequence, decodedNumber];
        % very last statements in this loop
        parsed_stream_index = parsed_stream_index + number_left_zeros + 1;
        number_left_zeros = 0;
    else
        number_left_zeros = number_left_zeros + 1;
        parsed_stream_index = parsed_stream_index + 1;
    end
end
