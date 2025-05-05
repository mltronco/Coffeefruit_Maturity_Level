img = imread('Images/Device/IMG1.jpg');
%segment_image_by_class(img, 'verdolengo');
segment_all_classes('Images/Device/IMG1.jpg');



% 
% img = im2double(rgb2gray(imread('Images/Device/IMG1.jpg')));
% zc_mask = detect_zero_crossing_edges(img);
% arcs = find_arcs_and_compute_angles(zc_mask);
% 
% % Mostrar ángulos de los primeros arcos
% for i = 1:min(5, length(arcs))
%     fprintf('Arco %d: Ángulo ? = %.2f°, Longitud = %d px\n', ...
%         i, arcs(i).angle, arcs(i).length);
% end
% 
% 
% img = im2double(rgb2gray(imread('Images/Device/IMG1.jpg')));
% zc = detect_zero_crossing_edges(img);
% arcs = find_arcs_and_compute_angles(zc);
% project_ellipses_from_arcs(img, arcs);
% 
% 
% img = im2double(rgb2gray(imread('Images/Device/IMG1.jpg')));
% zc = detect_zero_crossing_edges(img);
% arcs = find_arcs_and_compute_angles(zc);
% n_fruits = project_ellipses_from_arcs(img, arcs);

