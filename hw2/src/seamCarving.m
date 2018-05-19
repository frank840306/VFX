function img = seamCarving(img)
%myFun - Description
%
% Syntaxn img = seamCarving(img, target_h, target_w)
%
% Long description
    [h, w, ~] = size(img);
    % TODO: 
    bool_img = boolean(rgb2gray(img));
    sum_bool_horivontal = sum(bool_img, 1);
    min_x = 0;
    max_x = 0;
    flag = 0;
    for idx = 1:w
        if sum_bool_horivontal(idx) ~= 0
            if flag == 0
                min_x = idx;
                flag = 1;
            end
            max_x = idx;
        end
    end
    % fprintf('min: %d, max: %d\n', min_x, max_x);
    img = img(:, min_x:max_x, :);
    [h, w, ~] = size(img);
    
    bool_img = boolean(rgb2gray(img));
    sum_bool_vertical = sum(bool_img, 2);
    
    up_limit = 0;
    down_limit = 0;
    flag = 0;
    % sum_bool_vertical(sum_bool_vertical == w, 1)
    for idx = 1:h
        if sum_bool_vertical(idx) == w
            if flag == 0
                down_limit = idx;
                flag = 1;
            end
            up_limit = idx;
        end
    end
    % fprintf('up: %d, down: %d\n', up_limit, down_limit);
    fprintf('Seam carving up...\n');
    img(1:up_limit, :, :) = carve_up(img(1:up_limit, :, :));
    fprintf('Seam carving down...\n');
    img(down_limit:end, :, :) = carve_down(img(down_limit:end, :, :));
    img = uint8(img);
end


function img = carve_up(img)
    iter = 0;
    img = double(img);
    carveFlag = zeros(1, size(img, 1));
    while true
        iter = iter + 1;
        % fprintf('========== Iteration %2d ==========\n', iter);
        [h, w, c] = size(img);
        gray_img = rgb2gray(img);
        % gray_img(1:10, 77:95)
        [Gmag, Gdir] = imgradient(gray_img);
        bool_first_line = boolean(gray_img(1, :));
        [segment_start, segment_end, segment_num] = expand_segment(bool_first_line);
        if segment_num == 0 || iter == round(w / 2)
            break
        end
        for segment_idx = 1:segment_num
            segment_w = segment_end(segment_idx) - segment_start(segment_idx) + 1;
            
            dp = zeros(h, segment_w);
            from = zeros(h, segment_w);
            for y = 1:h
                dp(y, 1) = Gmag(y, segment_start(segment_idx));
            end
            for x = 2:segment_w
                for y = 1:h
                    min_neighbor = dp(y, x - 1);
                    from(y, x) = y;
                    if y > 1 && dp(y - 1, x - 1) < min_neighbor
                        min_neighbor = dp(y - 1, x - 1);
                        from(y, x) = y - 1;
                    end
                    if y < h && dp(y + 1, x - 1) < min_neighbor
                        min_neighbor = dp(y + 1, x - 1);
                        from(y, x) = y + 1;
                    end
                    dp(y, x) = Gmag(y, segment_start(segment_idx) + x - 1) + min_neighbor;
                end
            end
            min_grad = inf;
            for y = 1:h
                if dp(y, segment_w) < min_grad && gray_img(y, segment_end(segment_idx)) ~= 0 && carveFlag(y) == 0
                    min_grad = dp(y, segment_w);
                    min_y = y;
                    carveFlag(y) = 1;
                end
            end
            min_grad_path = [];
            for idx = segment_w:-1:1
                min_grad_path = [min_y, min_grad_path];
                min_y = from(min_y, idx);
            end
            % fprintf('path: ');
            % for idx = 1:length(min_grad_path)
            %    fprintf('%d ', min_grad_path(idx)); 
            % end
            % fprintf('\n');
            for idx = 1:segment_w
                for y = 1:min_grad_path(idx)
                    img(y, segment_start(segment_idx) + idx - 1, :) = img(y + 1, segment_start(segment_idx) + idx - 1, :);
                end
                if min_grad_path(idx) + 2 > h
                    img(min_grad_path(idx) + 1, segment_start(segment_idx) + idx - 1, :) = img(min_grad_path(idx), segment_start(segment_idx) + idx - 1, :);
                else
                    img(min_grad_path(idx) + 1, segment_start(segment_idx) + idx - 1, :) = img(min_grad_path(idx), segment_start(segment_idx) + idx - 1, :) / 2 + img(min_grad_path(idx) + 2, segment_start(segment_idx) + idx - 1, :) / 2;
                end
            end
            % fprintf('%d <--> %d V ', segment_start(segment_idx), segment_end(segment_idx));
            % imwrite(uint8(img), sprintf('res/seam%d.png', iter), 'png');
        end
        % fprintf('\n');
    end
    img = uint8(img);
end

function img = carve_down(img)
    [h, w, c] = size(img);
    img = img(h:-1:1, :, :);
    img = carve_up(img);
    img = img(h:-1:1, :, :);
end

function [segment_start, segment_end, segment_num] = expand_segment(bool_line)
    % bool_line(1:500)
    segment_start = [];
    segment_end = [];
    prev_bool = 1;
    w = length(bool_line);
    if sum(bool_line) == length(bool_line) 
        % pass
    elseif sum(bool_line) == 0
        segment_start = [segment_start, 1];
        segment_end = [segment_end, w];
    else    
        for idx = 1:w
            if idx == w && ~bool_line(idx)
                segment_end = [segment_end, idx];
            end
            if bool_line(idx)    % is white
                if prev_bool == 0
                    segment_end = [segment_end, idx - 1];
                end
            elseif ~bool_line(idx)         % is black
                if prev_bool == 1
                    segment_start = [segment_start, idx];  
                end
            else                        
                % continue
            end
            prev_bool = bool_line(idx);
        end
    end
    if length(segment_start) ~= length(segment_end)
        error('Error: size of segment_start and segment_end are not the same, %d ~= %d', length(segment_start), length(segment_end));
    else
        % fprintf('Expand Segment: start num: %d, end num: %d\n', length(segment_start), length(segment_end));
        segment_num = length(segment_start);
        % for idx = 1:segment_num
            % fprintf('%d <--> %d   ', segment_start(idx), segment_end(idx));
        % end
        % fprintf('\n');
    end
end

