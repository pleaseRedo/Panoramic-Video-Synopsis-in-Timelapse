function output = synopsis_general(BackgroundMSK,pix_median,mov,num_obj)
% This function will stick object into the backgroud to form synopsis
%   BackgroundMSK = Mask for object
%  pix_median = background, usually the median
%  num_obj = user specified obj to keep in frame
[height,width,num_frame] = size(BackgroundMSK);
section  = floor(num_frame/num_obj);
mov = double(mov);
output = zeros([height,width,3,section]);
for t = 1:section
%     mask1 = BackgroundMSK(:,:,t)>0;
%     cur_img= pix_median(:,:,:,1).*repmat((1-mask1),[1,1,3])+mov(:,:,:,t).*repmat((mask1),[1,1,3]);
    cur_img= simpleSynUpdate(BackgroundMSK,section,mov,pix_median(:,:,:,1),t,1);
    
    for i = 1:num_obj
        cur_img= simpleSynUpdate(BackgroundMSK,section,mov,cur_img,t,i);
%         cur_img=  simpleSynUpdate(BackgroundMSK,section,mov,cur_img,t,i);
    end
%     mask2 = BackgroundMSK(:,:,t+section)>0;
%     mask3 = BackgroundMSK(:,:,t+section*2)>0;
%     cur_img = cur_img.* repmat((1-mask2),[1,1,3])+mov(:,:,:,t+section).*repmat((mask2),[1,1,3]);
%     cur_img = cur_img.* repmat((1-mask3),[1,1,3])+mov(:,:,:,t+2*section).*repmat((mask3),[1,1,3]);

    imshow(uint8(cur_img));
    drawnow;
    output(:,:,:,t) = cur_img;
end
end

