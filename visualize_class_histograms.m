% visualize_class_histograms.m
% Visualiza histogramas de cada canal para una clase específica y su fondo

function visualize_class_histograms(className)
    load('thresholds_all_classes.mat', 'umbral_all', 'canales_all');

    if ~isfield(umbral_all, className)
        error('Clase "%s" no encontrada en los umbrales cargados.', className);
    end

    baseDir = fullfile(pwd, 'Images', 'Classification');
    classDir = fullfile(baseDir, className);
    bgDir = fullfile(baseDir, 'background');
    
    % Leer primera imagen válida de la clase
    classImgs = dir(fullfile(classDir, '*.jpg'));
    bgImgs = dir(fullfile(bgDir, '*.png'));
    imgF = im2double(imread(fullfile(classDir, classImgs(1).name)));
    imgB = im2double(imread(fullfile(bgDir, bgImgs(1).name)));

    % Espacios de color
    hsvF = rgb2hsv(imgF); labF = rgb2lab(imgF); ycbcrF = rgb2ycbcr(imgF);
    hsvB = rgb2hsv(imgB); labB = rgb2lab(imgB); ycbcrB = rgb2ycbcr(imgB);

    % Máscaras (quita fondo blanco)
    maskF = ~(hsvF(:,:,3) > 0.9 & hsvF(:,:,2) < 0.2);
    maskB = ~(hsvB(:,:,3) > 0.9 & hsvB(:,:,2) < 0.2);

    % Canales definidos
    channels = {'R','G','B','H','S','V','L','a','b','Y','Cb','Cr'};
    dataF = extract_channels(imgF, hsvF, labF, ycbcrF);
    dataB = extract_channels(imgB, hsvB, labB, ycbcrB);

    % Mostrar histogramas de los canales seleccionados para la clase
    selected = canales_all.(className);
    thresholds = umbral_all.(className);

    figure('Name', ['Histogramas clase: ', className], 'NumberTitle', 'off');
    numPlots = length(selected);
    for i = 1:numPlots
        ch = selected{i};
        valsF = dataF.(ch);
        valsB = dataB.(ch);
        Qs = thresholds.(ch);

        % Aplicar máscaras
        vF = valsF(maskF);
        vB = valsB(maskB);

        subplot(1, numPlots, i);
        hold on;
        histogram(vF, 100, 'Normalization', 'probability', 'FaceColor', 'r', 'FaceAlpha', 0.4);
        histogram(vB, 100, 'Normalization', 'probability', 'FaceColor', 'b', 'FaceAlpha', 0.4);
        xline(Qs(1), '--k', 'Q1');
        xline(Qs(2), '--k', 'Q3');
        title(['Canal ', ch]);
        xlabel('Valor'); ylabel('Frecuencia');
        legend('Fruta','Fondo');
        grid on;
        hold off;
    end
end

% Extrae todos los canales en estructura
function out = extract_channels(rgb, hsv, lab, ycbcr)
    out.R  = mat2gray(rgb(:,:,1));
    out.G  = mat2gray(rgb(:,:,2));
    out.B  = mat2gray(rgb(:,:,3));
    out.H  = hsv(:,:,1);
    out.S  = hsv(:,:,2);
    out.V  = hsv(:,:,3);
    out.L  = mat2gray(lab(:,:,1));
    out.a  = mat2gray(lab(:,:,2));
    out.b  = mat2gray(lab(:,:,3));
    out.Y  = mat2gray(ycbcr(:,:,1));
    out.Cb = mat2gray(ycbcr(:,:,2));
    out.Cr = mat2gray(ycbcr(:,:,3));
end

