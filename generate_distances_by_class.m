function generate_distances_by_class()

baseDir = fullfile(pwd, 'Images', 'Classification');
bgDir = fullfile(baseDir, 'background');
classes = {'verde', 'verdolengo', 'cereja', 'passa'};
channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};

bgImgs = dir(fullfile(bgDir, '*.png'));
bg = initialize_pixel_struct(channels);

for i = 1:length(bgImgs)
    img = imread(fullfile(bgDir, bgImgs(i).name));
    hsv = rgb2hsv(img);
    lab = rgb2lab(img);
    ycbcr = double(rgb2ycbcr(img));
    mask = ~(hsv(:,:,3) > 0.9 & hsv(:,:,2) < 0.2);

    bg = append_pixels(img, hsv, lab, ycbcr, mask, bg);
end

Q3_background = struct();
for i = 1:length(channels)
    ch = channels{i};
    Q3_background.(ch) = prctile(bg.(ch), 75);
end

dist_matrix = [];

for c = 1:length(classes)
    className = classes{c};
    classDir = fullfile(baseDir, className);
    imgs = dir(fullfile(classDir, '*.jpg'));
    if isempty(imgs)
        imgs = dir(fullfile(classDir, '*.png'));
    end

    px = initialize_pixel_struct(channels);

    for i = 1:length(imgs)
        img = imread(fullfile(classDir, imgs(i).name));
        hsv = rgb2hsv(img);
        lab = rgb2lab(img);
        ycbcr = double(rgb2ycbcr(img));
        mask = ~(hsv(:,:,3) > 0.9 & hsv(:,:,2) < 0.2);
        px = append_pixels(img, hsv, lab, ycbcr, mask, px);
    end

    row = zeros(1, length(channels));
    for i = 1:length(channels)
        ch = channels{i};
        Q1f = prctile(px.(ch), 25);
        dist = Q1f - Q3_background.(ch);
        row(i) = dist;
    end

    dist_matrix = [dist_matrix; row];
end

T = array2table(dist_matrix, 'VariableNames', channels, ...
    'RowNames', upper(classes));
writetable(T, 'distancias_por_classe.csv', 'WriteRowNames', true);
end

function out = initialize_pixel_struct(channels)
    out = struct();
    for i = 1:length(channels)
        out.(channels{i}) = [];
    end
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
