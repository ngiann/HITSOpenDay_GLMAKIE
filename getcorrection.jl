using Optim

function getcorrection(yred, ygreen, yblue)

    xred   = [1 1 1; 0 0 0.0; 0 0 0]
    
    xgreen = [0.0 0 0;1 1 1; 0 0 0]
    
    xblue  = [0.0 0 0; 0 0 0; 1 1 1]

    function objective(p)

        local A = reshape(p, 3, 3)

        sum((A*xred - yred).^2) +  sum((A*xgreen - ygreen).^2) + sum((A*xblue - yblue).^2) 

    end


    opt = Optim.Options(iterations = 100)

    reshape(optimize(objective, randn(9), LBFGS(), opt, autodiff=:forward).minimizer, 3, 3)


end