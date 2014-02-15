function gbar = GBar(x,y,sx,sy,B,sB,A,L,C)

	gbar = ...
	sum(A.*B.*( ...
		 exp( (sx.^2/2-x)./L) ...
		-exp( (sy.^2/2-y)./L) ...
	) ...
	+ C*(x-y);

end
