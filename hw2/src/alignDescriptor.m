function [dx, dy] = alignDescriptor(pos1, pos2)
%myFun - Description
%
% Syntax: [dx, dy] = alignDescriptor(pos1, pos2)
%
% Long description
    
    pos_size = size(pos1, 1);
    A = zeros(2 * pos_size + 1, 3);
    b = zeros(2 * pos_size + 1, 1);
    for idx = 1:pos_size
        x_or_y = floor((idx - 1) / pos_size) + 1;   % 1 for x, 2 for y    
        A(idx, x_or_y) = 1;
        A(idx, 3) = pos2(idx, x_or_y);
        b(idx, 1) = pos1(idx, x_or_y);
    end
    A(2 * pos_size + 1, 3) = 1;
    b(2 * pos_size + 1, 1) = 1;

    delta = round(A \ b);
    fprintf('A size (%d %d), b size (%d %d), delta size (%d %d)\n', size(A, 1), size(A, 2), size(b, 1), size(b, 2), size(delta, 1), size(delta, 2));
    % delta(3) = [];
    dx = delta(1);
    dy = delta(2);
    fprintf('dx = %d, dy = %d\n', dx, dy);
end