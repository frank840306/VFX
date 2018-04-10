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

oldpath = path;
% add src folder path 
path(oldpath, src_dir);

% image alignment
image_dir = fullfile(data_dir, input_dir);
tmp_dir = sprintf('%d_alignment', input_dir_idx);
alignment_dir = fullfile(data_dir, tmp_dir);
alignImg = alignImage(image_dir, alignment_dir, scale_num, output_bitmap);
size(alignImg)

% restore original path
path(oldpath)

exit