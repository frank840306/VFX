function blendedImage = blendImage2(img1, img2, dy, posi_thres, nega_thres)
%myFun - Description
%
% Syntax: blendedImage = blendImage2(img1, img2, dy)
%
% Long description
    [h_1, w_1, c_1] = size(img1);
    [h_2, w_2, c_2] = size(img2);
    if (w_1 ~= w_2) || (c_1 ~= c_2)
        error('Error: image shape not match (%d %d %d) ~= (%d %d %d)', h_1, w_1, c_1, h_2, w_2, c_2);
    else
        fprintf('Info: img1 (%d %d %d), img2 (%d %d %d), dy: %d\n', h_1, w_1, c_1, h_2, w_2, c_2, dy);
        if dy > 0 && dy > posi_thres
            h_p = h_1 + (dy - posi_thres);
        elseif dy < 0 && dy < nega_thres    
            h_p = h_1 + abs(dy - nega_thres);
        else
            h_p = h_1;
        end
        % h_p = max(h_1, h_2 + abs(dy));
        blendedImage = zeros(h_p, w_1, c_1);
        fprintf('BlengImage2: image shape (%d %d %d), posi: %d, nega: %d\n', h_p, w_1, c_1, posi_thres, nega_thres);
        if dy > 0
            blendedImage(1:dy + abs(nega_thres), :, :) = img1(1:dy + abs(nega_thres), :, :);
            if dy > posi_thres
                blendedImage(dy + abs(nega_thres) + 1:h_1, :, :) = interpolateImage(img1(dy + abs(nega_thres) + 1:h_1, :, :), img2(1:h_1 - dy - abs(nega_thres), :, :));
                blendedImage(h_1 + 1:end, :, :) = img2(h_1 - dy - abs(nega_thres) + 1:end, :, :);
            else
                blendedImage(dy + abs(nega_thres) + 1:dy + abs(nega_thres) + h_2, :, :) = interpolateImage(img1(dy + abs(nega_thres) + 1:dy + abs(nega_thres) + h_2, :, :), img2);
                blendedImage(dy + abs(nega_thres) + h_2 + 1:end, :, :) = img1(dy + abs(nega_thres) + h_2 + 1:end, :, :);
            end    
            % blendedImage(dy + 1:dy + h_2, :, :) = interpolateImage(img1(dy+1:dy+h_2, :, :), img2(1:h_1 - dy, :, :));
            % blendedImage(dy + h_2 + 1:end, :, :) = img2(h_1 - dy + 1:end, :, :);
        elseif dy < 0
            if dy < nega_thres
                blendedImage(1:h_2 + abs(dy) + posi_thres - h_1, :, :) = img2(1:h_2 + abs(dy) + posi_thres - h_1, :, :);
                blendedImage(h_2 + abs(dy) + posi_thres - h_1 + 1:h_2, :, :) = interpolateImage(img1(1:h_1 - abs(dy) - posi_thres, :, :), img2(h_2 + abs(dy) + posi_thres - h_1 + 1:end, :, :));
            else
                blendedImage(1:h_1 - posi_thres - abs(dy) - h_2, :, :) = img1(1:h_1 - posi_thres - abs(dy) - h_2, :, :);
                blendedImage(h_1 - posi_thres - abs(dy) - h_2 + 1:h_1 - posi_thres - abs(dy), :, :) = interpolateImage(img1(h_1 - abs(dy) - posi_thres - h_2 + 1:h_1 - abs(dy) - posi_thres, :, :), img2);
            end
            blendedImage(h_p - abs(dy) - posi_thres + 1:end, :, :) = img1(h_1 - abs(dy) - posi_thres + 1:end, :, :);           
            % blendedImage(1:h_2 + abs(dy) - h_1, :, :) = img2(1:h_2 + abs(dy) - h_1, :, :);
            % blendedImage(h_2 + abs(dy) - h_1 + 1:h_2, :, :) = interpolateImage(img1(1:h_1 - abs(dy), :, :), img2(h_2 + abs(dy) - h_1 + 1:end, :, :));
            % blendedImage(h_2 + 1:end, :, :) = img1(h_1 - abs(dy) + 1:end, :, :);
        else
            blendedImage(1:abs(nega_thres), :, :) = img1(1:abs(nega_thres), :, :);
            blendedImage(abs(nega_thres) + 1:abs(nega_thres) + h_2, :, :) = interpolateImage(img1(abs(nega_thres) + 1:abs(nega_thres) + h_2, :, :), img2);
            blendedImage(abs(nega_thres) + h_2 + 1:end, :, :) = img1(abs(nega_thres) + h_2 + 1:end, :, :);
        end
    end
end

function interpolatedImage = interpolateImage(img1, img2)
    [h_1, w_1, c_1] = size(img1);
    [h_2, w_2, c_2] = size(img2);
    if (h_1 ~= h_2) || (w_1 ~= w_2) || (c_1 ~= c_2)
        error('Error: image shape not match (%d %d %d) ~= (%d %d %d)', h_1, w_1, c_1, h_2, w_2, c_2);
    else
        % inter_range = round(h_1 / 20);
        % interpolatedImage = [zeros(h_1, inter_range, c_1), img2(:, inter_range + 1:end, :)];
        % fprintf('size: %d', size(interpolatedImage, 2));
        % r_1 = 1:-1 / (inter_range - 1):0;
        % r_2 = 0:1 / (inter_range - 1):1;
        % for w = 1:inter_range
        %     interpolatedImage(:, w, :) = r_1(w) * img1(:, w_1 - inter_range + w, :) + r_2(w) * img2(:, w, :);
        % end
        
        interpolatedImage = zeros(h_1, w_1, c_1);
        % r_1 = 1:-1 / (w_1 - 1):0;
        % r_2 = 0:1 / (w_2 - 1):1;
        
        % sp = 1;
        sp = round(w_1 / 2) - 15;
        ep = sp + 30;
        r_1 = 1:-1 / (ep - sp):0;
        r_2 = 0:1 / (ep - sp):1;
        
        for h = 1:h_1
            for w = 1:w_1
                if sum(img1(h, w, :)) == 0
                    interpolatedImage(h, w, :) = img2(h, w, :);
                elseif sum(img2(h, w, :)) == 0
                    interpolatedImage(h, w, :) = img1(h, w, :);
                else
                    if sp <= w && w <= ep
                        % interpolatedImage(h, w, :) = r_1(w) * img1(h, w, :) + r_2(w) * img2(h, w, :);
                        interpolatedImage(h, w, :) = r_1(w - sp + 1) * img1(h, w, :) + r_2(w - sp + 1) * img2(h, w, :);
                    elseif w < sp
                        interpolatedImage(h, w, :) = img1(h, w, :);
                    elseif w > ep
                        interpolatedImage(h, w, :) = img2(h, w, :);
                    end
                end
            end
        end

    end
end