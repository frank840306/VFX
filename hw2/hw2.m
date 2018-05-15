clear all;
close all;

% parameter setting

% task = 'denny';     % denny for test, church for demo
% task = 'church';
task = 'parrington';
% focal_length = 1000;
% focal_length = 1094.45; % pseudo 1094.45
focal_length = 706.286; % pseudo 1094.45
descriptor_thres = 0.8;
image_thres = 60;
cache = false;       % save and load mat file
saveCache = true;   % whether to save mat file

cache = true;

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
createDirectory(result_dir, true);  % clear the dir


% read image
[images, img_size, img_h, img_w, channel] = readImage(data_dir, task);

% inverse warping
% if cache
%     load(fullfile(mat_dir, 'warpedImages'));
% else
warpedImages = inverseWarping(images, img_size, img_h, img_w, channel, focal_length);
if saveCache
    save(fullfile(mat_dir, 'warpedImages'), 'warpedImages');
end
% end
% img_size = 6;
% write warping images
for idx = 1:img_size
    filename = sprintf('%s_warp_%d.jpg', task, idx);
    output_path = fullfile(res_dir, filename);
    imwrite(squeeze(warpedImages(:, :, :, idx)), output_path, 'jpg');
end

% feature detection and description

% if cache
%     load(fullfile(mat_dir, 'descriptors'));
% else
descriptors = zeros(500, 66, img_size);
for idx = 1:img_size
    disp(['Computing feature detection and description for image_' int2str(idx)])
    warpedImages_gray = rgb2gray(warpedImages(:, :, :, idx));
    descriptors(:, :, idx) = MSOP(warpedImages_gray);

    filename = [res_dir '/feature_' int2str(idx) '.png'];
    imwrite(insertMarker(warpedImages(:, :, :, idx), [round(descriptors(:, 1, idx)), round(descriptors(:, 2, idx))]), filename);
end
%     if saveCache
%         save(fullfile(mat_dir, 'descriptors'), 'descriptors');
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% total_dy = 0;
accumulate_dx = 0;
panorama = warpedImages(:, :, :, 1);
for idx = 1:img_size - 1
    % TODO: pos only need to get x and y
    
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
    panorama = matchImage(panorama, warpedImages(:, :, :, idx + 1), dx + accumulate_dx, dy);
    accumulate_dx = accumulate_dx + dx;
    fprintf('idx: %d, panorama size:(%d %d %d), current dx: %d, accumulated dx:%d\n', idx, size(panorama, 1), size(panorama, 2), size(panorama, 3), dx, accumulate_dx);
    
    filename = sprintf('%s_panorama_%d.jpg', task, idx);
    output_path = fullfile(res_dir, filename);
    imwrite(panorama, output_path, 'jpg');
    % total_dy = total_dy + delta{idx}(2);
    % break;
    
end

filename = sprintf('%s_panorama.jpg', task);
output_path = fullfile(result_dir, filename);
imwrite(panorama, output_path, 'jpg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% restore original path
path(old_path);
clear;