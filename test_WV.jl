using VideoIO, GLMakie, Statistics
using DataStructures: CircularBuffer

function test(Tmax = 10; dev = dev)
    
    cam = VideoIO.opencamera(dev)
   

    fig = Figure(backgroundcolor = :black, resolution=(1400, 2000))
    
    display(fig)

    ax = Axis(fig[1,1],backgroundcolor = :black, title = "Aufzeichnung", xlabel = "Zeit", ylabel = "Lichtfluss")

    fontsize_theme = Theme(fontsize = 35, fontcolor=:white, textcolor=:white)

    set_theme!(fontsize_theme)

    xlims!(ax, 0, Tmax); ylims!(ax, 0, 1.0)



    t0 = time()

    function nextvalues()
        
        local img = read(cam)

        local μ = mean(img)
        
        return time()-t0, μ.b, μ.r, rotr90(img)

    end



    # Here we plot image captured from webcam
    
    aximg = fig[2, 1]

    imgobs = Observable(nextvalues()[4])

    image(aximg, imgobs)


    
    # Here we store lightcurves and recorded time

    tobs, yblue, yred = zeros(0), zeros(0), zeros(0)

    

    try     

        tail = 10000

        markersize = 10


        # Plotting for BLUE light curve

        trajblue = CircularBuffer{Point2f}(tail)

        fill!(trajblue, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsblue = Observable(trajblue) # make it an observable

        c = to_color(:cyan)

        tailcolblue = [RGBAf(c.r, c.g, c.b, (i/tail)^2) for i in 1:tail]

        scatter!(ax, trajobsblue; markersize=markersize, color = tailcolblue)


        # Plotting for RED light curve

        trajred = CircularBuffer{Point2f}(tail)

        fill!(trajred, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsred = Observable(trajred) # make it an observable

        c = to_color(:red)

        tailcolred = [RGBAf(c.r, c.g, c.b, (i/tail)^2) for i in 1:tail]

        scatter!(ax, trajobsred; markersize=markersize,  color = tailcolred)


        
        while time() - t0 < Tmax
            
            t, blueval, redval, imgobs[] = nextvalues() # get next input from webcam

            push!(tobs,t) # store timestamp
            push!(yblue,blueval) # store blue value
            push!(yred,redval) # store red value

            push!(trajobsblue[], Point2f(t, blueval)) # update blue curve
            push!(trajobsred[],  Point2f(t, redval))  # update red curve

            trajobsblue[] = trajobsblue[] # meaningless line to force update
            trajobsred[] = trajobsred[]   # meaningless line to force update

            sleep(0.001)

        end

    finally
      
        close(cam)

    end

    tobs, yblue, yred

end