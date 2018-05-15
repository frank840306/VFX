function [max_match_pos1, max_match_pos2] = RANSAC(matched_idx, pos1, pos2, thres)
%myFun - Description
%
% Syntax: [move_ver, move_hor] = RANSAC(pos1, pos2)
%
% Long description
    P = 0.99;
    p = 0.5;
    n = 2;
    
    k = int32(log(1 - P) / log(1 - p ^ n));

    % matched_pos1 = pos1(matched_idx(:, 1), :);
    % matched_pos2 = pos2(matched_idx(:, 2), :);

    des_size = size(matched_idx, 1);
    fprintf('RANSAC iteration: %d, descriptor size: %d\n', k, des_size);
    max_match_pos1 = [];
    max_match_pos2 = [];

    for idx= 1:k
        sample_idx = randperm(des_size, n);
        others_idx = setdiff(1:des_size, sample_idx);
        
        sample_pos1 = pos1(matched_idx(sample_idx, 1), :);
        sample_pos2 = pos2(matched_idx(sample_idx, 2), :);
        others_pos1 = pos1(matched_idx(others_idx, 1), :);
        others_pos2 = pos2(matched_idx(others_idx, 2), :);

        % relative distance = pos1 - pos2
        moves = mean(sample_pos1 - sample_pos2, 1);   % 1:x, 2:y
        L2 = sqrt(sum((others_pos2 + moves - others_pos1) .^ 2, 2));
        % L2
        % thres
        match_pos1 = others_pos1(L2 < thres, :);
        match_pos2 = others_pos2(L2 < thres, :);

        if size(match_pos1, 1) > size(max_match_pos1, 1)
            max_match_pos1 = match_pos1;
            max_match_pos2 = match_pos2;
            fprintf('Update max match %d/%d\n', size(max_match_pos1, 1), length(others_idx));
        end
    end
end