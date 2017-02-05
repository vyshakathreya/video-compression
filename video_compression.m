% COMPE 565 : Multimedia Communication Systems
% Project 3 : Motion estimation for Video Compression
% Vishakha Vijaykumar (820535151), Vyshak Athreya BK (820924384)

clear all;
close all;
clc;

% Reading the video file
video_object = VideoReader('walk_qcif.avi');    
k = 1;
while hasFrame(video_object)
    video_frames(k).cdata = readFrame(video_object);
    k = k+1; 
end

for i=6:10
	YCbCr = rgb2ycbcr(video_frames(i).cdata(:,:,:));
    Y(:,:,i) = YCbCr(:,:,1);
    Cb(:,:,i) = YCbCr(1:2:144,1:2:176,2); %4:2:0 compression
    Cr(:,:,i) = YCbCr(1:2:144,1:2:176,3);
end

frame_ref=video_frames(6).cdata(:,:,1);     % Y component of first frame
figure(1);
imshow(frame_ref);
title('Reference frame - Frame 6');

%first frame is taken as the reference fram and used for prediction
for frames=6:10
    fr_ref_Y=video_frames(frames).cdata(:,:,1);  %gives the reference frame
    fr_target_Y=video_frames(frames+1).cdata(:,:,1);  %gives the target frame
    
    MB_count=0;
    
    frame_1 = fr_ref_Y;
    copy_1 = double(frame_1);
    frame_2 = fr_target_Y;
    copy_2 = double(frame_2);
    
    mb_Y=16; %Macroblock size
    b1_Y=zeros(mb_Y,mb_Y); %reference
    b2_Y=zeros(mb_Y,mb_Y); %target
    
    w_Y=8; %window maximum displacement
    [r,c]=size(copy_2);
    image=copy_1;
    r_block_Y=zeros(mb_Y,mb_Y);%residual %makes all the values in a macroblock to zero
    
    v_block_no=ceil(r/mb_Y); %vertical block
    h_block_no=ceil(c/mb_Y);  %horizontal block
    %The number of blocks=horizontal*vertical blocks
    
    vector_Y=zeros(1,2);
    searchwindow_Y=zeros(v_block_no*h_block_no,2,2);  %Matrix of Vector
    
    counter=1;
    for row_block=1:mb_Y:r
        for col_block=1:mb_Y:c
            block2=copy_2([row_block:row_block+mb_Y-1],[col_block:col_block+mb_Y-1]); %target frame
            
            diff_Y=realmax;  
            MSE_Y=realmax;           
            
            for row_1=-w_Y:w_Y
                for col_1=-w_Y:w_Y
                    row_2=row_block+row_1; %incrementing row
                    col_2=col_block+col_1; %incrementing column
                    
                    if row_2>0 & col_2>0 & row_2+mb_Y-1<=r & col_2+mb_Y-1<=c
                        block1=copy_1([row_2:row_2+mb_Y-1],[col_2:col_2+mb_Y-1]); %reference frame
                        r_block_Y=block2-block1; %temporary storage for storing the difference matrix
                        MSE_2_Y=sum(sum(r_block_Y.^2));
                        minMSE_Y=MSE_2_Y./256;
                        MB_count=MB_count+1;
                        
                        if minMSE_Y<MSE_Y
                            MSE_Y=minMSE_Y;
                            vector_Y=[row_2-row_block,col_2-col_block]; %co-ordinates for search
                            mv = vector_Y;
                            reconstructed_image([row_block:row_block+mb_Y-1],[col_block:col_block+mb_Y-1])=copy_1([row_2:row_2+mb_Y-1],[col_2:col_2+mb_Y-1]);
          
                        elseif minMSE_Y==MSE_Y
                            diff1=(row_block-row_2)^2+(col_block-col_2)^2;
                            
                            if diff1<diff_Y
                                diff_Y=diff1;
                                vector_Y=[row_2-row_block,col_2-col_block];
                            end
                        end
                    end
                end
            end
            
            
            
            d_frame([row_block:row_block+15],[col_block:col_block+15])=r_block_Y; %saving after each itiration
            searchwindow_Y(counter,:,1)=[row_block,col_block];      %Block Position
            searchwindow_Y(counter,:,2)=vector_Y;
            counter=counter+1;
            
        end
    end
    display(MSE_Y)
    figure()
    quiver(searchwindow_Y(:,2,1),searchwindow_Y(:,1,1),searchwindow_Y(:,2,2),searchwindow_Y(:,1,2));
    title(['motion vector for image ',num2str(frames),' and image ',num2str(frames+1)] );
    
    grid on
    predicted_image=uint8(reconstructed_image);
    
    figure()
    subplot(2,2,1)
    imshow(fr_target_Y);
    title(['original frame ',num2str(frames)]);
    subplot(2,2,2)
    imshow(predicted_image);
    title(['predicted image - frame # ',num2str(frames+1)]);
    error = fr_target_Y - predicted_image;
    subplot(2,2,3)
    imshow(error);
    title(['error frame - frame # ',num2str(frames+1)]);
    
end
% Computation load Analysis - "Exhaustive search "
 
for i=1:99   
Comparisions=( 4*(mb_Y*mb_Y) + 4*mb_Y + 1);
additions = 2*(mb_Y*mb_Y);
Sum_addition= i*(Comparisions*additions)
Sum_comparision= i*Comparisions
end;

