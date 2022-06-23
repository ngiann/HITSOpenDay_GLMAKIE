using VideoIO, GLMakie, Statistics
using DataStructures: CircularBuffer

function test(Tmax = 10; dev = dev)
    
    cam = VideoIO.opencamera(dev)
   
    fig = Figure(backgroundcolor = :black)#, resolution=(3500, 1000))
    
    display(fig)

    ax = Axis(fig[1,1],backgroundcolor = :black, title = "Aufzeichnung", xlabel = "Zeit", ylabel = "Lichtfluss")

    fontsize_theme = Theme(fontsize = 35, fontcolor=:white, textcolor=:white)

    set_theme!(fontsize_theme)

    xlims!(ax, 0, Tmax); ylims!(ax, 0, 1.0)


    tobs, yblue, yred = zeros(0), zeros(0), zeros(0)

    
    t0 = time()

    function nextvalues()
        
        local img = read(cam)

        local μ = mean(img)
        
        return time()-t0, μ.b, μ.r

    end


    try     

        tail = 100


        trajblue = CircularBuffer{Point2f}(tail)

        fill!(trajblue, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsblue = Observable(trajblue) # make it an observable

        c = to_color(:cyan)

        tailcolblue = [RGBAf(c.r, c.g, c.b, (i/tail)^2) for i in 1:tail]

        scatter!(ax, trajobsblue; markersize=32, color = tailcolblue)



        trajred = CircularBuffer{Point2f}(tail)

        fill!(trajred, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsred = Observable(trajred) # make it an observable

        c = to_color(:red)

        tailcolred = [RGBAf(c.r, c.g, c.b, (i/tail)^2) for i in 1:tail]

        scatter!(ax, trajobsred; markersize=32,  color = tailcolred)


        
        while time() - t0 < Tmax
            
            t, blueval, redval = nextvalues()

            push!(tobs,t)
            push!(yblue,blueval)
            push!(yred,redval)

            push!(trajobsblue[], Point2f(t, blueval))
            push!(trajobsred[],  Point2f(t, redval))

            trajobsblue[] = trajobsblue[]
            trajobsred[] = trajobsred[]

            sleep(0.0001)

        end

    finally
      
        close(cam)

    end

    tobs, yblue, yred

end