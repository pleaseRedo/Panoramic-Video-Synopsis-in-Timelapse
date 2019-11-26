function [cur_img] = simpleSynUpdate(BackgroundMSK,section,mov,cur_img,t,obj)
% This function is used to put synopsis object into the scene/ background
% This function is used recursively 
% BackgroundMSK : mask of object or background
% section : length of each synopsis section
% mov : original input
% cur_img : output of this function
% t : frames
% obj: count of current object.
    cur_frame = t+(obj-1)*section;
    
    mask = BackgroundMSK(:,:,cur_frame)>0;
    cur_img = cur_img.* repmat((1-mask),[1,1,3])+mov(:,:,:,cur_frame).*repmat((mask),[1,1,3]);


end




