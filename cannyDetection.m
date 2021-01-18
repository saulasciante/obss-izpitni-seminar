function edgeLinking = cannyDetection(imageName)
    image = imread(imageName);
    
    figure;
    subplot(2, 2, 1); imshow(image); title('Original image');
    
    % SMOOTHING IMAGE
    smoothedImage = imgaussfilt(im2double(image), 2);
    subplot(2, 2, 2); imshow(smoothedImage, [min(smoothedImage(:)),max(smoothedImage(:))]); title('Gaussian smoothing');

    % Prewitt mask
    kx = [-1 0 +1; -1 0 +1; -1 0 +1];
    ky = [-1 -1 -1; 0 0 0; +1 +1 +1];
    gx = conv2(smoothedImage, kx, 'same');
    gy = conv2(smoothedImage, ky, 'same');

    mag = sqrt(gx.^2 + gy.^2);
    angles = atan2(gy, gx) * 180/pi;
    % normalize angles 0 - 360
    angles(angles < 0) = 360 + angles(angles < 0);
    
    
    % ADJUSTING ANGLES
    imgHeight = size(image, 1);
    imgWidth = size(image, 2);
    adjustedAngles = zeros(imgHeight, imgWidth);
    
    for h = 1:imgHeight
        for w = 1:imgWidth
            if ((angles(h, w) >= 337.5) && (angles(h, w) < 22.5) || ...
                (angles(h, w) >= 157.5) && (angles(h, w) < 202.5))
                adjustedAngles(h, w) = 0;
            elseif ((angles(h, w) >= 22.5) && (angles(h, w) < 67.5) || ...
                    (angles(h, w) >= 202.5) && (angles(h, w) < 247.5))
                adjustedAngles(h, w) = 45;
            elseif ((angles(h, w) >= 67.5) && (angles(h, w) < 112.5) || ...
                    (angles(h, w) >= 247.5) && (angles(h, w) < 292.5))
                adjustedAngles(h, w) = 90;
            elseif ((angles(h, w) >= 112.5) && (angles(h, w) < 157.5) || ...
                    (angles(h, w) >= 292.5) && (angles(h, w) < 337.5))
                adjustedAngles(h, w) = 135;
            end
        end
    end

    % NON-MAXIMUM SUPPRESION
    % window size = 3
    edgeMatrix = zeros(imgHeight, imgWidth);
    
    for h = 2:imgHeight-1
        for w = 2:imgWidth-1
            switch adjustedAngles(h, w)
                case 0
                    edgeMatrix(h,w) = mag(h,w) * (mag(h,w) == max([mag(h,w), mag(h, w-1), mag(h, w+1)]));
                case 90
                    edgeMatrix(h,w) = mag(h,w) * (mag(h,w) == max([mag(h,w), mag(h-1, w), mag(h+1, w)]));
                case 45
                    edgeMatrix(h,w) = mag(h,w) * (mag(h,w) == max([mag(h,w), mag(h-1, w+1), mag(h+1, w-1)]));
                case 135
                    edgeMatrix(h,w) = mag(h,w) * (mag(h,w) == max([mag(h,w), mag(h-1, w-1), mag(h+1, w+1)]));
                otherwise
            end
        end
    end
    
    subplot(2, 2, 3); imshow(edgeMatrix); title('Non-maximum suppression');
    
    % N2: Hysteresis thresholding (separation into strong and weak edge pixels)
    % N3: Form longer edges (edge-linking w/ 8-connectivity of weak pixels to strong pixels)
    T_LOW = 0.1;
    T_HIGH = 0.35;
    edgeLinking = zeros(imgHeight, imgWidth);
    
    for h = 1:imgHeight
        for w = 1:imgWidth
            if (edgeMatrix(h,w) < T_LOW)
                edgeLinking(h,w) = 0;
            elseif (edgeMatrix(h,w) > T_HIGH || ...
                    edgeMatrix(h-1,w-1) > T_HIGH || ...
                    edgeMatrix(h-1,w) > T_HIGH || ...
                    edgeMatrix(h-1,w+1) > T_HIGH || ...
                    edgeMatrix(h,w-1) > T_HIGH || ...
                    edgeMatrix(h,w+1) > T_HIGH || ...
                    edgeMatrix(h+1,w-1) > T_HIGH || ...
                    edgeMatrix(h+1,w) > T_HIGH || ...
                    edgeMatrix(h+1,w+1) > T_HIGH)
                edgeLinking(h,w) = 255;
            end
        end
    end
    
    subplot(2, 2, 4); imshow(edgeLinking); title('Edge linking');
    
    for h = 1:imgHeight
        for w = 1:imgWidth
            if (edgeLinking(h,w) ~= 255)
                edgeLinking(h,w) = 0;
            end
        end
    end
    
    figure; imshow(edgeLinking)
end