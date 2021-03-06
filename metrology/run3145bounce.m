%hold on

try
run3145syncSingle
catch
end

run3147MetrologyParameters
run3147PendulumParameters

phitop=pwData(:,pwPhiTopCol)*1e-6;
psdTheta=pwData(:,psdCol);


%three copies
distanceDown = repmat(phitop, 1,3) - bounceTouchPosition;

%Uncertainty bands
distanceDown(:,2) = distanceDown(:,2) - bounceTestU;
distanceDown(:,3) = distanceDown(:,3) + bounceTestU;

%Scale to radians
distanceDown = distanceDown./(pendulumBodyWidth/2.0);

distanceUp   = -distanceDown + bounceAngleOffset;
distanceDown =  distanceDown + bounceAngleOffset;

angOut = [phitop psdTheta*psdToRadians distanceDown distanceUp];

plot(phitop,psdTheta * psdToRadians,'1.', phitop, distanceDown,'.3', phitop, distanceUp,'.3');

save 'run3145bounce.dat' angOut

hold off
