function [feature] = MSOP(image)
    
    [row, col, value] = localMax(image);
    descriptor = constructDescriptor(image, row, col);
%     level = ones(length(row), 1);
    for i = 1:3
        n = 2 ^ i;
%         disp(['Level: ' int2str(i) ', subsampling factor: ' int2str(n)]);
        image_tmp = image(1:n:end, 1:n:end);
        
        [row_tmp, col_tmp, value_tmp] = localMax(image_tmp);
        row = [row; row_tmp .* n];
        col = [col; col_tmp .* n];
        value = [value; value_tmp];
        
%         disp(['Level: ' int2str(i) ', constructing descriptor...']);
        descriptor_tmp = constructDescriptor(image_tmp, row_tmp, col_tmp);
        descriptor = [descriptor; descriptor_tmp];
        
%         tmp(1:length(row_tmp), 1) = n;
%         level = [level; tmp];
%         clear tmp
    end
    
    dist = zeros(length(row));
%     disp(['Number of features before non-maximal suppression: ' int2str(length(row))]);
    for i = 1:length(row)
        index = find(value * 0.95 > value(i));
        if isempty(index)
            dist(i) = Inf;
        else
            dist(i) = min(dist2([row(i), col(i)], [row(index), col(index)]));
        end
%         if mod(i, 1000) == 0
%             disp(['Computing the radius of the ' int2str(i) 'th point']);
%         end
    end

    n = 500;
    [~, index] = sort(dist, 'descend');
    row = row(index(1:n));
    col = col(index(1:n));
    descriptor = descriptor(index(1:n), :);
    
    feature = [col, row, descriptor];     % x, y form
%     feature = [row, col, descriptor];       % matrix form