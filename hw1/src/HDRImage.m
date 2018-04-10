function HDRImage(images, exposure_time, image_num, output)
    
    exposure_time_ln = log(exposure_time);
    random_seed = 0;
    sample_num = 100;                                               % total amount of sample points
    lambda = 100;

    [row, col, channel] = size(images(:, :, :, 1));
    rng(random_seed);
    sample_index = randi([1, row * col], 1, sample_num);

    disp('sampling 100 points...');
    sample_points = zeros(sample_num, image_num, 3, 'uint8');
    for i = 1:image_num
       for j = 1:3
           tmp = images(:, :, j, i);
           sample_points(:, i, j) = tmp(sample_index);
       end
    end

    disp('computing g curve...');
    g = zeros(256, 3);
    w = [0:1/127:1 1:-1/127:0];
    for i = 1:3
        [g(:, i), ~] = gsolve(sample_points(:, :, i), exposure_time_ln, lambda, w);
    end
    % plot(g);

    disp('computing lnE...');
    lnE = zeros(row * col, channel);
    for i = 1:channel
        tmp = images(:, :, i, :);
        tmp = reshape(tmp, row * col, image_num);
        lnE(:, i) = sum(w(tmp + 1) .* (g(tmp + 1) - exposure_time_ln), 2) ./ sum(w(tmp + 1), 2);
    end

    disp('computing HDR image...');
    lnE(isnan(lnE)) = 0;
    image_HDR = exp(reshape(lnE, row, col, channel));
    index = isnan(image_HDR) | isinf(image_HDR);
    image_HDR(index) = 0;
    hdrwrite(image_HDR, output);

    clear;
end