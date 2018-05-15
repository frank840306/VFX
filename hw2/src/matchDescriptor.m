function matched_idx = matchDescriptor(desc1, desc2, thres)
%myFun - Description
%
% Syntax: matched_idx = matchDescriptor(desc1, desc2)
%
% Long description

    ranking_list = [];
    matched_idx = [];
    desc_size = size(desc1, 1);
    flag1 = zeros(1, desc_size, 'uint8');
    flag2 = zeros(1, desc_size, 'uint8');
    
    
    for idx = 1:desc_size
        dis_vector = sum((desc2 - desc1(idx, :)) .^ 2, 2);
        [sec_min_val, sec_min_idx] = min(dis_vector(dis_vector > min(dis_vector)));
        current_list = [ones(desc_size, 1) * idx, (1:desc_size).', dis_vector, dis_vector / sec_min_val];
        current_list = current_list(current_list(:, 4) < thres, :);
        
        ranking_list = [ranking_list; current_list];
        % disp(ranking_list(1:20, :));
        % break;
    end
    ranking_list = sortrows(ranking_list, 3);
    % disp(ranking_list(1:5, :));
    for idx = 1:size(ranking_list, 1)
        if ranking_list(idx, 4) < thres && ~flag1(ranking_list(idx, 1)) && ~flag2(ranking_list(idx, 2))
            matched_idx = [matched_idx; [ranking_list(idx, 1), ranking_list(idx, 2)]];
            flag1(ranking_list(idx, 1)) = 1;
            flag2(ranking_list(idx, 2)) = 1;
            % disp(ranking_list(idx, :));
        end
    end
    
    % matched_idx = [];
    % for idx = 1:size(desc1, 1)
    %     dis_vector = sum((desc2 - desc1(idx, :)) .^ 2, 2);
    %     [fir_min_val, fir_min_idx] = min(dis_vector);
    %     [sec_min_val, sec_min_idx] = min(dis_vector(dis_vector > fir_min_val));
    %     if fir_min_val / sec_min_val < thres
    %         matched_idx = [matched_idx; [idx, fir_min_idx]];
    %         desc2(fir_min_idx, :) = [];
    %         % break;
    %     end
    % end

    % K-D tree version
    % mdl = KDTreeSearcher(desc2);
    % matched_idx = [];
    % search_size = size(desc1, 1);
    % flag1 = zeros(1, search_sizem, 'uint8');
    % flag2 = zeros(1, search_size, 'uint8');
    % for step = 1:search_size
    %     mdl = KDTreeSearcher(desc2);
    %     [min_idx, min_val] = knnsearch(mdl, desc1, 'K', 2);
    %     distance_ratio = min_val(:, 1) ./ min_val(:, 2);
    %     disp([min_val, distance_ratio]);
    %     % min_idx = min_idx(distance_ratio < thres);
    %     % min_val = min_val(distance_ratio < thres);
    %     [val, idx] = min(min_val);
    %     while true
    %         if distance_ratio(idx) < thres && flag1(idx) == 0 && flag2(min_idx(idx)) == 0
    %             matched_idx = [matched_idx; [idx, min_idx(idx)]];
    %             flag1(idx) = 1;
    %             flag2(min_idx(idx)) = 1;
    %             break;
    %         end
    %         [val, idx]
    %     end
    %     if size(min_idx, 1) > 0
    %         [val, idx] = min(min_val);
    %         matched_idx = [matched_idx; [idx, min_idx(idx)]];
    %         % desc2(min_idx(idx), :) = []
    %     end 
        
    % end
        
end