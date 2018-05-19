function [panorama, posi_thres, nega_thres] = matchImage(image1, image2, dx, dy, posi_thres, nega_thres)
%myFun - Description
%
% Syntax: panorama = matchImage(image1, image2, dx, dy)
%
% Long description
    [h_1, w_1, c_1] = size(image1);
    [h_2, w_2, c_2] = size(image2);
    
    % dx = delta(1);
    % dy = delta(2);

    
    % panorama = zeros(w_p, h_p, c_p);
    % panorama(: , 1:w_p - w_2) = image1(:, 1:w_p - w_2);
    % panorama(: , w_p - w_2 + 1:w_1) = blendImage();
    % panorama(: , w_1 + 1:end) = image2(:, w_2 - w_1 + dx + 1:end);
    if dx > 0
        if dy > 0 && dy > posi_thres
            h_p = h_1 + (dy - posi_thres);
        elseif dy < 0 && dy < nega_thres    
            h_p = h_1 + abs(dy - nega_thres);
        else
            h_p = h_1;
        end

        % h_p = max(h_1, h_2 + abs(dy));
        w_p = w_2 + dx;
        c_p = c_1;
        panorama = zeros(h_p, w_p, c_p);
        % fprintf('image size: %d %d %d\n', h_p, w_p, c_p);
        if dy > 0
            if dy > posi_thres
                panorama(1:h_1, 1:dx, :) = image1(:, 1:dx, :);
                panorama(:, dx + 1:w_1, :) = blendImage2(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy, posi_thres, nega_thres);
                panorama(abs(nega_thres) + dy + 1:end, w_1 + 1:end, :) = image2(:, w_1 - dx + 1:end, :);
                posi_thres = dy;
                % fprintf('Update positive threshold: %d\n', posi_thres);
            else
                panorama(:, 1:dx, :) = image1(:, 1:dx, :);
                panorama(:, dx + 1:w_1, :) = blendImage2(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy, posi_thres, nega_thres);
                panorama(dy + abs(nega_thres) + 1:dy + abs(nega_thres) + h_2, w_1 + 1:end, :) = image2(:, w_1 - dx + 1:end, :);

            end
            
        elseif dy < 0
            if dy < nega_thres
                panorama(h_p - h_1 + 1:end, 1:dx, :) = image1(:, 1:dx, :);
                panorama(:, dx + 1:w_1, :) = blendImage2(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy, posi_thres, nega_thres);
                panorama(1:h_2, w_1 + 1:end, :) = image2(:, w_1 - dx + 1:end, :);
                nega_thres = dy;
                % fprintf('Update negative threshold: %d\n', nega_thres);
            else
                panorama(:, 1:dx, :) = image1(:, 1:dx, :);
                panorama(:, dx + 1:w_1, :) = blendImage2(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy, posi_thres, nega_thres);
                panorama(h_p - abs(dy) - posi_thres - h_2 + 1:h_p - abs(dy) - posi_thres, w_1 + 1:end, :) = image2(:, w_1 - dx + 1:end, :);
            end    
        else
            panorama(:, 1:dx, :) = image1(:, 1:dx, :);
            panorama(:, dx + 1:w_1, :) = blendImage2(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy, posi_thres, nega_thres);
            panorama(1:h_2, w_1 + 1:end, :) = image2(:, w_1 - dx + 1:end, :);
        end
        

        % panorama = [image1(:, 1:dx, :), blendImage(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy), image2(:, w_1 - dx + 1:end, :)];
        % panorama = uint8(panorama);
    else
        error('Error: unable to deal with dx(%d) < 0\n', dx);
    end
    % [h_p, w_p, c_p]
    
end