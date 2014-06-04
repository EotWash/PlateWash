clear pause
more off 

if (1 == injectIFOSystematic)
	%Update me!
	load( [HOMEDIR '/ifo/foilTranslationToTorque.dat']);

        %Load bootstrapped IFO
	[ifoP ifoV] = loadBSFits( 'output/bootstrapArbFit.bootstrappedFits.dat');
end


%Bootstrap loop
for bootStrapCounter = 1:NumberOfYukawaBootstraps

	['yukawa bootstrap counter ' num2str(bootStrapCounter)]

	%Bootstrapping
	pMd = bootstrapData(pM);

	if(1 == injectIFOSystematic)
		%Fake torque
		outTor = foilTranslationToTorque*fitVectorPolyLinearSpline( [pMd(:,aCol) pMd(:,bCol)], ifoP(bootStrapCounter,:), ifoV(bootStrapCounter, : ) );
		%Have to _subtract_ the systematic ;).
		pMd(:,torCol) = pMd(:,torCol) - outTor;
	end

	if(SysNoX == 1)
		%Fuzz x errorbars
		pMd(:,aCol) = pMd(:,aCol) + randn(rows(pMd),1) .* pMd(:,aErrCol);
		pMd(:,bCol) = pMd(:,bCol) + randn(rows(pMd),1) .* pMd(:,bErrCol);
	end

	%'bootstrapping complete'

	%Save the real data

	SlopeFit  = [ 1 0 0 0 0 0 0];
	YukawaFit = [ 0 1 1 0 0 0 0];
	MagFit    = [ 0 0 0 1 1 0 0];
	Mag2Fit   = [ 0 0 0 0 0 1 1];
	FitOnlyThese = SlopeFit + YukawaFit + MagFit + Mag2Fit;

	%bounds defined in FixedParameters
	LowerBounds = [-SloUB, repmat([LamLB, -SysUB], 1, NumFitSystematics)];
	UpperBounds = [ SloUB, repmat([LamUB,  SysUB], 1, NumFitSystematics)];
	NumIterations = 400; %default 100, but good fits are getting truncated at 200

	%Define fit function
	cSFunc = @(x) chiSquareWSystematics(pMd, x, signalColumns, torCol);

	%Fit begins
	ranLam = log10(10.^( rand(NumFitSystematics,1) *3.0-6)/XLUnits);
	ranAlp = (-1).^(round(rand(NumFitSystematics,1))+1).*10.^(rand(NumFitSystematics,1)*11-5);
	ranSlo = (rand-0.5)*10e-12/XSUnits;

	%Compose ranSeed
	ranSeed = [ ranSlo ] 
	for ranCtr = 1:rows(ranLam)
		ranSeed = [ranSeed ranLam(ranCtr) ranAlp(ranCtr)];
	end

	ranSeed

	pause
	
	try
		%When analyzing, make a cut on csMin
		tic
		[x, csMin, fitInfo, iter, nf]   = sqp(ranSeed, cSFunc, [], [], LowerBounds, UpperBounds,NumIterations);
		[csMin fitInfo iter nf]
		bsO = [ transpose(x) csMin nf iter fitInfo ranSeed bootStrapCounter toc rows(pM)];
		%if fit converged, save it.
		if(fitInfo == 101) 
	       		bootstrapOut = [bootstrapOut; bsO];
		end

		if(1 == testInjection & ~exist("fileInjection"))
			injParameters = [lambdasInjected/XLUnits alphasInjected injSlope/XSUnits];
			outfilename = ['output/bootstrapYukawa.Sysa' num2str(alpha) 'l' num2str(lambda) 'slop' num2str(injSlope) '.dat'];
		elseif(exist("fileInjection"))
			injParameters = [0 0 0];
			outfilename = ['output/bootstrapYukawa.SysaInjected' '.dat']; 
		else
			injParameters = [0 0 0];
			outfilename = ['output/bootstrapYukawa.Sys' '.dat'];
		end
		save( outfilename, "bootstrapOut", "injParameters");
	catch
		'FIT ERROR!'
		errorMessage
	end

end %bsCnt
