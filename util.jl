trim(x; startat=startat, endat=endat) = x[startat:endat]

function getmeanfromindices(q, idx) 
    
    local a = mean(q[idx])
    
    [a.r;a.g;a.b]

end


function getmaskingreen(img; val = val)

    findall([img[i].g >= val for i in eachindex(img)])

end

function getmaskinred(img; val = val)

    findall([img[i].r >= val for i in eachindex(img)])

end

function getmaskinblue(img; val = val)

    findall([img[i].b >= val for i in eachindex(img)])

end

# ygreen = reduce(hcat, [getmeanfromindices(w, maskidx) for w in webcamimages[[40,60,70]]])

# maskidx = getmaskinred(webcamimages[end]; val = 0.3)

# delays = [2^(i/3)*0.46125 for i in -1:13]