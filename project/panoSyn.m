function [output] = panoSyn(objMsk,panorama,mov,number_obj)
% This function is used for iterating updatePanorama   
% They share same parameters
[height,width,num_frame] = size(objMsk);
objMsk(:,:,end) = objMsk(:,:,end-1);
[p_height,p_width,~] = size(panorama);
section  = floor(num_frame/number_obj);
pano_sec = floor((p_width-width)/number_obj);
cur_img = zeros(height,width,3);
output = zeros([size(panorama),section]);

panorama_mask = zeros(size(panorama));
panorama_obj = zeros(size(panorama));
cur_frame = 0;
scanline=0;

for t= 1:section
    cur_img = updatePanorama(t,section,panorama,objMsk,mov,1,number_obj);
    for s  = 2:number_obj
        cur_img = updatePanorama(t,section,cur_img,objMsk,mov,s,number_obj);
    end
    cur_img(:,:,1) = medfilt2(cur_img(:,:,1),[3 3]);
    cur_img(:,:,2) = medfilt2(cur_img(:,:,2),[3 3]);
    cur_img(:,:,3) = medfilt2(cur_img(:,:,3),[3 3]);
    imshow(uint8(cur_img));
    drawnow;
    output(:,:,:,t) = cur_img;
end

end