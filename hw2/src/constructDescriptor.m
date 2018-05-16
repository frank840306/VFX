function [descriptor] = constructDescriptor(image, row, col)
    row_int = round(row);
    col_int = round(col);

    [Px, Py] = gradient(single(image));
    Px = imgaussfilt(Px, 4.5);
    Py = imgaussfilt(Py, 4.5);

    C = Px ./ ((Px .^ 2 + Py .^ 2) .^ 0.5);
    index = isnan(C) | isinf(C);
    C(index) = 0;

    S = Py ./ ((Px .^ 2 + Py .^ 2) .^ 0.5);
    index = isnan(S) | isinf(S);
    S(index) = 0;

    index = sub2ind(size(C), row_int, col_int);
%     rotation = [C(index), -S(index), S(index), C(index)];
    rotation = [S(index), -C(index), C(index), S(index)];
    rotation = transpose(rotation);
    tmp = size(rotation);
    rotation = reshape(rotation, 2, 2, tmp(2));

    % patch = 40 * 40, and the feature point is at (20, 20)
    window = zeros(2, 1600);
    descriptor = zeros(length(row_int), 64);
    cell(1:8) = 5;
    for i = 1:length(row_int)
        % prepare window
        window(1, :) = reshape(repmat((col_int(i) - 19:col_int(i) + 20), [40, 1]), 1, 1600);
        window(2, :) = repmat((row_int(i) - 19:row_int(i) + 20), [1, 40]);
        
        % rotate window
        window(:, :) = rotation(:, :, i) * window;
        window(1, :) = round(window(1, :));
        window(2, :) = round(window(2, :));
        
        %shift window
        window(1, :) = window(1, :) + (col_int(i) - window(1, 780));
        window(2, :) = window(2, :) + (row_int(i) - window(2, 780));
        index = sub2ind(size(image), round(window(2, :)), round(window(1, :)));
        patch = reshape(image(index), 40, 40);
        C = mat2cell(patch, cell, cell);
        for j = 1:64
            descriptor(i, j) = mean(mean(C{j}));
        end
    end
    M = mean(descriptor, 2);
    S = std(descriptor, 0, 2);
    descriptor = (descriptor - M) ./ S;
%     disp(size(descriptor));