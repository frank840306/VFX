clear all;
close all;

% parameter setting

task = 'denny';     % denny for test, church for demo
% task = 'church';
% task = 'parrington';
% task = 'HSNU';
% task = 'csie';

% focal_length = 1000;
% focal_length = 1094.45; % pseudo 1094.45
% focal_length = 706.286; % pseudo 1094.45
focal_length = 1100;

descriptor_thres = 0.8;
image_thres = 60;
cache = false;       % save and load mat file
saveCache = true;   % whether to save mat file

% cache = true;

% path setting
src_dir = './src';
res_dir = './res';
mat_dir = './mat';
data_dir = './data';
result_dir = './result';

old_path = path;
path(old_path, src_dir);


createDirectory(res_dir, true);    % do not clear the dir
createDirectory(mat_dir, false);    % do not clear the dir
createDirectory(result_dir, false);  % clear the dir

% read image
[images, img_size, img_h, img_w, channel] = readImage(data_dir, task);
    
if cache
    load(fullfile(mat_dir, 'warpedImages'));
else
    % inverse warping
    warpedImages = inverseWarping(images, img_size, img_h, img_w, channel, focal_length);
    if saveCache
        save(fullfile(mat_dir, 'warpedImages'), 'warpedImages');
    end
end
% write warping images
for idx = 1:img_size
    filename = sprintf('%s_warp_%d.jpg', task, idx);
    output_path = fullfile(res_dir, filename);
    imwrite(squeeze(warpedImages(:, :, :, idx)), output_path, 'jpg');
end

% feature detection and description

if cache
    load(fullfile(mat_dir, 'descriptors'));
else
    descriptors = zeros(500, 66, img_size);
    for idx = 1:img_size
        disp(['Computing feature detection and description for image_' int2str(idx)])
        warpedImages_gray = rgb2gray(warpedImages(:, :, :, idx));
        descriptors(:, :, idx) = MSOP(warpedImages_gray);

        filename = [res_dir '/feature_' int2str(idx) '.png'];
        imwrite(insertMarker(warpedImages(:, :, :, idx), [round(descriptors(:, 1, idx)), round(descriptors(:, 2, idx))]), filename);
    end
    if saveCache
        save(fullfile(mat_dir, 'descriptors'), 'descriptors');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% total_dy = 0;
if cache
    load(fullfile(mat_dir, 'panorama'));
    load(fullfile(mat_dir, 'accumulate_dy'));
else
    accumulate_dx = 0;
    accumulate_dy = 0;
    posi_thres = 0;
    nega_thres = 0;
    panorama = warpedImages(:, :, :, 1);
    for idx = 1:img_size - 1
    % for idx = 1:5 
        % TODO: pos only need to get x and y
        fprintf('===================== stitching %d and %d ====================\n', idx, idx + 1);
        pos1 = descriptors(:, 1:2, idx);
        pos2 = descriptors(:, 1:2, idx + 1);
        
        des1 = descriptors(:, 3:end, idx);
        des2 = descriptors(:, 3:end, idx + 1);
        % find the matched descriptor
        matched_idx = matchDescriptor(des1, des2, descriptor_thres);
        plotMatchLink(warpedImages(:, :, :, idx), warpedImages(:, :, :, idx + 1), pos1(matched_idx(:, 1), :), pos2(matched_idx(:, 2), :), sprintf('res/matchDrscriptor_compare%d_%d.png', idx, idx+1));
        
        % remove the outlier
        [match_pos1, match_pos2, s1, s2] = RANSAC(matched_idx, pos1, pos2, image_thres);
        fprintf('match descriptor size: %d\n', size(match_pos1, 1));
        plotMatchLink(warpedImages(:, :, :, idx), warpedImages(:, :, :, idx + 1), match_pos1, match_pos2, sprintf('res/ransac_compare%d_%d.png', idx, idx+1));
        plotMatchLink(warpedImages(:, :, :, idx), warpedImages(:, :, :, idx + 1), s1, s2, sprintf('res/ransac_sample_compare%d_%d.png', idx, idx+1));
        
        % get the best dx and dy to align descriptor
        [dx, dy] = alignDescriptor(match_pos1, match_pos2);
        % dx is the horizontal move for image(idx+1) to match image(idx)
        % dy is the vertical move for image(idx+1) to match image(idx)

        accumulate_dx = accumulate_dx + dx;
        accumulate_dy = accumulate_dy + dy;
        fprintf('current dx: %d, current dy: %d, accumulated dx:%d, accumulated dy: %d\n', dx, dy, accumulate_dx, accumulate_dy);
        [panorama, posi_thres, nega_thres] = matchImage(panorama, warpedImages(:, :, :, idx + 1), accumulate_dx, accumulate_dy, posi_thres, nega_thres);
        fprintf('idx: %d, panorama size:(%d %d %d)\n', idx, size(panorama, 1), size(panorama, 2), size(panorama, 3));

        filename = sprintf('%s_panorama_%d_%d.png', task, 1, idx + 1);
        output_path = fullfile(res_dir, filename);
        imwrite(panorama, output_path, 'png');
        % break;
    end
    if saveCache
        save(fullfile(mat_dir, 'panorama'), 'panorama');
        save(fullfile(mat_dir, 'accumulate_dy'), 'accumulate_dy');
    end
end

% TODO: 拉正
[h_p, w_p, c_p] = size(panorama);
fprintf('Panorama size: (%d %d %d)\n', h_p, w_p, c_p);
if accumulate_dy >= 0
    h_start = 0:accumulate_dy / (w_p - 1):accumulate_dy;
else
    h_start = abs(accumulate_dy):accumulate_dy / (w_p - 1): 0;
end

h_start = int32(h_start);
for w = 1:w_p
    panorama(1:img_h, w, :) = panorama(h_start(w) + 1:h_start(w) + img_h, w, :);
    panorama(img_h+1:end, w, :) = 0;
end
panorama = panorama(1:img_h, :, :);
[h_p, w_p, c_p] = size(panorama);
fprintf('Panorama size: (%d %d %d)\n', h_p, w_p, c_p);


panorama = seamCarving(panorama);


filename = sprintf('%s_panorama.png', task);
output_path = fullfile(result_dir, filename);
imwrite(panorama(1:img_h, :, :), output_path, 'png');
[h_p, w_p, c_p] = size(panorama);
fprintf('Panorama size: (%d %d %d)\n', h_p, w_p, c_p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% restore original path
path(old_path);
clear;