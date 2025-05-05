function fruit_count = project_ellipses_from_arcs(img_gray, arcs)
[H, W] = size(img_gray);
imshow(img_gray); hold on; title('Projected ellipses from arcs');

fruit_count = 0;

for i = 1:length(arcs)
    alpha = arcs(i).angle;
    if alpha >= 160
        continue;  % descartar como fruto
    end

    P1 = arcs(i).P1;
    P2 = arcs(i).P2;
    Pc = arcs(i).Pc;

    b = norm(P1 - Pc);
    a = angle_to_a(alpha, b);

    theta = linspace(0, 2*pi, 100);
    xe = a * cos(theta);
    ye = b * sin(theta);

    best_overlap = 0;
    best_coords = [];

    for angle = 0:20:160
        R = [cosd(angle), -sind(angle); sind(angle), cosd(angle)];
        ellipse_rot = R * [xe; ye];
        x_rot = ellipse_rot(1,:) + Pc(1);
        y_rot = ellipse_rot(2,:) + Pc(2);

        if any(x_rot < 1) || any(x_rot > W) || any(y_rot < 1) || any(y_rot > H)
            continue;
        end

        mask_ellipse = poly2mask(x_rot, y_rot, H, W);
        border_mask = false(H, W);
        idx = sub2ind([H, W], arcs(i).pixels(:,2), arcs(i).pixels(:,1));
        border_mask(idx) = true;

        inter = sum(mask_ellipse(:) & border_mask(:));
        overlap = inter / sum(mask_ellipse(:));

        if overlap > best_overlap
            best_overlap = overlap;
            best_coords = [x_rot; y_rot];
        end
    end

    if best_overlap >= 0.7
        fruit_count = fruit_count + 1;
        plot(best_coords(1,:), best_coords(2,:), 'g', 'LineWidth', 1.5);
    end
end

hold off;
end

function a = angle_to_a(alpha, b)
    if alpha >= 160, a = 0;
    elseif alpha > 140, a = 6 * b;
    elseif alpha > 120, a = 5.5 * b;
    elseif alpha > 100, a = 3 * b;
    elseif alpha > 80,  a = 2.5 * b;
    elseif alpha > 60,  a = 2 * b;
    elseif alpha > 40,  a = 1.75 * b;
    elseif alpha > 20,  a = 2 * b;
    elseif alpha > 10,  a = 3.75 * b;
    else               a = 9 * b;
    end
end
