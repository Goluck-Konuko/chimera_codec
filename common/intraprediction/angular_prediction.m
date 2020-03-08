function pred_out = angular_prediction(left, top, blockSize, mode)
    [left_2, top_2] = interpolation(left,top, blockSize);
    %[left_2, top_2] = filter_reference_array(left_1, top_1, blockSize);
    mode_displacement = [32,26,21,17,13,9,5,2];
    mode_displacement_inv = [2,5,9,13,17,21,26,32];
    pred_out = zeros(blockSize);
    if(mode>=2 && mode<18)
        main_reference = [top(1);left_2];
        main_reference_ext = [];
        positive_modes = [2 3 4 5 6 7 8 9];
        negative_modes = [11 12 13 14 15 16 17];
        %set the mode displacement
        if find(positive_modes==mode)>=1
            index = find(positive_modes==mode);
            displacement = mode_displacement(index);
            for x=1:blockSize
                for y=1:blockSize
                    %calculate the pixel projection on to the reference array
                    c = (y*displacement)/32 ;
                    w = (y*displacement) && 31;
                    i = int8(x + c);
                    %estimate the pixel value from the neighboring projections
                    pred_out(x,y) = int16(((32-w)*main_reference(i) + w*main_reference(i+1)+16)/32);
                end
            end
        elseif(mode==10)
            for x=1:blockSize
                for y=1:blockSize
                    pred_out(x,y)= main_reference(x);
                end
            end
        else
            displacement = -(mode_displacement_inv(find(negative_modes==mode)));
            inv_angle = (256*32)/displacement;
            for i=1:blockSize %prepare the extensions
                index = int8(-1+((-i*inv_angle+128)/256));
                if(index<=blockSize-1)
                   main_reference_ext = [main_reference_ext top_2(index)];
                end
            end
            main_reference = [top_2(1); main_reference];
            %add the reference sample extension to the main reference
            for val=1:length(main_reference_ext)
                main_reference = [main_reference_ext(val); main_reference];
            end
            for x=1:blockSize
                for y=1:blockSize
                    %calculate the pixel projection on to the reference array
                    c = ((y+1)*displacement)/32 ; %projection
                    w = ((y+1)*displacement) && 31; %weighting
                    i = uint8((x+1) + c); %reference pixel index
%                     if i~=0
%                        %estimate the pixel value from the neighboring projections
%                         pred_out(x,y) = int8(((32-w)*main_reference(i) + w*main_reference(i+1)+16)/32);
%                     else
                        pred_out(x,y) = int16(((32-w)*main_reference(i+1) + w*main_reference(i+2)+16)/32);
                    %end
                end
            end
        end
    else
        %perform prediction for modes 18-35 here
        main_reference = top_2;
        main_reference_ext = [];
        positive_modes = [27 28 29 30 31 32 33 34];
        negative_modes = [18 19 20 21 22 23 24 25];
        if find(positive_modes==mode)>=1
            index = find(positive_modes==mode);
            displacement = mode_displacement(index);
            for x=1:blockSize
                for y=1:blockSize
                    %calculate the pixel projection on to the reference array
                    c = ((y)*displacement)/32 ;
                    w = ((y)*displacement) && 31;
                    i = int8(x + c);
                    %estimate the pixel value from the neighboring projections
                    pred_out(x,y) = int16(((32-w)*main_reference(i) + w*main_reference(i+1)+16)/32);
                end
            end
        elseif(mode==26)
            for x=1:blockSize
                for y=1:blockSize
                    pred_out(x,y)= main_reference(y+1);
                end
            end
        else
            ind = find(negative_modes==mode);
            displacement = int8(-1*(mode_displacement_inv(ind)));
            inv_angle = (256*32)/displacement;
            left_2 = [top_2(1); left_2]; %add the top left sample to the left reference before extensions
            for i=1:blockSize %prepare the extensions
                index = uint8(-1+((-i*inv_angle+128)/256));
                if(index<=blockSize-1)
                   main_reference_ext = [main_reference_ext left_2(index+1)];
                end
            end
            %add the reference sample extension to the main reference
            for val=1:length(main_reference_ext)
                main_reference = [main_reference_ext(val) main_reference];
            end
            for x=1:blockSize
                for y=1:blockSize
                    %calculate the pixel projection on to the reference array
                    c = ((y+1)*displacement)/32 ;
                    w = ((y+1)*displacement) && 31;
                    i = uint8((x+1) + c);
                    %estimate the pixel value from the neighboring projections
                    pred_out(x,y) = int16(((32-w)*main_reference(i+1) + w*main_reference(i+2)+16)/32);
                    
                end
            end
        end
    end
%     if mode==3%pure vertical
%         for x=1:blockSize
%             for y=1:blockSize
%                 pred_out(x,y) = top_2(y+1);
%             end
%         end
%     else %pure horizontal
%         for x=1:blockSize
%             for y=1:blockSize
%                 pred_out(x,y)= left_2(y);
%             end
%         end
%     end
end