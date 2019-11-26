function [panorama] = panoramicStitching(testSeq_c)
% This function is used to make panorama
% testSeq_c : A series of frames with object removal.
% Load images.;
% The framework of this file comes from offical matlab tutorial:
% https://uk.mathworks.com/help/vision/examples/feature-based-panoramic-image-stitching.html?prodcode=VP&language=en

clear tform_set;
clear centerImageIdx;
clear idx;

% testSeq_c is 4D colored input
testSeq_c = uint8(testSeq_c);
out_project  = zeros(size(testSeq_c));

src = testSeq_c(:,:,:,1);

grayImage = rgb2gray(src);
tgt_points = detectSURFFeatures(grayImage,'MetricThreshold',100);
[features, tgt_points] = extractFeatures(grayImage, tgt_points);
numImages = size(testSeq_c,4);
tform_set(numImages) = projective2d(eye(3));

imageSizes = zeros(numImages,2);

% Image matching between first image and other image in sequence.
for n = 2:numImages-1
    previous_point = tgt_points;
    previous_feature = features;


    tgt = testSeq_c(:,:,:,n);
    grayImage = rgb2gray(tgt);
    imageSizes(n,:) = size(grayImage);
    %   SURF feature matching
    tgt_points = detectSURFFeatures(grayImage,'MetricThreshold',100);
    [features, tgt_points] = extractFeatures(grayImage, tgt_points);
    indexPairs = matchFeatures(features, previous_feature, 'MatchThreshold',100,'MaxRatio',0.9,'Unique', true);
    matchedPoints = tgt_points(indexPairs(:,1), :);
    matched_previous = previous_point(indexPairs(:,2), :);
    
    % Compute homography between image pairs
    tform_set(n) = estimateGeometricTransform(matchedPoints, matched_previous,'projective');
    % Applying homography to images
    out_project(:,:,1,n) = imwarp(tgt(:,:,1),tform_set(n), 'OutputView', imref2d([size(tgt,1),size(tgt,2)]));
    out_project(:,:,2,n) = imwarp(tgt(:,:,2),tform_set(n), 'OutputView', imref2d([size(tgt,1),size(tgt,2)]));
    out_project(:,:,3,n) = imwarp(tgt(:,:,3),tform_set(n), 'OutputView', imref2d([size(tgt,1),size(tgt,2)]));

   
   
    subplot(2,1,1),imshow(tgt);
    subplot(2,1,2),imshow(uint8(out_project(:,:,:,n)));
    drawnow;
    % Find transformation matrix sequence, this is used for later inverse
    % transformation
    tform_set(n).T = tform_set(n).T * tform_set(n-1).T;
end
% Get transformation spatial bounding box range
for i = 1:numImages
    [hori_lim(i,:), verti_lim(i,:)] = outputLimits(tform_set(i), [1 imageSizes(i,2)], [1 imageSizes(i,1)]);
end

centroids = mean(hori_lim, 2);

[~, idx] = sort(centroids);

centroidIdx = floor((numImages+1)/2);
centroidImageIdx = idx(centroidIdx);

% Get transformation inverse
Tinv = invert(tform_set(centroidImageIdx));
for i = 1:numImages
    tform_set(i).T = tform_set(i).T * Tinv.T;
end
for i = 1:numImages
    [hori_lim(i,:), verti_lim(i,:)] = outputLimits(tform_set(i), [1 imageSizes(i,2)], [1 imageSizes(i,1)]);
end
maxImageSize = max(imageSizes);

% Projection limits
horiMin = min([1; hori_lim(:)]);
horiMax = max([maxImageSize(2); hori_lim(:)]);
vertiMin = min([1; verti_lim(:)]);
vertiMax = max([maxImageSize(1); verti_lim(:)]);
% Get size of the panoramic output.
width  = floor(horiMax - horiMin);
height = floor(vertiMax - vertiMin);

panorama = zeros([height width 3], 'like', tgt);
blender = vision.AlphaBlender('Operation', 'Binary mask','MaskSource', 'Input port');

xLimits = [horiMin horiMax];
yLimits = [vertiMin vertiMax];
outView = imref2d([height width], xLimits, yLimits);

% Stitching images together
for i = 1:numImages
    
    tgt = testSeq_c(:,:,:,i);

    % Apply inverse transformation, alignment of centroid.
    warpedImage = imwarp(tgt, tform_set(i), 'OutputView', outView);
    mask = imwarp(true(size(tgt,1),size(tgt,2)), tform_set(i), 'OutputView', outView);
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)

% [cur_img] = panoSyn(objMsk,panorama,mov);

end