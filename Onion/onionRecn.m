% Recontructing the onion: 
% INPUT: lambda -- the Lagrange multiplier
%        factor -- super-resolving factor
% OUTPUT: recImg -- reconstructed image
%
% We recontruct the fresh onion sample from experimental data by using the
% proposed algorithm. The data is collected from a Thorlabs GAN620C1
% Authors: Yuye Ling and Mengyuan Wang

function [recImg] = onionRecn(lambda, factor)
    % numSpec defines the sampling number of the spectral interferogram
    % numRecn defines the grid size of the original function
    numSpec = 2048;
    numRecn = numSpec;

    % The starting and ending wavelength are obtained directly from Thorlabs
    % support department
    lambdaSt = 791.6e-9;
    lambdaEnd = 994e-9;
    kSt = 2 * pi / lambdaEnd;
    kEnd = 2 * pi / lambdaSt;
    k = linspace(kEnd, kSt, numSpec)';
    load('Sk_onion.mat');
    Sk = Sk' ./ (sum(Sk)) * numRecn;

    % dz_fft gives the axial pixel size (digital resolution) after conventional
    % IDFT processing (w/o zero padding)
    dzFFT = 0.5 * 1 / (1 / lambdaSt - 1 / lambdaEnd);
    dzRecn = dzFFT / factor;
    zRecn = linspace(0, (numRecn - 1) * dzRecn, numRecn)';

    fringe = h5read('rawSpectrumOnionThorlab.h5','/rawData');
    [zGridRecn, kGrid] = meshgrid(zRecn, k);
    matFourRecn = exp(2j * zGridRecn .* kGrid);
    specRecn = repmat(Sk, 1 , numRecn);
    matTranRec = specRecn .* matFourRecn;
    D = eye(numRecn);
    recImg = zeros(numRecn, size(fringe, 2));
    for iCol = 1: size(fringe, 2)
        iCol
        [recImg(:, iCol), history] = lasso(matTranRec, fringe(:, iCol), D, lambda, 10, 1.2);
    end
    str = sprintf('onion_lambda_%d_factor_%d.mat', lambda, factor);
    save(str, 'recImg','-v6');
end