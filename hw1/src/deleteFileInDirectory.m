function deleteFileInDirectory(p)
    file = dir(p);
    for idx = 1:length(file)
        if ~file(idx).isdir
        % if ~filename.isdir
            delete(fullfile(file(idx).folder, file(idx).name));
        end
    end
end