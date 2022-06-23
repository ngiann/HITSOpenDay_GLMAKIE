using VideoIO, GLMakie, Statistics
using DataStructures: CircularBuffer

function test(Tmax = 10)
    
    cam = VideoIO.opencamera()

    t0 = time()
   
    fig = Figure(backgroundcolor = :black, resolution=(2800, 800))
    
    display(fig)

    ax = Axis(fig[1,1],backgroundcolor = :black, title = "Aufzeichnung", xlabel = "Zeit", ylabel = "Lichtfluss")

    fontsize_theme = Theme(fontsize = 35, fontcolor=:white, textcolor=:white)

    set_theme!(fontsize_theme)

    xlims!(ax, 0, Tmax); ylims!(ax, 0, 1.0)


    tobs, yblue, yred = zeros(0), zeros(0), zeros(0)

    function nextvalues()
        
        local img = read(cam)

        local μ = mean(img)
        
        return time()-t0, μ.b, μ.r

    end


    try     
    
        trajblue = CircularBuffer{Point2f}(100)

        fill!(trajblue, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsblue = Observable(trajblue) # make it an observable


        trajred = CircularBuffer{Point2f}(100)

        fill!(trajred, Point2f(-20,0)) # add correct values to the circular buffer

        trajobsred = Observable(trajred) # make it an observable


        scatter!(ax, trajobsblue; linewidth=8, color=:cyan)

        scatter!(ax, trajobsred; linewidth=8, color=:red)

        while time() - t0 < Tmax
            
            t, blueval, redval = nextvalues()

            push!(tobs,t)
            push!(yblue,blueval)
            push!(yred,redval)

            push!(trajobsblue[], Point2f(t, blueval))
            push!(trajobsred[],  Point2f(t, redval))

            trajobsblue[] = trajobsblue[]
            trajobsred[] = trajobsred[]

            sleep(0.02)

        end

    finally
      close(cam)
    end

    tobs, yblue, yred

end