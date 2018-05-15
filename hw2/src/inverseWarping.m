function warpingImages = inverseWarping(images, img_size, img_h, img_w, channel, focal_length)
%myFun - Description
%
% Syntax: warpingImages = inverseWarping(images)
%
% Long description
    warpingImages = zeros(img_h, img_w, channel, img_size, 'uint8');
    min_x = inf;
    max_x = 0;
    min_y = inf;
    max_y = 0;

    mid_x = img_w / 2;
    mid_y = img_h / 2;
    % fprintf('%d %d', mid_x, mid_y);
    for new_y = 1:img_h
        for new_x = 1:img_w
            x = focal_length * tan((new_x - mid_x) / focal_length);
            y = (new_y - mid_y) * (sqrt(x * x + focal_length * focal_length)) / focal_length;
            x = x + mid_x;
            y = y + mid_y;
            % reconstruct
            if (1 <= x) && (x <= img_w) && (1 <= y) && (y <= img_h)
                % floor_x = floor(x);
                % ceil_x = ceil(x);
                % floor_y = floor(y);
                % ceil_y = ceil(y);
                % colors = (images(floor_y, floor_x, :, :) / 4 + images(floor_y, ceil_x, :, :) / 4 + images(ceil_y, floor_x, :, :) / 4 + images(ceil_y, ceil_x, : , :) / 4);
                % colors = reshape(colors, [channel, img_size]);
                % warpingImages(new_y, new_x, :, :) = colors;
                min_x = min(min_x, new_x);
                max_x = max(max_x, new_x);
                min_y = min(min_y, new_y);
                max_y = max(max_y, new_y);
                warpingImages(new_y, new_x, :, :) = images(round(y), round(x), :, :);    
            end
        end
    end
    fprintf('min x: %d, max x: %d, min y: %d. max y: %d\n', min_x, max_x, min_y, max_y);
    warpingImages = warpingImages(min_y:max_y, min_x:max_x, :, :);
    % figure(1); imshow(warpingImages(:, :, :, 1));
end