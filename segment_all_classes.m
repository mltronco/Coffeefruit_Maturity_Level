function segmented_all = segment_all_classes(img_path)

 
    load('thresholds_all_classes.mat', 'umbral_all', 'canales_all', 'pesos_all');

    
    img = im2double(imread(img_path));
 

    [H, W, ~] = size(img);

  
    hsv    = rgb2hsv(img);
    lab    = rgb2lab(img);
    ycbcr  = rgb2ycbcr(img);


  
    channels_data.R  = img(:,:,1);
    channels_data.G  = img(:,:,2);
    channels_data.B  = img(:,:,3);
    channels_data.H  = hsv(:,:,1);
    channels_data.S  = hsv(:,:,2);
    channels_data.V  = hsv(:,:,3);
    channels_data.L  = lab(:,:,1);
    channels_data.a  = lab(:,:,2);
    channels_data.b  = lab(:,:,3);
    channels_data.Y  = ycbcr(:,:,1);
    channels_data.Cb = ycbcr(:,:,2);
    channels_data.Cr = ycbcr(:,:,3);

    
    hsv_blur = imgaussfilt(hsv(:,:,3), 0.7);
    white_mask = (hsv_blur > 0.82 & hsv(:,:,2) < 0.23);
    white_mask = imopen(white_mask, strel('disk', 1));
    white_mask = imclose(white_mask, strel('disk', 2));
    white_mask = imfill(white_mask, 'holes');
    white_mask = logical(white_mask);

    
    global_mask = zeros(H, W);

    
    class_names = fieldnames(umbral_all);
    for c = 1:length(class_names)
        class = class_names{c};
        if ~isfield(canales_all, class), continue; end

        selected_channels = canales_all.(class);
        thresholds = umbral_all.(class);
        weights = pesos_all.(class);

        class_score = zeros(H, W);

        for i = 1:length(selected_channels)
            ch = selected_channels{i};
            ch_data = channels_data.(ch);
            q1q3 = thresholds.(ch);

            mask = (ch_data >= q1q3(1)) & (ch_data <= q1q3(2));
            mask = bwareaopen(mask, 20);
            mask = imfill(mask, 'holes');

            class_score = class_score + weights(i) * double(mask);
        end

        class_mask = class_score > 0.01;
        class_mask(white_mask) = 0;

        global_mask = global_mask | class_mask;
    end

   
    segmented_all = img;
    for i = 1:3
        ch = segmented_all(:,:,i);
        ch(~global_mask) = 0;
        segmented_all(:,:,i) = ch;
    end


    hsv_final = rgb2hsv(segmented_all);
    residual_white = (hsv_final(:,:,3) > 0.82 & hsv_final(:,:,2) < 0.25);
    residual_white = imopen(residual_white, strel('disk', 1));
    residual_white = imclose(residual_white, strel('disk', 2));
    residual_white = imfill(residual_white, 'holes');

    for i = 1:3
        ch = segmented_all(:,:,i);
        ch(residual_white) = 0;
        segmented_all(:,:,i) = ch;
    end

   
    figure('Name','Segmentación de todas las clases');
    subplot(1,3,1); imshow(img); title('Imagen original + contornos');
    subplot(1,3,2); imshow(global_mask); title('Máscara combinada');
    subplot(1,3,3); imshow(segmented_all); title('Frutos segmentados (todas las clases)');

end


