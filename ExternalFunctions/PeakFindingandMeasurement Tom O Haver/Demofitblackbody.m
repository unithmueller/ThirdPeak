% Demos iterative fit to computer-generated blackbody spectrum
Temperature=fminsearch(@(lambda)(fitblackbody(lambda,wavelength,radiance)),start);