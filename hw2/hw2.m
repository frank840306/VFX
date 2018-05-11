clear all;
close all;

% parameter setting

task = 'denny';     % denny for test, church for demo
% task = 'church';
% focal_length = 1.7 * 25;
focal_length = 800; % pseudo 
% path setting
src_dir = './src';
res_dir = './res';
data_dir = './data';
result_dir = './result';

old_path = path;
path(old_path, src_dir);

if exist(res_dir, 'dir')
    if ~isEmptyDirectory(res_dir)
        deleteFileInDirectory(res_dir);
    end    
else
    mkdir(res_dir);
end
% read image
[images, img_size, img_h, img_w, channel] = readImage(data_dir, task);

% inverse warping
warpingImages = inverseWarping(images, img_size, img_h, img_w, channel, focal_length);

% write warping images
for idx = 1:img_size
    filename = sprintf('%s_warp_%d.jpg', task, idx);
    output_path = fullfile(res_dir, filename);
    imwrite(squeeze(warpingImages(:, :, :, idx)), output_path, 'jpg');
end

% feature detection



% image stitching

% image blending


% restore original path
path(old_path);
clear;