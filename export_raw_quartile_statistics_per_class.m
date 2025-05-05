function export_raw_quartile_statistics_per_class()

baseDir = fullfile(pwd, 'Images', 'Classification');
folders = dir(baseDir);
classes = {folders([folders.isdir] & ~ismember({folders.name}, {'.', '..'})).name};

channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};
quartile_data = [];
rowLabels = {};

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
        hsv = rgb2hsv(img); lab = rgb2lab(img); ycbcr = rgb2ycbcr(img);

        px.R  = [px.R;  reshape(img(:,:,1), [], 1)];
        px.G  = [px.G;  reshape(img(:,:,2), [], 1)];
        px.B  = [px.B;  reshape(img(:,:,3), [], 1)];
        px.H  = [px.H;  reshape(hsv(:,:,1), [], 1)];
        px.S  = [px.S;  reshape(hsv(:,:,2), [], 1)];
        px.V  = [px.V;  reshape(hsv(:,:,3), [], 1)];
        px.L  = [px.L;  reshape(lab(:,:,1), [], 1)];
        px.a  = [px.a;  reshape(lab(:,:,2), [], 1)];
        px.b  = [px.b;  reshape(lab(:,:,3), [], 1)];
        px.Y  = [px.Y;  reshape(ycbcr(:,:,1), [], 1)];
        px.Cb = [px.Cb; reshape(ycbcr(:,:,2), [], 1)];
        px.Cr = [px.Cr; reshape(ycbcr(:,:,3), [], 1)];
    end

    rowLabels = [rowLabels; ...
        [upper(className), ' 3rd quartile']; ...
        [upper(className), ' Median']; ...
        [upper(className), ' 1st quartile']];

    rowQ3 = []; rowMedian = []; rowQ1 = [];

    for ch = channels
        values = px.(ch{1});
        rowQ1     = [rowQ1, prctile(values, 25)];
        rowMedian = [rowMedian, median(values)];
        rowQ3     = [rowQ3, prctile(values, 75)];
    end

    quartile_data = [quartile_data; rowQ3; rowMedian; rowQ1];
end

T = array2table(quartile_data, 'VariableNames', channels, 'RowNames', rowLabels);
writetable(T, 'quartilsporclasse.csv', 'WriteRowNames', true);

end

function out = initialize_pixel_struct(channels)
    out = struct();
    for i = 1:length(channels)
        out.(channels{i}) = [];
    end
end

