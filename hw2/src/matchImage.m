function panorama = matchImage(image1, image2, dx, dy)
%myFun - Description
%
% Syntax: panorama = matchImage(image1, image2, dx, dy)
%
% Long description
    [h_1, w_1, c_1] = size(image1);
    [h_2, w_2, c_2] = size(image2);
    
    % dx = delta(1);
    % dy = delta(2);

    % h_p = min(h_1, h_2);
    % w_p = w_2 + dx;
    % c_p = min(c_1, c_2);

    % panorama = zeros(w_p, h_p, c_p);
    % panorama(: , 1:w_p - w_2) = image1(:, 1:w_p - w_2);
    % panorama(: , w_p - w_2 + 1:w_1) = blendImage();
    % panorama(: , w_1 + 1:end) = image2(:, w_2 - w_1 + dx + 1:end);
    if dx > 0
        if dy >= 0
            panorama = [image1(:, 1:dx, :), blendImage(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy), image2(:, w_1 - dx + 1:end, :)];
        else
            fprintf('Error: unable to deal with dy(%d) < 0\n', dy);
            panorama = [image1(:, 1:dx, :), blendImage(image1(:, dx+1:end, :), image2(:, 1:w_1 - dx, :), dy), image2(:, w_1 - dx + 1:end, :)];
        end
    else
        fprintf('Error: unable to deal with dx(%d) < 0\n', dx);
    end
    % [h_p, w_p, c_p]
    panorama = uint8(panorama);
end