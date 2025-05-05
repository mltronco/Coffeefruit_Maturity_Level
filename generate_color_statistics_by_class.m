% Script: generate_color_statistics_by_class.m
% Description: Generate Q1, Median, and Q3 values for each color channel per class.

clc;
clear;

% === Step 1: Define class names ===
classes = {'green', 'green_oliva', 'cherry', 'raisin'};
channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};

% === Step 2: Prepare output structure ===
rows = {};
rowLabels = {};

% === Step 3: Loop through each class ===
for c = 1:length(classes)
    className = classes{c};
    classDir = fullfile(pwd, 'Images', 'Classification', className);
    files = dir(fullfile(classDir, '*.jpg'));

    % === Initialize pixel containers ===
    channelPixels = struct();
    for ch = channels
        channelPixels.(ch{1}) = [];
    end

    % === Process all images in the class ===
    for i = 1:length(files)
        img = imread(fullfile(classDir, files(i).name));
        
        % Convert to necessary color spaces
        R_full = double(img(:,:,1));
        G_full = double(img(:,:,2));
        B_full = double(img(:,:,3));
        hsvImg = rgb2hsv(img); labImg = rgb2lab(img); ycbcrImg = rgb2ycbcr(img);
        H_full = hsvImg(:,:,1);
        S_full = hsvImg(:,:,2);
        V_full = hsvImg(:,:,3);
        L_full = labImg(:,:,1);
        a_full = labImg(:,:,2);
        b_full = labImg(:,:,3);
        Y_full  = double(ycbcrImg(:,:,1));
        Cb_full = double(ycbcrImg(:,:,2));
        Cr_full = double(ycbcrImg(:,:,3));
        
        % Optional HSV mask (exclude white background)
        mask = ~(V_full > 0.9 & S_full < 0.2);
        
        % Append masked pixel values
        channelPixels.R  = [channelPixels.R; R_full(mask)];
        channelPixels.G  = [channelPixels.G; G_full(mask)];
        channelPixels.B  = [channelPixels.B; B_full(mask)];
        channelPixels.H  = [channelPixels.H; H_full(mask)];
        channelPixels.S  = [channelPixels.S; S_full(mask)];
        channelPixels.V  = [channelPixels.V; V_full(mask)];
        channelPixels.L  = [channelPixels.L; L_full(mask)];
        channelPixels.a  = [channelPixels.a; a_full(mask)];
        channelPixels.b  = [channelPixels.b; b_full(mask)];
        channelPixels.Y  = [channelPixels.Y; Y_full(mask)];
        channelPixels.Cb = [channelPixels.Cb; Cb_full(mask)];
        channelPixels.Cr = [channelPixels.Cr; Cr_full(mask)];
    end

    % === Calculate Q1, Median, Q3 for each channel ===
    Q1_row = []; Median_row = []; Q3_row = [];

    for ch = channels
        data = channelPixels.(ch{1});
        Q1 = prctile(data, 25);
        Median = median(data);
        Q3 = prctile(data, 75);

        Q1_row = [Q1_row, Q1];
        Median_row = [Median_row, Median];
        Q3_row = [Q3_row, Q3];
    end

    % Store in rows
    rows = [rows; Q3_row; Median_row; Q1_row];
    rowLabels = [rowLabels; ...
        [className, ' 3rd quartile']; ...
        [className, ' Median']; ...
        [className, ' 1st quartile']];
end

% === Step 4: Create and save table ===
T = cell2table(rows, 'VariableNames', channels, 'RowNames', rowLabels);
writetable(T, fullfile(pwd, 'quartile_statistics_all_classes.csv'), 'WriteRowNames', true);

disp('? Table saved as quartile_statistics_all_classes.csv');
