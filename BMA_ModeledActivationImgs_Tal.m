function ExpImg = BMA_ModeledActivationImgs_Faster(theexps)

EDsub = 11.6; %Based on Eickhoffs 2009 paper
EDtemp = 5.7; %Based on Eickhoffs 2009 paper
sigmasub = EDsub/(2*sqrt(2/pi));
sigmatemp = EDtemp/(2*sqrt(2/pi));
clear EDsub EDtemp
FWHMsub = sigmasub*sqrt(8*log(2));
FWHMtemp = sigmatemp*sqrt(8*log(2));
clear sigmatemp sigmasub
testmat = 80*96*70;
[i(:,1), i(:,2), i(:,3)] = ind2sub([80 96 70], 1:testmat);
clear testmat
i = i-0.5;

for a = 1:numel(theexps)
    tempmatrix = theexps(a).XYZ_Tal;
    FWHMsubeff = FWHMsub/sqrt(double(theexps(a).Subject_Total));
    FWHM = sqrt((FWHMtemp^2)+(FWHMsubeff^2));
    clear FWHMsubeff
    sigma = FWHM/(2*sqrt(2*log(2)));
    clear FWHM
    denomout = 1/(((2*pi)^1.5)*(sigma^3));
    denomin = 1/(2*(sigma^2));
    clear sigma
    
    distmat = denomin*(-4)*(pdist2(tempmatrix, i).^2);
    clear tempmatrix denomin
    p = 8*denomout*exp(distmat);
    clear denomout distmat
    p(find(p<0.00001)) = 0;
    
    finalp = max(p, [], 1);
    clear p
    ExpImg(a).ModActs = reshape(finalp, [80 96 70]);
    clear finalp
end

end