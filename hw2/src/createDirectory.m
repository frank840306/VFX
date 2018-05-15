function createDirectory(dir_name, clear_flag)
%myFun - Description
%
% Syntax: createDirectory(dir_name)
%
% Long description
    if exist(dir_name, 'dir')
        if ~isEmptyDirectory(dir_name) && clear_flag
            deleteFileInDirectory(dir_name);
        end    
    else
        mkdir(dir_name);
    end 
end