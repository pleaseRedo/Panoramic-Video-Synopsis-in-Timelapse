  function [cur_img] = updatePanorama(t,section,panorama,objMsk,mov,part,number_obj)
%  This function is used to stick object into panorama background
% t: count of frames
% section : length of synopsis
% panorama : panorama background
% objMsk : detection window mask
% mov : original input
% part : current count of object
% number_obj : the number of ojbect in total
[height,width,num_frame] = size(objMsk);
[p_height,p_width,~] = size(panorama);
pano_sec = floor((p_width-width)/number_obj);
panorama_mask = zeros(size(panorama));
panorama_obj = zeros(size(panorama));
cur_frame = t+(part-1)*section;
scanline = t+(part-1)*pano_sec;

if part==1
   cur_frame =t;
%    scanline= t;
end       
head_flag =0;
    while(head_flag ==0)
        % Determing which column to start.
        if(sum(panorama(:,scanline,1))==0||(p_height-getfield(find(panorama(:,scanline,1)),{1}))<height)
            scanline = scanline + 1;   
        else
          head_flag = 1;
        end
    end
    head = find(panorama(:,scanline,1));
    mask_head = head(1);
    mask1 = objMsk(:,:,cur_frame);
    panorama_mask(mask_head:mask_head+height-1,scanline:scanline+width-1,: ) = repmat(mask1,[1 1 3]);
    panorama_obj(mask_head:mask_head+height-1,scanline:scanline+width-1,: ) = double(mov(:,:,:,cur_frame));
    cur_img= double(panorama).*(1-panorama_mask)+panorama_obj.*panorama_mask;
  end

