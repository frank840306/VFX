function plotMatchLink(image1, image2, pos1, pos2, fout)
%myFun - Description
%
% Syntax: plotMatchLink(image1, image2, pos1, pos2, fout)
%
% Long description
    [h_1, w_1, c_1] = size(image1);
    [h_2, w_2, c_2] = size(image2);
    if h_1 ~= h_2 || w_1 ~= w_2 || c_1 ~= c_2
        fprintf('Error: image shape not match (%d %d %d) ~= (%d %d %d)\n', h_1, w_1, c_1, h_2, w_2, c_2);
    else
        % RGB = [image1, zeros(h_1, 10, 3, 'uint8'), image2];
        % disp(pos1);
        RGB = zeros(h_1, 2 *  w_1 + 10, 3, 'uint8');
        RGB(:, 1:w_1, :) = image1;
        RGB(:, w_1+11:end, :) = image2;
        radius = ones(size(pos1, 1), 1) * 5;
        pos2(:, 1) = pos2(:, 1) + w_1 + 10;
        % link = [pos1, pos2];
        RGB = insertShape(RGB, 'circle', [pos1, radius]);
        RGB = insertShape(RGB, 'circle', [pos2, radius]);
        RGB = insertShape(RGB, 'line', [pos1, pos2]);
        imwrite(RGB, fout);

    end
    
end