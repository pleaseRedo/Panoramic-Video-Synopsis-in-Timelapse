close all;
% User input
video = VideoReader('tigerOrig.mp4');
number_obj = 5;


mov = read(video);
seq = double(mov);
[height,width,~,num_frame] = size(mov);
gray_seq = zeros(height,width,num_frame/2);
objMsk = zeros(height,width,num_frame);
flattenImgSet = zeros(height,width,num_frame);

for i = 1:num_frame
    gray_seq(:,:,i)  = rgb2gray(mov(:,:,:,i));
end
output = zeros([height width 3]);
testSeq = zeros(height,width,num_frame/2);
testSeq_c = zeros(height,width,3,num_frame/2);

tforms(num_frame) = projective2d(eye(3));
pix_median = zeros(height,width,8);
pix_median_c = zeros(height,width,3,8);

% ns  = [2,12,22,32,42,52,62];
%% find sequence median aka backgound
for i = 1:height
   for j = 1:width
       pix_median(i,j,:) = median(gray_seq(i,j,:));    
   end
end 

for i = 1:height
   for j = 1:width
       pix_median_c(i,j,1,:) = median(mov(i,j,1,:));  
              pix_median_c(i,j,2,:) = median(mov(i,j,2,:));    
       pix_median_c(i,j,3,:) = median(mov(i,j,3,:));    

   end
end 
bg_set = zeros(size(mov));

%% Compute optic flow for object detection
count=1;
for i = 1:num_frame-1
    srcImage =  gray_seq(:,:,i);

    neighborImage = gray_seq(:,:,i+1);

    % These parameters are tunned for tiger cases.
    alpha = 0.5;
    ratio = 0.5;
    minWidth = 10;
    nOuterFPIterations =4;
    nInnerFPIterations = 3;
    nSORIterations = 40;
    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

    % tic;
    [vx,vy,warpI2] = Coarse2FineTwoFrames(srcImage,neighborImage,para);
    % toc ;   

    cur_flow = vx+vy;
    level=graythresh(cur_flow);
    bw=im2bw(cur_flow,level);
    se = strel('disk',4);
    openbw=imdilate(bw,se);
    stats = regionprops(openbw, 'BoundingBox' ,'Area','Centroid' ,'PixelList' ); 
    centroids = cat(1, stats.Centroid);
%     flow_msk = cur_flow>0;
%     imshow((cur_flow.*flow_msk));
%     drawnow;
    % This is a single element task thus the largest area is the target
    largestArea = 0;
    for n=1:size(stats)
    if(stats(n).Area>=largestArea)
       cur_bb = stats(n).BoundingBox;
       largestArea = stats(n).Area;       
    end
    end
    % Visualization
    % subplot(4,1,2),imshow(uint8(srcImage));
%     hold on; 
%     rectangle('position', cur_bb, 'edgecolor', 'g', 'linewidth',2);
%     drawnow
%     hold off
    %
    %imshow(cur_flow);   
    objectMask = poly2mask([cur_bb(1),cur_bb(1)+cur_bb(3),cur_bb(1)+cur_bb(3),cur_bb(1)],[cur_bb(2),cur_bb(2),cur_bb(2)+cur_bb(4),cur_bb(2)+cur_bb(4)],size(srcImage,1),size(srcImage,2));
    flattenImg = srcImage.*(1-objectMask) + objectMask.*pix_median(:,:,1);
%     subplot(4,1,3),imshow(uint8(flattenImg));



    %Perform masking over color image
    % remove the object
    flattenImgColor(:,:,1) =   double(mov(:,:,1,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,1,1);
    flattenImgColor(:,:,2) =   double(mov(:,:,2,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,2,1);
    flattenImgColor(:,:,3) =   double(mov(:,:,3,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,3,1);
%     subplot(4,1,3),imshow(uint8(flattenImgColor));
    bg_set(:,:,:,count)  =  flattenImgColor;
    objMsk(:,:,count) = objectMask;

    count= count+1;
end


% Repeat same task with skipped frames 
count = 1;
for i = 1:2:num_frame-1
    srcImage =  gray_seq(:,:,i);
    neighborImage = gray_seq(:,:,i+1);

    alpha = 0.5;
    ratio = 0.5;
    minWidth = 10;
    nOuterFPIterations =4;
    nInnerFPIterations = 3;
    nSORIterations = 40;

    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

    % tic;
    [vx,vy,warpI2] = Coarse2FineTwoFrames(srcImage,neighborImage,para);
    % toc ;   

    cur_flow = vx+vy;
    level=graythresh(cur_flow);
    bw=im2bw(cur_flow,level);
    se = strel('disk',4);
    openbw=imdilate(bw,se);
    stats = regionprops(openbw, 'BoundingBox' ,'Area','Centroid' ,'PixelList' ); 
    centroids = cat(1, stats.Centroid);

%     subplot(4,1,1),imshow(uint8(cur_flow));
    largestArea = 0;
    for n=1:size(stats)
    if(stats(n).Area>=largestArea)
    cur_bb = stats(n).BoundingBox;
    largestArea = stats(n).Area;
    end   
    end
%     Comment are for intermediate result visualization
%     subplot(4,1,2),imshow(uint8(srcImage));

%      imshow(uint8(srcImage))
%      hold on; 
%     boxRect = [corr_offset(1) corr_offset(2) size(template,2), size(template,1)];
%      rectangle('position', cur_bb, 'edgecolor', 'g', 'linewidth',2);
%      input('')
%      drawnow
%      hold off
    %
    %imshow(cur_flow);   
    objectMask = poly2mask([cur_bb(1),cur_bb(1)+cur_bb(3),cur_bb(1)+cur_bb(3),cur_bb(1)],[cur_bb(2),cur_bb(2),cur_bb(2)+cur_bb(4),cur_bb(2)+cur_bb(4)],size(srcImage,1),size(srcImage,2));
    objectMask = objMsk(:,:,i);
    flattenImg = srcImage.*(1-objectMask) + objectMask.*pix_median(:,:,1);
%     subplot(4,1,3),imshow(uint8(flattenImg));

    %%%%%%%%%%%%%%% COLOR vER
    flattenImgColor(:,:,1) =   double(mov(:,:,1,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,1,1);

    flattenImgColor(:,:,2) =   double(mov(:,:,2,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,2,1);
    flattenImgColor(:,:,3) =   double(mov(:,:,3,i)).*(1-objectMask) + objectMask.*pix_median_c(:,:,3,1);

%     subplot(4,1,3),imshow(uint8(flattenImgColor));
    bg_set(:,:,:,count)  =  flattenImgColor;

    % The above just do the same thing like the previous loop but skipped a
    % frame for each iteration
    srcImage = flattenImg;
    testSeq_c(:,:,:,count) = uint8(flattenImgColor);
    count = count + 1;
    %imshow(uint8(testSeq_c(:,:,:,count)))




end
panorama = panoramicStitching(testSeq_c);
panorama(:,:,1) = medfilt2(panorama(:,:,1),[3 3]);
panorama(:,:,2) = medfilt2(panorama(:,:,2),[3 3]);
panorama(:,:,3) = medfilt2(panorama(:,:,3),[3 3]);

output = panoSyn(objMsk,panorama,mov,number_obj);
output = uint8(output);
for i = 1:size(output,4)
    filename = sprintf('pano_%d.jpg',i);
    imwrite(output(:,:,:,i),filename);
end

