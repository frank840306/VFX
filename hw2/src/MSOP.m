function [feature] = MSOP(image)
    
    % construct 3-level image pyramid
    % find all feature points and their descriptors
    [row, col, value] = localMax(image);
    descriptor = constructDescriptor(image, row, col);
    for i = 1:2
        n = 2 ^ i;
        image_tmp = image(1:n:end, 1:n:end);
        
        [row_tmp, col_tmp, value_tmp] = localMax(image_tmp);
        row = [row; row_tmp .* n];
        col = [col; col_tmp .* n];
        value = [value; value_tmp];
        
        descriptor_tmp = constructDescriptor(image_tmp, row_tmp, col_tmp);
        descriptor = [descriptor; descriptor_tmp];
    end
    
    % non-maximal suppression
    dist = zeros(length(row));
    for i = 1:length(row)
        index = find(value > value(i));
        if isempty(index)
            dist(i) = Inf;
        else
            dist(i) = min(dist2([row(i), col(i)], [row(index), col(index)]));
        end
    end

    % get five hundred feature points
    n = 500;
    [~, index] = sort(dist, 'descend');
    row = row(index(1:n));
    col = col(index(1:n));
    descriptor = descriptor(index(1:n), :);
    
    feature = [col, row, descriptor];     % x, y form