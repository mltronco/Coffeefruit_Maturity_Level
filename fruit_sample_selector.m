function selector_muestras_frutas(imagen_path)
    % Verifica si se pasa el path como argumento
    if nargin < 1
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp'}, 'Selecciona la imagen');
        imagen_path = fullfile(path, file);
    end

    % Cargar imagen
    img = imread(imagen_path);
    figure, imshow(img), title('Selecciona región y etiqueta');

    continuar = true;
    muestra_id = 1;

    while continuar
        % Seleccionar región con el mouse
        h = imrect;
        position = wait(h); % [x, y, width, height]
        
        if isempty(position)
            break;
        end

        % Preguntar por la clase
        clase = inputdlg('Nombre de la clase:', 'Etiqueta', [1 50]);
        if isempty(clase)
            break;
        end

        clase = char(clase);
        % Crear carpeta si no existe
        if ~exist(clase, 'dir')
            mkdir(clase);
        end

        % Extraer muestra
        x = round(position(1));
        y = round(position(2));
        w = round(position(3));
        h_ = round(position(4));
        muestra = imcrop(img, [x, y, w, h_]);

archivos_existentes = dir(fullfile(clase, sprintf('%s_*.png', clase)));
ids = [];

for k = 1:length(archivos_existentes)
    nombre = archivos_existentes(k).name;
    expr = sprintf('%s_(\\d+).png', clase);
    tokens = regexp(nombre, expr, 'tokens');
    if ~isempty(tokens)
        ids(end+1) = str2double(tokens{1}{1});
    end
end

if isempty(ids)
    next_id = 1;
else
    next_id = max(ids) + 1;
end


        % Generar nombre único y guardar
filename = fullfile(clase, sprintf('%s_%03d.png', clase, next_id));
imwrite(muestra, filename);
fprintf('Guardada muestra en %s\n', filename);



        % Preguntar si desea continuar
        continuar = questdlg('¿Deseas seleccionar otra muestra?', ...
                             'Continuar', 'Sí', 'No', 'Sí');
        continuar = strcmp(continuar, 'Sí');
    end

    close all;
    disp('Proceso terminado.');
end
