function zero_cross_mask = detect_zero_crossing_edges(img_gray)

    smoothed = imgaussfilt(img_gray, 1.5);  
 
    h = fspecial('log', [5 5], 1.5);
    log_response = imfilter(smoothed, h, 'replicate');

   
    [H, W] = size(log_response);
    zero_cross_mask = false(H, W);


    for i = 2:H-1
        for j = 2:W-1
            center = log_response(i,j);

               neighbors = [
                log_response(i-1,j), log_response(i+1,j);  
                log_response(i,j-1), log_response(i,j+1);  
                log_response(i-1,j-1), log_response(i+1,j+1);  
                log_response(i-1,j+1), log_response(i+1,j-1)  
            ];

            for k = 1:size(neighbors,1)
                if sign(neighbors(k,1)) ~= sign(neighbors(k,2))
                    zero_cross_mask(i,j) = true;
                    break;
                end
            end
        end
    end

end

