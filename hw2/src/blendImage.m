function blendedImage = blendImage(image1, image2, dy)
%myFun - Description
%
% Syntax: blendedImage = blendImage(image1, image2, dy)
%
% Long description
    [h_1, w_1, c_1] = size(image1);
    [h_2, w_2, c_2] = size(image2);
    if (h_1 ~= h_2) || (w_1 ~= w_2) || (c_1 ~= c_2)
        fprintf('Error: image shape not match (%d %d %d) ~= (%d %d %d)', h_1, w_1, c_1, h_2, w_2, c_2);
    else     
        fprintf('BlendImage: blending range: (height, width, dy) = (%d, %d, %d)\n', h_1, w_1, dy);
        if dy > 0
            fprintf('dy(%d) > 0\n', dy);
            tmpImage = [image1(1:dy, :, :); interpolateImage(image1(dy+1:end, :, :), image2(1:h_2 - dy, :, :), false); image2(h_2 - dy + 1:end, :, :)];
            h_start = int32(0:dy / (w_1 - 1):dy);
        elseif dy < 0
            % fprintf('Error: unable to deal with dy < 0');
            fprintf('dy(%d) < 0\n', dy);
            tmpImage = [image2(1:abs(dy), :, :); interpolateImage(image1(abs(dy)+1:end, :, :), image2(1:h_2 - abs(dy), :, :), true); image1(h_2 - abs(dy) + 1:end, :, :)];    
            h_start = int32(abs(dy):dy / (w_1 - 1):0)
        else
            tmpImage = interpolateImage(image1(dy+1:end, :, :), image2(1:h_2 - dy, :, :), false);
            h_start = int32(0:dy / (w_1 - 1):dy);
        end
        if h_start ~= 0
            blendedImage = zeros(h_1, w_1, c_1);
            for idx=1:w_1
                % fprintf('%d %d\n', h_start(idx)+1, h_start(idx) + h_1);
                blendedImage(:, idx, :) = tmpImage(h_start(idx)+1:h_start(idx) + h_1, idx, :);
            end
        else
            blendedImage = tmpImage;
        end
    end
end

function interpolatedImage = interpolateImage(image1, image2, reversed)
    [h_1, w_1, c_1] = size(image1);
    [h_2, w_2, c_2] = size(image2);
    if (w_1 ~= w_2)
        fprintf('Error: width not match %d ~= %d \n', w_1, w_2);
    else
        % default reversed is false
        fprintf('InterpolatedImage: interpolate range: (height, width, reversed) = (%d, %d, %d)\n', h_1, w_1, reversed);
        if ~reversed
            r_1 = 1:-1 / (w_2 - 1):0;
            r_2 = 0:1 / (w_1 - 1):1;
        else
            r_1 = 0:1 / (w_1 - 1):1;
            r_2 = 1:-1 / (w_2 - 1):0;
        end
        % r_1
        % r_2
        interpolatedImage = zeros(h_1, w_1, c_1);
        for w = 1:w_1
            % disp(image1(:, w, :) * r_1(w) + image2(:, w, :) * r_2(w));
            interpolatedImage(:, w, :) = image1(:, w, :) * r_1(w) + image2(:, w, :) * r_2(w);
            % break;
        end
    end
end