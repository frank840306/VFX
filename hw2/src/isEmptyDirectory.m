function empty = isEmptyDirectory(p)
    if isdir(p)
        f = dir(p);
        empty = ~(length(f) > 2);
    else
        error('Error: % is not a directory', p);
    end
end