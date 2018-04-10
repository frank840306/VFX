function photographicGlobal(HDR_filename, a, white, output)
    
    delta = 1e-6;
    hdr = hdrread(HDR_filename);
    
    Lw = 0.2126 * hdr(:, :, 1) + 0.7152 * hdr(:, :, 2) + 0.0722 * hdr(:, :, 3);
    N = size(hdr, 1) * size(hdr, 2);
    Lw_mean = exp((1 / N) * sum(sum(log(delta + Lw))));
    
    Lm = (a / Lw_mean) * Lw;
    Ld = (Lm .* (1 + (Lm / (white^2)))) ./ (1 + Lm);
    
    ldr = zeros(size(hdr));
    for i = 1:3
        Cw = hdr(:, :, i) ./ Lw;
        ldr(:, :, i) = Cw .* Ld;
    end
    imwrite(ldr, output);
    
    clear;
end