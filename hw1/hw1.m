clear all;
close all;
 

% alignment parameter 
scale_num = 5;          % the number of time to scale image
output_bitmap = false;
%%%%%%%%%%%%%%%%%%%%%%%%%
input_dir_idx = 1;      % the index of input image folder
use_compress = false;   % currently compressed image only because of the insufficiency RAM
if use_compress
    input_dir = sprintf('%d_compressed', input_dir_idx);
else
    input_dir = sprintf('%d', input_dir_idx);
end

% setting directory
src_dir = './src';
data_dir = './data';
output_dir = './result';

oldpath = path;
% add src folder path 
path(oldpath, src_dir);

% image alignment
image_dir = fullfile(data_dir, input_dir);
tmp_dir = sprintf('%d_alignment', input_dir_idx);
alignment_dir = fullfile(data_dir, tmp_dir);
alignImg = alignImage(image_dir, alignment_dir, scale_num, output_bitmap);
% size(alignImg)

% make output directory
if exist(output_dir, 'dir')
    if ~isEmptyDirectory(output_dir)
        deleteFileInDirectory(output_dir)    
    end
else
    mkdir(output_dir)
end

% construct HDR image
exposure_time = [1/50, 1/80, 1/100, 1/125, 1/160, 1/200, 1/250, 1/320, 1/400, 1/500, 1/640, 1/800, 1/1000, 1/1250, 1/1600];
image_num = length(exposure_time);
HDRImage(alignImg, exposure_time, image_num, './result/HDR.hdr');

% global tone mapping
photographicGlobal('./result/HDR.hdr', 1.5, 100, './result/global_tm.jpg');

% restore original path
path(oldpath)

clear;
% exit