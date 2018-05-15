function matched_idx = matchDescriptor(desc1, desc2, thres)
%myFun - Description
%
% Syntax: matched_idx = matchDescriptor(desc1, desc2)
%
% Long description
    % matched_idx = [];
    % for idx = 1:size(desc1, 1)
    %     dis_vector = sum((desc2 - desc1(idx)) .^ 2, 2);
    %     [fir_min_val, fir_min_idx] = min(dis_vector);
    %     [sec_min_val, sec_min_idx] = min(dis_vector(dis_vector > fir_min_val));
    %     if fir_min_val / sec_min_val < thres
    %         matched_idx = [matched_idx; [idx, fir_min_idx]];
    %     end
    % end

    % K-D tree version
    mdl = KDTreeSearcher(desc2);
    [min_idx, min_val] = knnsearch(mdl, desc1, 'K', 2);
    distance_ratio = min_val(:, 1) ./ min_val(:, 2);
    matched_idx = [(1:size(desc1, 1)).', min_idx(:, 1)];
    matched_idx = matched_idx(distance_ratio < thres, :);
end