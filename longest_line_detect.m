%------------------------------------------------------------------------
% This code calculates the distance of the largest horizontal line in an image
% by extracting line segments based on Hough transform  
%------------------------------------------------------------------------
clc; clearvars; close all

RGB_raw = imread('ex1_testimg1.png');
% RGB_raw = imread('ex1_testimg2.png');  % alternate test image

I = rgb2gray(RGB_raw); % convert to grayscale to get a bi-dimensional image
BW = imbinarize(I);
BW1 = imclearborder(BW, 4); % clear any borders the image might have
[H,T,R] = hough(BW1);
P  = houghpeaks(H,10);
lines = houghlines(BW1,T,R,P,'FillGap',5);
figure, imshow(BW1), hold on

% search for the longest line
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   if (lines(k).theta == -90)  % plot and compare length only if line is horizontal
       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len) 
          max_len = len;       
          xy_long = xy;
       end
   end
end

% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
% Plot beginnings and ends of longest line segment
plot(xy_long(1,1),xy_long(1,2),'x','LineWidth',2,'Color','yellow');
plot(xy_long(2,1),xy_long(2,2),'x','LineWidth',2,'Color','red');
disp('Calculated length of the line segment is:');
disp(max_len); 