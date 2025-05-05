function arcs = find_arcs_and_compute_angles(edge_mask)
% edge_mask: imagen binaria (salida de detect_zero_crossing_edges)
% arcs: struct con campos .P1, .P2, .Pc, .angle (grados)

    % Etiquetar componentes conectados (bordas)
    labeled = bwlabel(edge_mask, 8);
    stats = regionprops(labeled, 'PixelIdxList', 'PixelList');

    arcs = [];

    for k = 1:length(stats)
        pixels = stats(k).PixelList;

        if size(pixels,1) < 70
            continue  % ignorar bordas muy pequeñas
        end

        % Paso 1: puntos inicial y final del arco
        P1 = pixels(1,:);
        P2 = pixels(end,:);

        % Paso 2: punto más lejano (curvatura máxima) como Pc
        dists = zeros(size(pixels,1),1);
        for i = 2:size(pixels,1)-1
            Pi = pixels(i,:);
            dists(i) = point_to_line_distance(P1, P2, Pi);
        end
        [~, idx] = max(dists);
        Pc = pixels(idx,:);

        % Paso 3: calcular ángulo entre vectores (P1–Pc) y (P2–Pc)
        v1 = P1 - Pc;
        v2 = P2 - Pc;
        cos_angle = dot(v1, v2) / (norm(v1)*norm(v2));
        angle_rad = acos(max(min(cos_angle,1),-1));  % estabilidad numérica
        angle_deg = rad2deg(angle_rad);

        % Guardar arco
        arcs(end+1).P1 = P1;
        arcs(end).P2 = P2;
        arcs(end).Pc = Pc;
        arcs(end).angle = angle_deg;
        arcs(end).length = size(pixels,1);
        arcs(end).pixels = pixels;
    end
end

function d = point_to_line_distance(A, B, P)
% Distancia del punto P a la línea AB
    if isequal(A, B)
        d = norm(P - A);
        return;
    end
    AB = B - A;
    AP = P - A;
    d = norm(cross([AB 0], [AP 0])) / norm(AB);
end
