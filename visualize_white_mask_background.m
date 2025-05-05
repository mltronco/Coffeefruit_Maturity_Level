function visualizar_histograma_RGB_mascara()

    % Cargar imagen
    rgb = im2double(imread('Images/Classification/cereja/amostra1.jpg'));

    % Convertir a HSV y generar máscara del fondo blanco
    hsv = rgb2hsv(rgb);
    mask_white = (hsv(:,:,3) > 0.9 & hsv(:,:,2) < 0.2);
    mask_keep = ~mask_white;

    % Crear imagen con fondo eliminado
    img_masked = rgb;
    for i = 1:3
        channel = rgb(:,:,i);
        channel(mask_white) = 0;
        img_masked(:,:,i) = channel;
    end

    % Extraer canales válidos según la máscara
    R_vals = rgb(:,:,1); R_vals = R_vals(mask_keep);
    G_vals = rgb(:,:,2); G_vals = G_vals(mask_keep);
    B_vals = rgb(:,:,3); B_vals = B_vals(mask_keep);

    % Mostrar histogramas por canal
    figure('Name', 'Histogramas por canal RGB sin fondo blanco');

    subplot(1,3,1);
    histogram(R_vals, 50, 'FaceColor', 'r'); title('Canal R');
    xlabel('Intensidad'); ylabel('Frecuencia');

    subplot(1,3,2);
    histogram(G_vals, 50, 'FaceColor', 'g'); title('Canal G');
    xlabel('Intensidad');

    subplot(1,3,3);
    histogram(B_vals, 50, 'FaceColor', 'b'); title('Canal B');
    xlabel('Intensidad');

end

