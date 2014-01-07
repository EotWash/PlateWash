%Returns the three axis force and torque on array1 by array2
%array entries of the form [m, x, y, z] 
function [force, torque]=pointMatrixGravity(array1,array2)

	force = [0 0 0];

	torque = [0 0 0];

	for i = 1:rows(array1)

			iforce=Gmmr2Array( array1(i,:),array2);
	
			itorque=cross(array1(i,2:4),iforce', 2);

			torque += itorque;
			force  += iforce';

	end
end

%!test
%! 'pointMatrix force test'
%! fundamentalConstants
%! m1 = [1 0 0 0];
%! m2 = [1 1 0 0];
%! [F T] = pointMatrixGravity(m1,m2);
%! Fg = G;
%! assert(abs(F(1) - Fg) < 2*eps)
%! assert(abs(F(2:3)) < 2*eps)
%! assert(abs(T) < 2*eps)

%!test
%! 'pointMatrix torque test'
%! fundamentalConstants
%! m1 = [1 0 1 0];
%! m2 = [1 1 1 0];
%! [F T] = pointMatrixGravity(m1,m2);
%! Fg = G;
%! assert(abs(F(1) - Fg) < 2*eps)
%! assert(abs(F(2:3)) < 2*eps)
%! assert(abs(T(1:2) < 2*eps)
%! assert(abs(T(3)+ Fg) < 2*eps)

%!test 
%! 'pointMatrix ISL convergence test'
%! fundamentalConstants
%! m1 = genPointMassAnnlSheet( 1, 0, 1, 1, 5, 10);
%! for ctr = 1:100
%! 	exp = rand*5+2;
%!	d = 10^exp;
%!	r = randn*0.01;
%!	md = translatePMArray(m1, [d,r,0]);
%!	[F T] = pointMatrixGravity(m1,md);
%!	assert(sum(abs(T)) < 6*eps)
%!	assert( abs(F(1) - G/d^2 ) / (G/d^2) < 0.001)
%!  end

%!test
%! 'pointMatrix sheet uniformity test'
%! fundamentalConstants
%! tm = [1 0 0 0];
%! %r = 20; t = 0.01; xspacing = 0.0025; rspacing = 0.05; m = 20000*pi*r*r*t;
%! r = 20; t = 0.01; xspacing = 0.0025; rspacing = 0.5; m = 20000*pi*r*r*t;
%! sheet = genPointMassAnnlSheet(m , 0, r, t, t/xspacing, r/rspacing);
%! v = [];
%! for ctr = 1:10
%!	ctr
%!	d = rand+rspacing; %yes, rand
%!	y = randn*rspacing;
%!	z = randn*rspacing;
%!	s = translatePMArray( sheet, [d,y,z]);
%!	v = [v; d y z pointMatrixGravity(tm, s)];
%!	clear s
%! end
%! plot(v(:,1), v(:,4), '+')


%!test 
%! "newton's shell theorem"
%! shell = genPointMassSphericalRandomShell(1, 10, 100000);
%! v = [];
%! for ctr = 1:100
%! 	p = randn(1,3);
%!	m = [1 0 0 0];
%!	s = translatePMArray(shell, p);
%!	v = [v; p, pointMatrixGravity(m, s)]
%! end
%!  plot( v(:,3), sqrt( sum(v(:,4:6).^2,2)) )
