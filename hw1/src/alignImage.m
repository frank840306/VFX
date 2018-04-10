function alignImg = alignImage(input_dir, output_dir, scale_num, bitmap)
    fprintf('Input directory: %s\n', input_dir)
    fprintf('Output directory: %s\n', output_dir)
    fprintf('Scale number: %d\n', scale_num)
    % create output directory 
    if exist(output_dir, 'dir')
        if ~isEmptyDirectory(output_dir)
            deleteFileInDirectory(output_dir)    
        end
    else
        mkdir(output_dir)
    end
    if bitmap
        bitmap_dir = [input_dir '_bitmap'];
        if exist(bitmap_dir, 'dir')
            if ~isEmptyDirectory(bitmap_dir)
                deleteFileInDirectory(bitmap_dir);
            end
        else
            mkdir(bitmap_dir);
        end
    end

    
    % read input file
    if ~exist(input_dir, 'dir') || isEmptyDirectory(input_dir)
        error('Error: input directory %s not found or empty', input_dir);
        return
    else
        input_file = dir(input_dir);
        tmp_size = length(input_file);
        
        % input_cell = cell(1, input_size)
        input_size = 0;
        for idx = 1:tmp_size
            if ~input_file(idx).isdir
                filename = fullfile(input_file(idx).folder, input_file(idx).name);
                input_matrix{input_size + 1} = imread(filename);
                input_size = input_size + (1 - input_file(idx).isdir);
            end
        end
        fprintf('Input size = %d\n', input_size);
    end
    % get binary image
    for idx = 1:input_size
    % fprintf(, , )
        [hidth, width, channel] = size(input_matrix{idx});

        mat_thres = sum(sum(sum(input_matrix{idx}))) / (hidth * width * channel);
        % testing weighted binary
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % weight = (input_matrix{idx} > 127) .* double(abs(255 - input_matrix{idx})) * 0.1 + (input_matrix{idx} <= 127) .* double(abs(0 - input_matrix{idx})) * 0.1;
        % mat_thres = sum(sum(sum(double(input_matrix{idx}) .* weight))) / sum(sum(sum(weight)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sort_idx(idx).thres = mat_thres;
        sort_idx(idx).idx = idx;

        input_grey_matrix = sum(input_matrix{idx}, 3) / 3;
        grey_size = size(input_grey_matrix);
        % fprintf('grey matrix size = %d %d, dim = %d\n', grey_size(1), grey_size(2), length(grey_size));
        binary_matrix{idx} = zeros(hidth, width);
        binary_matrix{idx}(input_grey_matrix > mat_thres) = 1;
        
        % fprintf('light pixel %d, dark pixel %d\n', sum(sum(xor(0, binary_matrix{idx}))), sum(sum(xor(1, binary_matrix{idx}))));
        
        % output bitmap file
        if bitmap
            filename = sprintf('bitmap_%d', idx);
            output_path = fullfile(bitmap_dir, filename);
            imwrite(binary_matrix{idx}, output_path, 'jpg');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~, I] = sort(arrayfun (@(x) x.thres, sort_idx));
    sorted_idx = sort_idx(I);
    chosen_idx = sorted_idx(ceil(input_size / 2)).idx;
    fprintf('Chosen idx: %d\n', chosen_idx)

    base_binary_matrix = binary_matrix{chosen_idx};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % base_binary_matrix = binary_matrix{1};
    
    
    % testing alignment function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clear binary_matrix
    % clear base_binary_matrix
    
    % binary_matrix{1} = [1 1 1 1 0 1 1 1 0;...
    %                     1 1 0 1 0 1 0 0 1;...
    %                     1 1 1 0 0 1 1 0 0;...
    %                     1 0 1 1 0 1 1 1 0;...
    %                     0 0 0 1 0 0 1 0 0;...
    %                     0 1 0 1 0 1 1 0 1;...
    %                     1 1 1 0 0 1 1 0 1];
    % binary_matrix{2} = [1 1 1 0 0 1 1 1 0;...
    %                     1 1 0 1 0 0 0 1 1;...
    %                     1 0 1 1 0 1 1 0 1;...
    %                     1 0 1 1 0 1 1 1 0;...
    %                     0 0 1 1 1 0 1 0 0;...
    %                     0 0 0 1 0 1 1 0 1;...
    %                     1 1 1 0 0 1 1 0 1];
    % base_binary_matrix = binary_matrix{1};
    
    % input_size=2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    common_ver_lower = 1;
    common_ver_upper = hidth;

    common_hor_lower = 1;
    common_hor_upper = width;
    
    total_hor_movement = 0;
    total_ver_movement = 0;
    for idx = 1:input_size
    % default scale = 6
        [ver_move(idx), hor_move(idx)] = align(base_binary_matrix, binary_matrix{idx}, scale_num);
        fprintf('vertical move: %d, horizontal move: %d\n', ver_move(idx), hor_move(idx));
        common_ver_lower = max(common_ver_lower, common_ver_lower + ver_move(idx));
        common_ver_upper = min(common_ver_upper, common_ver_upper + ver_move(idx));
        common_hor_lower = max(common_hor_lower, common_hor_lower + hor_move(idx));
        common_hor_upper = min(common_hor_upper, common_hor_upper + hor_move(idx));
        fprintf('Current bound: vertical (%d ~ %d) horizontal (%d ~ %d)\n', common_ver_lower, common_ver_upper, common_hor_lower, common_hor_upper);
        total_ver_movement = total_ver_movement + abs(ver_move(idx)); 
        total_hor_movement = total_hor_movement + abs(hor_move(idx));
        total_movement = total_ver_movement + total_hor_movement;
    end
    clear binary_matrix
    
    fprintf('Total movement: %d, vertical %d, horizontal %d\n', total_movement, total_ver_movement, total_hor_movement);
    for idx = 1:input_size
        ver_lower = common_ver_lower - ver_move(idx);
        ver_upper = common_ver_upper - ver_move(idx);
        hor_lower = common_hor_lower - hor_move(idx);
        hor_upper = common_hor_upper - hor_move(idx);
        % fprintf('Image idx %d, vertical range = %d, horizontal range = %d\n', idx, ver_upper - ver_lower, hor_upper - hor_lower);
        filename = sprintf('%d', idx);
        output_path = fullfile(output_dir, filename);
        alignImg(:, :, :, idx) = input_matrix{idx}(ver_lower:ver_upper, hor_lower:hor_upper, :);
        imwrite(input_matrix{idx}(ver_lower:ver_upper, hor_lower:hor_upper, :), output_path, 'jpg');
    end
end 

function [ver_move, hor_move] = align(base_mat, mat, scale)
    % new (ver, hor)
    % (-, -)2 (-, 0)5 (-, +)7
    % (0, -)3 (0, 0)1 (0, +)8
    % (+, -)4 (+, 0)6 (+, +)9

    if scale == 0
        % no move
        prev_hor_move = 0;
        prev_ver_move = 0;
    else
        next_base_mat = base_mat(2:2:end, 2:2:end);
        next_mat = mat(2:2:end, 2:2:end);
        [prev_ver_move, prev_hor_move] = align(next_base_mat, next_mat, scale - 1);
    end
    
    ver_move = prev_ver_move * 2;
    hor_move = prev_hor_move * 2;
    

    % TODO: add scale prev move
    % fprintf('   Prev move from scale %d: vertical: %d, horrizontal: %d\n', scale - 1, prev_ver_move, prev_hor_move);
    % 1
    if prev_ver_move < 0 && prev_hor_move < 0
        base_mat = base_mat(1:end+2*prev_ver_move, 1:end+2*prev_hor_move);
        mat = mat(1-2*prev_ver_move:end, 1-2*prev_hor_move:end);
    % 2
    elseif prev_ver_move == 0 && prev_hor_move < 0
        base_mat = base_mat(:, 1:end+2*prev_hor_move);
        mat = mat(:, 1-2*prev_hor_move:end);
    % 3
    elseif prev_ver_move > 0 && prev_hor_move < 0
        base_mat = base_mat(1+2*prev_ver_move:end, 1:end+2*prev_hor_move);
        mat = mat(1:end-2*prev_ver_move, 1-2*prev_hor_move:end);
    % 4
    elseif prev_ver_move < 0 && prev_hor_move == 0
        base_mat = base_mat(1:end+2*prev_ver_move, :);
        mat = mat(1-2*prev_ver_move:end, :);
    % 5
    elseif prev_ver_move == 0 && prev_hor_move == 0
        base_mat = base_mat(:, :);
        mat = mat(:, :);
    % 6
    elseif prev_ver_move > 0 && prev_hor_move == 0
        base_mat = base_mat(1+2*prev_ver_move:end, :);
        mat = mat(1:end-2*prev_ver_move, :);
    % 7
    elseif prev_ver_move < 0 && prev_hor_move > 0
        base_mat = base_mat(1:end+2*prev_ver_move, 1+2*prev_hor_move:end);
        mat = mat(1-2*prev_ver_move:end, 1:end-2*prev_hor_move);
    % 8
    elseif prev_ver_move == 0 && prev_hor_move > 0
        base_mat = base_mat(:, 1+2*prev_hor_move:end);
        mat = mat(:, 1:end-2*prev_hor_move);
    % 9
    elseif prev_ver_move > 0 && prev_hor_move > 0
        base_mat = base_mat(1+2*prev_ver_move:end, 1+2*prev_hor_move:end);
        mat = mat(1:end-2*prev_ver_move, 1:end-2*prev_hor_move);
    end


    minimum_loss = inf;
    % 1 central first
    loss = compare(base_mat(), mat());
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 0;
        tmp_hor_move = 0;
        % fprintf('   Scale: %d,(1) (0, 0), current minimum: %5d\n', scale, loss);
    end
    % 2
    loss = compare(base_mat(1:end-1, 1:end-1), mat(2:end, 2:end));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = -1;
        tmp_hor_move = -1;
        % fprintf('   Scale: %d,(2) (-, -), current minimum: %5d\n', scale, loss);
    end
    % 3
    loss = compare(base_mat(:, 1:end-1), mat(:, 2:end));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 0;
        tmp_hor_move = -1;
        % fprintf('   Scale: %d,(3) (0, -), current minimum: %5d\n', scale, loss);
    end
    % 4
    loss = compare(base_mat(2:end, 1:end-1), mat(1:end-1, 2:end));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 1;
        tmp_hor_move = -1;
        % fprintf('   Scale: %d,(4) (+, -), current minimum: %5d\n', scale, loss);
    end
    % 5
    loss = compare(base_mat(1:end-1, :), mat(2:end, :));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = -1;
        tmp_hor_move = 0;
        % fprintf('   Scale: %d,(5) (-, 0), current minimum: %5d\n', scale, loss);
    end
    
    % 6
    loss = compare(base_mat(2:end, :), mat(1:end-1, :));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 1;
        tmp_hor_move = 0;
        % fprintf('   Scale: %d,(6) (+, 0), current minimum: %5d\n', scale, loss);
    end
    % 7
    loss = compare(base_mat(1:end-1, 2:end), mat(2:end, 1:end-1));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = -1;
        tmp_hor_move = 1;
        % fprintf('   Scale: %d,(7) (-, +), current minimum: %5d\n', scale, loss);
    end
    % 8
    loss = compare(base_mat(:, 2:end), mat(:, 1:end-1));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 0;
        tmp_hor_move = 1;
        % fprintf('   Scale: %d,(8) (0, +), current minimum: %5d\n', scale, loss);
    end
    % 9
    loss = compare(base_mat(2:end, 2:end), mat(1:end-1, 1:end-1));
    if loss < minimum_loss
        minimum_loss = loss;
        tmp_ver_move = 1;
        tmp_hor_move = 1;
        % fprintf('   Scale: %d,(9) (+, +), current minimum: %5d\n', scale, loss);
    end
    ver_move = ver_move + tmp_ver_move;
    hor_move = hor_move + tmp_hor_move;

end



function loss = compare(mat1, mat2)
    [hidth1, width1] = size(mat1);
    [hidth2, width2] = size(mat2);
    if hidth1 ~= hidth2 || width1 ~= width2
        error('Error: inconsistent matrix shape (%d %d) ~= (%d %d)', hidth1, width1, hidth2, width2);
    end
    % loss = sum(sum(abs(mat1 - mat2)))/(hidth1 * width1);
    loss = sum(sum(xor(mat1, mat2))) / (hidth1 * width1);
end

function empty = isEmptyDirectory(p)
    if isdir(p)
        f = dir(p);
        empty = ~(length(f) > 2);
    else
        error('Error: % is not a directory', p);
    end
end

function deleteFileInDirectory(p)
    file = dir(p);
    for idx = 1:length(file)
        if ~file(idx).isdir
        % if ~filename.isdir
            delete(fullfile(file(idx).folder, file(idx).name));
        end
    end
end