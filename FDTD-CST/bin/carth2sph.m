function [ Fs_pw_rthph] = carth2sph(pos, Fs_pw)
    Fs_pw_rthph=zeros(size(Fs_pw));
    [az,el,~]=cart2sph(pos(:,1),pos(:,2),pos(:,3));
    el=-el+pi/2;
    az(az<0)=2*pi+az(az<0);

    for m=1:2*length(pos)
        for n=1:length(pos)
            Fs_pw_rthph(n,:,m)=([sin(el(n))*cos(az(n)) sin(el(n))*sin(az(n)) cos(el(n));  cos(el(n))*cos(az(n)) cos(el(n))*sin(az(n)) -sin(el(n)); -sin(az(n)) cos(az(n)) 0]*(Fs_pw(n,:,m).'));
        end
    end

end