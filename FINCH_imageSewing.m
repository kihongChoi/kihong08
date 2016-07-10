% for future development: add image processing algorithm

% read one sample image
%  thisCell = layerCell_1;
%  thisCell = flipud(thisCell');
% sampleImg = layerCell_1{1,1};

imgSize = 1001;	% probably 1:1 size
x = 12; y = 4;

offsetSize_x = 81; 	% px
offsetSize_y = 81; 	% px
transparency = 0.5;

filenamePrefix = '140.0';

canvasSize_x = imgSize + offsetSize_x * (x - 1);
canvasSize_y = imgSize + offsetSize_y * (y - 1);

%targetLayer = zeros(canvasSize_y, canvasSize_x);

% h = waitbar(0,'Loading...', 'Name','Wait bar name');
% for yy = 1:y
% 	for xx = 1:x
% 		% == your contents here ==
%             thisImg = double(imread(sprintf('i_430.0_z001y%03dx%03d.jpg', yy, xx)));
%         
% 			thisPoint_x = 1+offsetSize_x*(xx-1);
% 			thisPoint_y = canvasSize_y - imgSize - offsetSize_y*(yy-1) + 1;
% 
%             blendLayer = zeros(size(targetLayer));
%             
%             %thisImg = thisCell{1+y-yy, xx};
%             
%             thisImg = thisImg./max(max(thisImg));
% 			blendLayer(thisPoint_y:thisPoint_y+imgSize-1, thisPoint_x:thisPoint_x+imgSize-1) = thisImg;
% 			targetLayer = max(targetLayer, blendLayer*transparency); 	% lighten effect & transparency
%             %disp(imgList((yy-1)*x + xx).name)
%             
% 		% == update waitbar ==
% 		thisCount = (yy-1)*x + xx;
% 		totalCount = x*y;
% 		waitbar( thisCount/totalCount, h, sprintf('Operating... %s%%', num2str(fix(10000*thisCount/totalCount)/100)));
%         imagesc(targetLayer);
%         
% 	end
% end
% colormap('gray')
% delete(findall(0,'type','figure','tag','TMWWaitbar'));

% row by row save


targetLayer = zeros(canvasSize_y, canvasSize_x);
h = waitbar(0,'Loading...', 'Name','Wait bar name');
for yy = 1:y
    
	for xx = 1:x
		% == your contents here ==
            thisImg = double(imread(sprintf('i_%s_z001y%03dx%03d.tif', filenamePrefix, yy, xx)));
        
			thisPoint_x = 1 + offsetSize_x*(xx-1);
			thisPoint_y = 1 + canvasSize_y - imgSize - offsetSize_y*(yy-1);
            %disp([thisPoint_x, thisPoint_y]);

            blendLayer = zeros(size(targetLayer));
            
            %thisImg = thisCell{1+y-yy, xx};
            
            thisImg = thisImg./max(max(thisImg));
			blendLayer(thisPoint_y:thisPoint_y+imgSize-1, thisPoint_x:thisPoint_x+imgSize-1) = thisImg;
			targetLayer = max(targetLayer, blendLayer*transparency); 	% lighten effect & transparency
            %disp(imgList((yy-1)*x + xx).name)
            
            
		% == update waitbar ==
		thisCount = (yy-1)*x + xx;
		totalCount = x*y;
		waitbar( thisCount/totalCount, h, sprintf('Operating... %s%%', num2str(fix(10000*thisCount/totalCount)/100)));
        imagesc(targetLayer);
        
    end
    
end
colormap('gray')
delete(findall(0,'type','figure','tag','TMWWaitbar'));

saveImage = input('save image?: ');
if saveImage
    imwrite(uint8(255.*targetLayer./max(max(targetLayer))), sprintf('recImg_%s.tif', filenamePrefix));
end
