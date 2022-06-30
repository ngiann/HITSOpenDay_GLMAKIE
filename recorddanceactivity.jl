function recorddanceactivity(darkframe, maskindices, CorrectionInverseMatrix)

    local webcamimages, timeinsecs, redflux, greenflux, blueflux = recordImages(darkframe, 30, maskindices, A=CorrectionInverseMatrix, dev=GLOBALDEV);

    PyPlot.figure(10)
    PyPlot.title("Geschätzte Zeitverschiebung")
    nlags = length(timeinsecs)-1
    PyPlot.plot(timeinsecs[1:nlags],exp.(crosscor(blueflux,redflux,1:nlags)),".")

end