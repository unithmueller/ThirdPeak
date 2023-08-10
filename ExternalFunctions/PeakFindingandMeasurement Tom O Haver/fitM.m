function err = fitM(lam,yobsd,Spectra,InstFun,StrayLight)
% Fitting function for broadened absorption of any number of components


% InstFunction = Instrument function or slit function. (column vector)





global z



fa=fft(InstFun);
fy1=fy.*fa;
z=real(ifft(fy1))./sum(InstFun);
c = z\yobsd;
q = z*c;
