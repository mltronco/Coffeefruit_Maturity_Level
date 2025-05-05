% Script: calculate_channel_distances.m
% Description: Calculates statistical distances (Q1_fruit - Q3_background) 
% for each color channel to identify the most discriminative channels.

clc;
clear;

% === Step 1: Define paths ===
fruitDir = fullfile(pwd, 'Images', 'Classification', 'cereja', 'BoxPlot');
bgDir    = fullfile(pwd, 'Images', 'Classification', 'background');

fruitImgs = dir(fullfile(fruitDir, '*.jpg'));
bgImgs    = dir(fullfile(bgDir, '*.png'));

if isempty(fruitImgs) || isempty(bgImgs)
    error('No images found in one or both directories.');
end

channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};
fruitPixels = struct(); bgPixels = struct();

for i = 1:length(channels)
    fruitPixels.(channels{i}) = [];
    bgPixels.(channels{i}) = [];
end

% === Process fruit images ===
for i = 1:length(fruitImgs)
    img = imread(fullfile(fruitDir, fruitImgs(i).name));
    
    % RGB
    R_full = double(img(:,:,1));
    G_full = double(img(:,:,2));
    B_full = double(img(:,:,3));
    
    % HSV
    hsvImg = rgb2hsv(img);
    H_full = hsvImg(:,:,1);
    S_full = hsvImg(:,:,2);
    V_full = hsvImg(:,:,3);
    
    % CIELab
    labImg = rgb2lab(img);
    L_full = labImg(:,:,1);
    a_full = labImg(:,:,2);
    b_full = labImg(:,:,3);
    
    % YCbCr
    ycbcrImg = rgb2ycbcr(img);
    Y_full  = double(ycbcrImg(:,:,1));
    Cb_full = double(ycbcrImg(:,:,2));
    Cr_full = double(ycbcrImg(:,:,3));
    
    % HSV-based mask to remove light background
    mask = ~(V_full > 0.9 & S_full < 0.2);
    
    % Apply mask
    fruitPixels.R  = [fruitPixels.R;  R_full(mask)];
    fruitPixels.G  = [fruitPixels.G;  G_full(mask)];
    fruitPixels.B  = [fruitPixels.B;  B_full(mask)];
    fruitPixels.H  = [fruitPixels.H;  H_full(mask)];
    fruitPixels.S  = [fruitPixels.S;  S_full(mask)];
    fruitPixels.V  = [fruitPixels.V;  V_full(mask)];
    fruitPixels.L  = [fruitPixels.L;  L_full(mask)];
    fruitPixels.a  = [fruitPixels.a;  a_full(mask)];
    fruitPixels.b  = [fruitPixels.b;  b_full(mask)];
    fruitPixels.Y  = [fruitPixels.Y;  Y_full(mask)];
    fruitPixels.Cb = [fruitPixels.Cb; Cb_full(mask)];
    fruitPixels.Cr = [fruitPixels.Cr; Cr_full(mask)];
end

% === Process background images ===
for i = 1:length(bgImgs)
    img = imread(fullfile(bgDir, bgImgs(i).name));
    
    % RGB
    R_full = double(img(:,:,1));
    G_full = double(img(:,:,2));
    B_full = double(img(:,:,3));
    
    % HSV
    hsvImg = rgb2hsv(img);
    H_full = hsvImg(:,:,1);
    S_full = hsvImg(:,:,2);
    V_full = hsvImg(:,:,3);
    
    % CIELab
    labImg = rgb2lab(img);
    L_full = labImg(:,:,1);
    a_full = labImg(:,:,2);
    b_full = labImg(:,:,3);
    
    % YCbCr
    ycbcrImg = rgb2ycbcr(img);
    Y_full  = double(ycbcrImg(:,:,1));
    Cb_full = double(ycbcrImg(:,:,2));
    Cr_full = double(ycbcrImg(:,:,3));
    
    % HSV-based mask
    mask = ~(V_full > 0.9 & S_full < 0.2);
    
    % Apply mask
    bgPixels.R  = [bgPixels.R;  R_full(mask)];
    bgPixels.G  = [bgPixels.G;  G_full(mask)];
    bgPixels.B  = [bgPixels.B;  B_full(mask)];
    bgPixels.H  = [bgPixels.H;  H_full(mask)];
    bgPixels.S  = [bgPixels.S;  S_full(mask)];
    bgPixels.V  = [bgPixels.V;  V_full(mask)];
    bgPixels.L  = [bgPixels.L;  L_full(mask)];
    bgPixels.a  = [bgPixels.a;  a_full(mask)];
    bgPixels.b  = [bgPixels.b;  b_full(mask)];
    bgPixels.Y  = [bgPixels.Y;  Y_full(mask)];
    bgPixels.Cb = [bgPixels.Cb; Cb_full(mask)];
    bgPixels.Cr = [bgPixels.Cr; Cr_full(mask)];
end

% === Calculate Q1, Q3, and distances ===
fprintf('--- Channel separation (Q1_fruit - Q3_background) ---\n');
fprintf('%-4s | Q1_fruit | Q3_bg | Distance\n', 'Ch');
fprintf('-------------------------------\n');

results = {};
for i = 1:length(channels)
    ch = channels{i};
    Q1_fruit = prctile(fruitPixels.(ch), 25);
    Q3_bg    = prctile(bgPixels.(ch), 75);
    dist     = Q1_fruit - Q3_bg;

    results = [results; {ch, Q1_fruit, Q3_bg, dist}];
    fprintf('%-4s | %8.2f | %6.2f | %7.2f\n', ch, Q1_fruit, Q3_bg, dist); 
end

% === Save as table ===
T = cell2table(results, 'VariableNames', {'Channel','Q1_fruit','Q3_background','Distance'});
writetable(T, fullfile(pwd, 'channel_separation_scores.csv'));


