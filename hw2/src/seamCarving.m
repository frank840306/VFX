function img = seamCarving(img)
%myFun - Description
%
% Syntaxn img = seamCarving(img, target_h, target_w)
%
% Long description
    [h, w, ~] = size(img);
    img = carve_up(img);
    img = carve_down();
    % while true
    %     % expand up

        
    %     % expand down


    %     if condition
    %         break;
    %     end
    % end
    
end


function img = carve_up(img)
    while true
        [h, w, c] = size(img);
        gray_img = rgb2gray(img);
        [Gmag, Gdir] = imgradient(gray_img);
        bool_first_line = boolean(gray_img(1, :));
        [segment_start, segment_end, segment_num] = expand_segment(bool_first_line);
        if segment_num == 0
            break
        end
        for segment_idx = 1:segment_num
            segment_w = segment_end(segment_idx) - segment_start(segment_idx) + 1
            
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
                if dp(y, segment_w) < min_grad
                    min_grad = dp(y, segment_w);
                    min_y = y;
                end
            end
            min_grad_path = []
            for idx = segment_w:-1:1
                min_grad_path = [min_y, min_grad_path];
                min_y = from(min_y, idx);
            end
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
    end
end

function img = carve_down(img)
    
end

function [segment_start, segment_end, segment_num] = expand_segment(bool_line)
    segment_start = []
    segment_end = []
    prev_bool = 1;
    if sum(bool_line) == length(bool_line) 
        % pass
    elseif sum(bool_line) == 0
        segment_start = [segment_start, 1];
        segment_end = [segment_end, w];
    else    
        for idx = 1:w
            if idx == w && ~bool_line(idx)
                segment_end = [segment_end, idx]
            if bool_line(idx)    % is white
                if prev_bool == 0
                    segment_end = [segment_end, idx - 1]
                end
            elseif ~bool_line(idx)         % is black
                if prev_bool == 1
                    segment_start = [segment_start, idx]     
                end
            else                        
                continue
            end
            prev_bool = bool_line(idx);
        end
    end
    fprintf('Expand Segment: start num: %d, end num: %d\n', length(segment_start), length(segment_end));
    segment_num = length(segment_start);
end