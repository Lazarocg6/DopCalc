function [snr_out] = snr_in(EIRPtx, Grx, lambda, RCSb, Rtxb, Rrxb, Lsys, Fs, Brx)
%Compute bistatic RX SNR 
%   Detailed explanation goes here

    snr_out = 10.*log10((EIRPtx.*Grx.*(lambda^2).*RCSb)./(((4.*pi).^3).*(Rtxb.^2) ...
        .*(Rrxb.^2).*Lsys.*(10.^(-20.4)).*Fs.*Brx));

end

