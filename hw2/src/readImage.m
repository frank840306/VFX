function [images, img_size, img_h, img_w, channel] = readImage(data_dir, task)
%myFun - Description
%
% Syntax: images = readImage(data_dir, task)
%
% Long description
    image_name_list = get_name_list(data_dir, task);
    
    img_size = length(image_name_list);
    % for idx = 1: img_size
    %     disp(image_name_list{idx});
    % end
    for idx = 1:img_size
        fprintf('image: %s\n', image_name_list{idx});
        images(:, :, :, idx) = imread(image_name_list{idx});
        if idx == 1
            [img_h, img_w, channel] = size(squeeze(images(:, :, :, idx)));    
        end
    end
    fprintf('Input task [ %s ] size: %d, height: %d, width: %d, channel: %d\n', task, img_size, img_h, img_w, channel);
end

function image_name_list = get_name_list(data_dir, task)

    if strcmp(task, 'denny')
        name_template = task;    
    elseif strcmp(task, 'church')
        name_template = 'IMG_';
    elseif strcmp(task, 'parrington')
        name_template = 'prtn';
    elseif strcmp(task, 'HSNU')
        name_template = 'h_';
    elseif strcmp(task, 'stage')
        name_template = 's_';
    elseif strcmp(task, 'csie')
        name_template = 'IMG_';
    elseif strcmp(task, 'grail')
        name_template = 'grail';
    elseif strcmp(task, 'social')
        name_template = 'IMG_';
    elseif strcmp(task, 'lake1')
        name_template = 'lake1';
    elseif strcmp(task, 'lake2')
        name_template = 'IMG_';
    else
        error('Error: Unknown task: %s', task);
    end
        
    image_dir = fullfile(data_dir, task);

    if ~exist(image_dir, 'dir') || isEmptyDirectory(image_dir)
        error('Error: input directory %s not found or empty', image_dir);
    else
        
        all_file = dir(image_dir);
        all_size = length(all_file);
        
        is_image = strncmpi({all_file.name}, name_template, length(name_template));
        image_idx = 1;
        for idx = 1:all_size
            if ~all_file(idx).isdir && is_image(idx)
                % fprintf('%s', all_file(idx).name);
                image_name_list{image_idx} = fullfile(image_dir, all_file(idx).name);
                image_idx = image_idx + 1;
            end
        end
        [image_name_list, idx] = sort(image_name_list);
    end
end