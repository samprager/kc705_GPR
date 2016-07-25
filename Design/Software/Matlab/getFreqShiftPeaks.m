function [Sf,fshift,tshift,ind] = getFreqShiftPeaks(sDAC,sADC,Fs,chirpBW,chirpT,fftlen,threshDB)
Sf = [];
fshift = 0;
tshift = 0;

if (numel(sDAC)~= numel(sADC))
    fprintf('Error: Input signals must have equal length\n');
    return;
end

chirpSlope = chirpBW/chirpT;     
sMix = sDAC.*sADC;
SfMix = fft(sMix,fftlen);
Sf = SfMix(1:ceil(end/2));
Sf_sq = abs(Sf).^2;
maxval = max(Sf_sq)
medval = median(Sf_sq);
threshval = medval*(10^(threshDB/10))
Sf_sq(Sf_sq<threshval)=0;
[val, ind] = findpeaks(Sf_sq);
fshift = (ind-1)*(Fs/2)/numel(Sf);
tshift = fshift/chirpSlope;
figure; hold on; plot(abs(Sf).^2); plot(Sf_sq); scatter(ind,val);
end