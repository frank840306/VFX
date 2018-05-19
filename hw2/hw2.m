clear all;
close all;

% parameter setting

% task = 'denny';     % denny for test, church for demo
% task = 'church';
% task = 'parrington';
% task = 'HSNU';
% task = 'csie';
% task = 'stage';
% task = 'grail';
task = 'social';
% task = 'lake1';
% task = 'lake2';

descriptor_thres = 0.8;
image_thres = 60;
cache = false;       % save and load mat file
saveCache = false;   % whether to save mat file

% cache = true;

% path setting
src_dir = './src';
res_dir = './res';
mat_dir = './mat';
data_dir = './data';
result_dir = './result';

old_path = path;
path(old_path, src_dir);


% createDirectory(res_dir, false);    % do not clear the dir
% createDirectory(mat_dir, false);    % do not clear the dir
createDirectory(result_dir, false);  % clear the dir

% read image
[images, img_size, img_h, img_w, channel] = readImage(data_dir, task);
focal_length = readFocalLength(data_dir, task);

if cache
    load(fullfile(mat_dir, 'warpedImages'));
else
    % inverse warping
    warpedImages = inverseWarping(images, img_size, img_h, img_w, channel, focal_length);
    if saveCache
        save(fullfile(mat_dir, 'warpedImages'), 'warpedImages');
    end
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
    end
    if saveCache
        save(fullfile(mat_dir, 'descriptors'), 'descriptors');
    end
end

if cache
    load(fullfile(mat_dir, 'panorama'));
    load(fullfile(mat_dir, 'accumulate_dy'));
else
    accumulate_dx = 0;
    accumulate_dy = 0;
    posi_thres = 0;
    nega_thres = 0;
    warpedImages = double(warpedImages);
    panorama = warpedImages(:, :, :, 1);
    for idx = 1:img_size - 1
        fprintf('===================== stitching %d and %d ====================\n', idx, idx + 1);
        pos1 = descriptors(:, 1:2, idx);
        pos2 = descriptors(:, 1:2, idx + 1);
        des1 = descriptors(:, 3:end, idx);
        des2 = descriptors(:, 3:end, idx + 1);
        matched_idx = matchDescriptor(des1, des2, descriptor_thres);
        % remove the outlier
        [match_pos1, match_pos2, s1, s2] = RANSAC(matched_idx, pos1, pos2, image_thres);
        % get the best dx and dy to align descriptor
        [dx, dy] = alignDescriptor(match_pos1, match_pos2);
        % dx is the horizontal move for image(idx+1) to match image(idx)
        % dy is the vertical move for image(idx+1) to match image(idx)
        accumulate_dx = accumulate_dx + dx;
        accumulate_dy = accumulate_dy + dy;
        fprintf('current dx: %d, current dy: %d, accumulated dx:%d, accumulated dy: %d\n', dx, dy, accumulate_dx, accumulate_dy);
        [panorama, posi_thres, nega_thres] = matchImage(panorama, warpedImages(:, :, :, idx + 1), accumulate_dx, accumulate_dy, posi_thres, nega_thres);
        fprintf('idx: %d, panorama size:(%d %d %d)\n', idx, size(panorama, 1), size(panorama, 2), size(panorama, 3));
    end
    if saveCache
        save(fullfile(mat_dir, 'panorama'), 'panorama');
        save(fullfile(mat_dir, 'accumulate_dy'), 'accumulate_dy');
    end
end

[h_p, w_p, c_p] = size(panorama);
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

panorama = seamCarving(panorama);


filename = sprintf('%s_panorama.png', task);
output_path = fullfile(result_dir, filename);
imwrite(panorama, output_path, 'png');
[h_p, w_p, c_p] = size(panorama);
fprintf('Final panorama size: (%d %d %d)\n', h_p, w_p, c_p);

% restore original path
path(old_path);
clear;