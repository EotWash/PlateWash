fundamentalConstants

d = load('finalPressure.dat');

printSI(d, 1, -9, 'torr', 'extracted/finalPressureTorr.tex');

printSI(d*OnePascalInTorr, 1, -6,'Pa', 'extracted/finalPressurePa.tex', 2);
