clc;
clear;

%% === STEP 1: Define base path ===
basePath = fullfile(pwd);  % current folder
ramaPrefix = 'Rama';
ramaDirs = dir(fullfile(basePath, [ramaPrefix, '*']));

%% === STEP 2: Determine next Rama folder name ===
nextRamaNum = length(ramaDirs) + 1;
ramaName = sprintf('%s%d', ramaPrefix, nextRamaNum);
ramaPath = fullfile(basePath, ramaName);

%% Create RamaX directory
mkdir(ramaPath);
fprintf('Created folder: %s\n', ramaPath);

%% STEP 3: Determine next Nodo folder name inside Rama ===
nodoPrefix = 'Nodo';
existingNodos = dir(fullfile(ramaPath, [nodoPrefix, '*']));
nextNodoNum = length(existingNodos) + 1;
nodoName = sprintf('%s%d', nodoPrefix, nextNodoNum);
nodoPath = fullfile(ramaPath, nodoName);
mkdir(nodoPath);
fprintf('Created folder: %s\n', nodoPath);

%% % Check if there are at least 4 webcams
availableCams = webcamlist;

if length(availableCams) < 4
    error('At least 4 webcams are required. Only %d detected.', length(availableCams));
end

%% Initialize webcam objects
cam1 = webcam(1);
cam2 = webcam(2);
cam3 = webcam(3);
cam4 = webcam(4);

%%  Capture one frame from each camera
img1 = snapshot(cam1);
img2 = snapshot(cam2);
img3 = snapshot(cam3);
img4 = snapshot(cam4);

%% Display captured images
figure('Name', 'Captured Images from 4 Cameras');
subplot(2,2,1); imshow(img1); title('Camera 1');
subplot(2,2,2); imshow(img2); title('Camera 2');
subplot(2,2,3); imshow(img3); title('Camera 3');
subplot(2,2,4); imshow(img4); title('Camera 4');

clear cam1 cam2 cam3 cam4;

%% Save images for later use
imwrite(img1, fullfile(nodoPath, 'IMG1.jpg'));
imwrite(img2, fullfile(nodoPath, 'IMG2.jpg'));
imwrite(img3, fullfile(nodoPath, 'IMG3.jpg'));
imwrite(img4, fullfile(nodoPath, 'IMG4.jpg'));
