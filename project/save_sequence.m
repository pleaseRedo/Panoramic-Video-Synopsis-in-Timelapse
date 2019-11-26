function output = save_sequence(matrix, path, prefix, first, digits)

%
% Read a matrix of gray level images and write a sequence of png files
% starting from the file 'path/prefix[first].png'
%
% Arguments:
%
% matrix: matrix of images to export
% path: path of the files
% prefix: prefix of the filename
% first: frame number of the first image of the sequence
% digits: number of digits of the frame number
%
% Example:
%
% myimage is a matrix containing 40 images
%
% save_sequence(mov, '.', 'myimage', 13, 4);
%   -> that will export images from './myimage0013.png' to './myimage0052.png'
%
% how to save a single image:
%
% save_sequence(myimage, '.', 'image', 27, 4);
%   -> that will export ./image0027.png'
%

% Check for slash at the end of the path
if(path(end)=='/')
    slash='';
else
    slash='/';
end

% Get the number of frames in the matrix
l = size(matrix,3)

for i=1:l
    
    % Create correct frame number
    frame_number = first+i-1;
    
    % Get the padded frame number
    number = padded_number(frame_number, digits);
    
    % Create the filename
    filename = strcat(path,slash,prefix,number,'.png');
    
    % Export the image
    imwrite(matrix(:,:,i),filename);
    
end

output = 0;

end



function output = padded_number(number, digits)

%
% Add zeros to the left of the number to match the given length
%

% Convert to string
output = num2str(number);
    
% Get length of string
l = size(output,2);
    
% Add necessary zeros
for i=l+1:digits
    output=strcat('0', output);
end

end
