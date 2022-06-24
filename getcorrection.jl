using Optim

function getcorrection(xred, xgreen, xblue, yred, ygreen, yblue)


    function objective(p)

        local A = reshape(p, 3, 3)

        sum((A*xred - yred).^2) +  sum((A*xgreen - ygreen).^2) + sum((A*xblue - yblue).^2) 

    end


    opt = Optim.Options(iterations = 100)

    reshape(optimize(objective, randn(9), LBFGS(), opt, autodiff=:forward).minimizer, 3, 3)


end