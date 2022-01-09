X=imread("F:/vivado_files/picture.jpeg");
X_resized=imresize(X,4.1);
X_resized=X_resized(1:4340,1:7808,:);
X_R=X_resized(:,:,1);
X_G=X_resized(:,:,2);
X_B=X_resized(:,:,3);
%imshow(X_resized);
%------------gen raw pic--------------------------
X_final=ones(4340,7808);
%R 奇数行奇数列
X_final(1:2:4339,1:2:7807)=X_R(1:2:4339,1:2:7807);
%B 偶数行偶数列
X_final(2:2:4340,2:2:7808)=X_B(2:2:4340,2:2:7808);
%Gr 奇数行偶数列
X_final(1:2:4339,2:2:7808)=X_G(1:2:4339,2:2:7808);
%Gb 偶数行奇数列
X_final(2:2:4340,1:2:7807)=X_G(2:2:4340,1:2:7807);
%-------lane1(first lane of bank u0)---------------
%X_lane_upper_1=X_final(:,2:2:488);
X_lane_upper_1=X_final(:,2:4:974);
%因为fwrite先写列所以转置一下,使其先写行,符合传输逻辑
X_lane_upper_1_T=X_lane_upper_1';
%---------导出------------------------
fileID=fopen("F:/vivado_files/lane_u1.bin","w");
fwrite(fileID,X_lane_upper_1_T,'uint16');
fclose(fileID);










