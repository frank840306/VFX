function [row, col, value] = localMax_sub(image)

    [Px, Py] = gradient(single(image));
    Px = imgaussfilt(Px, 1.0);
    Py = imgaussfilt(Py, 1.0);
    Hx2 = imgaussfilt(Px .^ 2, 1.5);
    Hy2 = imgaussfilt(Py .^ 2, 1.5);
    Hxy = imgaussfilt(Px .* Py, 1.5);
    detH = Hx2 .* Hy2 - Hxy .^ 2;
    trH = Hx2 + Hy2;
    
    % Compute harmonic mean
    harmonic_mean = detH ./ trH;
    index = isnan(harmonic_mean) | isinf(harmonic_mean);
    harmonic_mean(index) = 0;
    
    % Compute local max of harmonic mean matrix
    HM_threshold = harmonic_mean > 10;
    HM_local_max = harmonic_mean == imdilate(harmonic_mean, strel('square', 3));
    index = HM_threshold & HM_local_max;
    local_max = harmonic_mean .* index;
    
    % Ignore the points which are too close to the border
    border = 30;
    local_max(:, [1:border, end - border:end]) = 0;
    local_max([1:border, end - border:end], :) = 0;

    
    % Compute sub-pixel refinement
    [row, col, value] = find(local_max);
    xl = sub2ind(size(harmonic_mean), row, col - 1);
    xr = sub2ind(size(harmonic_mean), row, col + 1);
    yu = sub2ind(size(harmonic_mean), row - 1, col);
    yd = sub2ind(size(harmonic_mean), row + 1, col);
    tmp = [harmonic_mean(xl), harmonic_mean(xr), harmonic_mean(yu), harmonic_mean(yd), value];
    x1 = sum(tmp .* [-0.5 0.5 0 0 0], 2);
    y1 = sum(tmp .* [0 0 -0.5 0.5 0], 2);
    x2 = sum(tmp .* [1 1 0 0 -2], 2);
    y2 = sum(tmp .* [0 0 1 1 -2], 2);
    row = single(row) - (y1 ./ y2);
    col = single(col) - (x1 ./ x2);
    
    
    