%------------------------------------------------------------------------
% This code calculates the length of a line segment in world coordinates
% starting from a camera image
% Basic steps:
% - use <fitgeotrans> to estimate a geometric transformation 
% - use <imwarp> to apply that transformation to the original image
% - use <hughlines> to detect vertical lines in the transformed image; 
% the longest line corresponds to the guiding line in the original image 
% - use the reference object obtained by applying the geometric
% transformation to calculate world coordinates for the vertical line and
% its length
%-------------------------------------------------------------------------


clc; clear; close all
filename = 'ex3_testimg.png';
img = im2double(rgb2gray(imread(filename)));  % double is required to carry out projective maps without the error induced by uint8
name = 'ex3';
imshow(img);

% [c r p] = impixel;   % pixels were initially selected using impixel
c = [25 300 206 132 ]';
r = [173 172 78 77 ]';
base = [0 3; 3 3; 3 0; 0 0]; % assume a square area of 3 by 3 units

% estimate the transformation matrix from the selected points and base
tf = fitgeotrans([c r],base*100,'projective');  % assume an unit corresponds to 100cm 
disp('tf = ');
disp(tf)
T = tf.T;
disp('T =');
format short g
disp(T);
format
hold on;
% overlay control points on image
plot([c;c(1)],[r;r(1)],'r','Linewidth',2);
text(c(1),r(1)+20,'0, 3','Color','y');
text(c(2),r(2)+20,'3, 3','Color','y');
text(c(3),r(3)-20,'3, 0','Color','y');
text(c(4),r(4)-20,'0, 0','Color','y');
hold off;

% do image transform
% xf1_ref is spatial reference object that contains information associated to the transformed
% image
[xf1, xf1_ref] = imwarp(img,tf);
% truncate image
xf1_ref.XWorldLimits = [-500 500];
xf1_ref.YWorldLimits = [-800 500];
xf1_ref.ImageSize = [500 500];
% apply image transform using the new size and location of output image
% from xf1_ref imref2d reference object
[xf2 xf2_ref] = imwarp(img,tf,'OutputView',xf1_ref);
figure, imshow(xf2)

% detect the longest vertical line which corresponds to the orange
% guideline in the original image
BW = edge(xf2,'Prewitt');
[H,T,R] = hough(BW);
P  = houghpeaks(H,10);
lines = houghlines(BW,T,R,P,'FillGap',5);
figure, imshow(BW), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   if (lines(k).theta < 10) && (lines(k).theta >= 0)  % plot and compare length only if line is vertical (assume 0<=angle<10 deg) 
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
% calculate length of line based on xf2_ref imref2d reference object
[x1World, y1World] = intrinsicToWorld(xf2_ref,xy_long(1,1),xy_long(1,2));
[x2World, y2World] = intrinsicToWorld(xf2_ref,xy_long(2,1),xy_long(2,2));
length_w=pdist2([x1World, y1World],[x2World, y2World],'euclidean');
disp('Calculated length of the line segment is [in cm]:');
disp(length_w); 