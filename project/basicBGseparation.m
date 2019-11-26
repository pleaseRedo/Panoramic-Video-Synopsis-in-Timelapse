%% User input
% Make sure the video is in the directory
video = VideoReader('lena_in.mp4');
num_obj =3;
%%%%%%%%%%%%%%%
mov = read(video);
seq = double(mov);
[height,width,~,num_frame] = size(mov);

%% Convert to gray image
gray_seq = zeros(height,width,num_frame);
for i = 1:num_frame
    gray_seq(:,:,i)  = rgb2gray(mov(:,:,:,i));
    
end

%% Activity detection
pix_median = zeros(height,width,3,num_frame);

   for i = 1:height
       for j = 1:width
           pix_median(i,j,1,:) = median(seq(i,j,1,:));    
           pix_median(i,j,2,:) = median(seq(i,j,2,:));    
           pix_median(i,j,3,:) = median(seq(i,j,3,:));    
       end
   end 
    
% %% Convert to gray image
% gray_med = zeros(height,width,num_frame);
% for i = 1:num_frame
%     gray_med(:,:,i)  = rgb2gray(pix_median(:,:,:,i));
%     
% end

pix_median_uint = uint8(pix_median);
gray_seq_uint = uint8(gray_seq);
% 
%Check if active using characteristic function
X = zeros(height,width,num_frame);
length = num_frame;
BSegments = zeros(height, width, length);
for i = 1:length
    tgt  = abs((gray_seq(:,:,i))-double(rgb2gray(uint8(pix_median(:,:,:,i)))));
    level=graythresh(tgt);
    tgt = uint8(tgt);
    bw=im2bw(tgt,level);
    
    se = strel('sphere',3);
    se2 = strel('sphere',4);
    %openbw=imerode(bw,se);
    %openbw2 = imdilate(openbw,se2);
    denoised = imclose(bw,se);
    rgSize = 15; % region growing by 15 pixels
    se3 = ones(rgSize, rgSize); 
    sumup = imdilate(bw,se3);
    % Using bwlabel for region segmentation
    connected_region = bwlabel(sumup,8);
    segmentation = label2rgb(connected_region);
% Comments are middle results visualization    
%     subplot(1,3,1),imshow(uint8((mov(:,:,:,i))));
%      title({['Original']}); 
%      subplot(1,3,2),imshow(uint8(pix_median(:,:,:,i))),
%      title({['Background']}); 
%      subplot(1,3,3),imshow(uint8(tgt)),
%      title({['Foreground']}); 
%      
     
%      subplot(2,2,1),imshow(uint8(tgt));
%      subplot(1,2,1),imshow((bw)),
%      title({['Raw Mask']}); 
%      subplot(1,2,2),imshow((sumup));
%      title({['Processed Mask']}); 
%      subplot(1,3,3),imshow(uint8(sumup));
    
    BSegments(:,:,i) = connected_region;
    drawnow;
end

%% Synopsis
output = synopsis_general(BSegments,pix_median,mov,num_obj);
output = uint8(output);
for i = 1:size(output,4)
    filename = sprintf('general_%d.jpg',i);
    imwrite(output(:,:,:,i),filename);
end