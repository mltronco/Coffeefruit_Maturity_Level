function generate_thresholds_all_classes()

baseDir = fullfile(pwd, 'Images', 'Classification');
folders = dir(baseDir);
classes = {folders([folders.isdir] & ~ismember({folders.name}, {'.', '..', 'background'})).name};
channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};

umbral_all = struct();
canales_all = struct();
pesos_all = struct();

bgDir = fullfile(baseDir, 'background');
bgImgs = dir(fullfile(bgDir, '*.png'));
bgPixels = initialize_pixel_struct(channels);


for i = 1:length(bgImgs)
    img = enhance_contrast(im2double(imread(fullfile(bgDir, bgImgs(i).name))));
    hsv = rgb2hsv(img); lab = rgb2lab(img); ycbcr = rgb2ycbcr(img);

    white_mask = refine_white_mask(hsv);
    mask = ~white_mask;

    bgPixels = append_pixels(img, hsv, lab, ycbcr, mask, bgPixels);
end

for c = 1:length(classes)
    className = classes{c};
    classDir = fullfile(baseDir, className);
    fruitImgs = dir(fullfile(classDir, '*.jpg'));

    Q1_total = initialize_pixel_struct(channels);
    Q3_total = initialize_pixel_struct(channels);

    for i = 1:length(fruitImgs)
        img = enhance_contrast(im2double(imread(fullfile(classDir, fruitImgs(i).name))));
        hsv = rgb2hsv(img); lab = rgb2lab(img); ycbcr = rgb2ycbcr(img);

        white_mask = refine_white_mask(hsv);
        mask = ~white_mask;

        block_pixels = extract_pixels(img, hsv, lab, ycbcr, mask);
        for ch = channels
            ch_name = ch{1};
            Q1_total.(ch_name) = [Q1_total.(ch_name); prctile(block_pixels.(ch_name), 25)];
            Q3_total.(ch_name) = [Q3_total.(ch_name); prctile(block_pixels.(ch_name), 75)];
        end
    end

    metricas = [];
    for i = 1:length(channels)
        ch = channels{i};
        if isempty(Q1_total.(ch)), continue; end

        Q1f = mean(Q1_total.(ch));
        Q3f = mean(Q3_total.(ch));
        StdF = std([Q1_total.(ch); Q3_total.(ch)]);

        Q1b = prctile(bgPixels.(ch), 25);
        Q3b = prctile(bgPixels.(ch), 75);

        if Q3f > Q3b
            dist = Q1f - Q3b;
            valid = Q1f > Q3b;
        else
            dist = Q1b - Q3f;
            valid = Q1b > Q3f;
        end

        ratio = dist / (StdF + eps);

        if valid && dist > 0 && ratio > 0.1
            metricas = [metricas; {ch, dist, Q1f, Q3f, StdF, ratio}];
        end
    end

    if isempty(metricas)
        warning('Clase "%s" no tiene canales válidos.', className);
        continue;
    end

    T = cell2table(metricas, 'VariableNames', {'Channel','Distance','Q1','Q3','StdF','Ratio'});
    T = sortrows(T, 'Ratio', 'descend');

    alpha = 0.2;
    top3 = T(1:min(3, height(T)), :);
    rest = T(4:end, :);

    pesos_top = [0.15, 0.10, 0.05];
    if height(rest) > 0
        pesos_rest = ones(1, height(rest)) * (0.4 / height(rest));
    else
        pesos_rest = [];
    end

    canales_all.(className) = [top3.Channel; rest.Channel]';
    pesos_all.(className) = [pesos_top(1:height(top3)), pesos_rest];

    umbral_all.(className) = struct();
    T_combined = [top3; rest];
    for i = 1:height(T_combined)
        IQR = T_combined.Q3(i) - T_combined.Q1(i);
        Q1_adj = T_combined.Q1(i) - alpha * IQR;
        Q3_adj = T_combined.Q3(i) + alpha * IQR;
        umbral_all.(className).(T_combined.Channel{i}) = [Q1_adj, Q3_adj];
    end
end

save('thresholds_all_classes.mat', 'umbral_all', 'canales_all', 'pesos_all');
end

%% Funciones auxiliares

function mask = refine_white_mask(hsv)
    blurred = imgaussfilt(hsv(:,:,3), 0.7);
    mask = (blurred > 0.82 & hsv(:,:,2) < 0.23);
    mask = imopen(mask, strel('disk', 1));
    mask = imclose(mask, strel('disk', 2));
    mask = imfill(mask, 'holes');
end

function out = enhance_contrast(img)
    lab = rgb2lab(img);
    L = lab(:,:,1)/100;
    L_eq = adapthisteq(L, 'NumTiles', [8 8], 'ClipLimit', 0.01);
    lab(:,:,1) = L_eq * 100;
    out = lab2rgb(lab);
end

function out = initialize_pixel_struct(channels)
    out = struct();
    for i = 1:length(channels)
        out.(channels{i}) = [];
    end
end

function out = extract_pixels(rgb, hsv, lab, ycbcr, mask)
    out.R  = rgb(:,:,1);  out.R  = out.R(mask);
    out.G  = rgb(:,:,2);  out.G  = out.G(mask);
    out.B  = rgb(:,:,3);  out.B  = out.B(mask);
    out.H  = hsv(:,:,1);  out.H  = out.H(mask);
    out.S  = hsv(:,:,2);  out.S  = out.S(mask);
    out.V  = hsv(:,:,3);  out.V  = out.V(mask);
    out.L  = lab(:,:,1);  out.L  = out.L(mask);
    out.a  = lab(:,:,2);  out.a  = out.a(mask);
    out.b  = lab(:,:,3);  out.b  = out.b(mask);
    out.Y  = ycbcr(:,:,1);out.Y  = out.Y(mask);
    out.Cb = ycbcr(:,:,2);out.Cb = out.Cb(mask);
    out.Cr = ycbcr(:,:,3);out.Cr = out.Cr(mask);
end

function out = append_pixels(rgb, hsv, lab, ycbcr, mask, out)
    tmp = rgb(:,:,1);  out.R  = [out.R;  tmp(mask)];
    tmp = rgb(:,:,2);  out.G  = [out.G;  tmp(mask)];
    tmp = rgb(:,:,3);  out.B  = [out.B;  tmp(mask)];
    tmp = hsv(:,:,1);  out.H  = [out.H;  tmp(mask)];
    tmp = hsv(:,:,2);  out.S  = [out.S;  tmp(mask)];
    tmp = hsv(:,:,3);  out.V  = [out.V;  tmp(mask)];
    tmp = lab(:,:,1);  out.L  = [out.L;  tmp(mask)];
    tmp = lab(:,:,2);  out.a  = [out.a;  tmp(mask)];
    tmp = lab(:,:,3);  out.b  = [out.b;  tmp(mask)];
    tmp = ycbcr(:,:,1);out.Y  = [out.Y;  tmp(mask)];
    tmp = ycbcr(:,:,2);out.Cb = [out.Cb; tmp(mask)];
    tmp = ycbcr(:,:,3);out.Cr = [out.Cr; tmp(mask)];
end






