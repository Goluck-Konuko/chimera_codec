function motionCompenstatedFrame = motion_compensation(ref,mvf)
%MC Integer pixel motion compensation
%    MOTCOMP = MC(REF,MVF) computes the motion-compensated version of REF,
%    using the vector field stored in MVF. This field should be dense, i.e.
%    one vector per pixel)
%
[rows, cols] = size(ref);
motionCompenstatedFrame=zeros(rows,cols);
for r=1:rows
    for c=1:cols
        mc_r = r + mvf(r,c,1);
        mc_c = c + mvf(r,c,2);
        motionCompenstatedFrame(r,c)=ref(mc_r,mc_c);
    end
end 
