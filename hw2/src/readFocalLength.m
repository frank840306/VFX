function focal_length = readFocalLength(data_dir, task)
    fileID = fopen(fullfile(data_dir, task, 'focal_length.txt'));
    focal_length = fscanf(fileID, '%f');
end
