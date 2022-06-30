using VideoIO, GLMakie, Printf
using ColorTypes, FixedPointNumbers, LinearAlgebra, Statistics, ColorSchemeTools
using DataStructures: CircularBuffer

function recordImages_nodarkframe(Tmax = 10, maskidx = 1:(640*360); A = Matrix(I, 3, 3), dev = dev)

    darkframe = Matrix{RGB{Float32}}(undef, 640, 360)

    fill!(darkframe, RGB{Float32}(0.0, 0.0, 0.0))

    recordImages(darkframe, Tmax, maskidx; A = A, dev = dev)

end


function recordImages(darkframe, Tmax = 10, maskidx = 1:(640*360); A = Matrix(I, 3, 3), dev = dev)

    # display("darkframe")
    
    VideoIO.DEFAULT_CAMERA_OPTIONS["video_size"] = "640x360"

    VideoIO.DEFAULT_CAMERA_OPTIONS["framerate"] = 10

    cam = VideoIO.opencamera(dev)

    nextimage() = rotr90(read(cam))

    modifiedimage = Matrix{RGB{Float32}}(undef, 640, 360)

    fill!(modifiedimage, RGB{Float32}(0.0, 0.0, 0.0))

    imgarray = Array{typeof(modifiedimage)}(undef, 0)


    tsec, μred, μgreen, μblue = zeros(Float32, 0), zeros(Float32, 0), zeros(Float32, 0), zeros(Float32, 0)

    try

        imgobs = Observable(nextimage())

        fig = Figure(backgroundcolor = :black)

        display(fig)   

        image(fig[1,1], imgobs)



        ax = Axis(fig[2,1],backgroundcolor = :black, title = "Aufzeichnung", xlabel = "Zeit", ylabel = "Lichtfluss")

        fontsize_theme = Theme(fontsize = 35, fontcolor=:white, textcolor=:white)

        set_theme!(fontsize_theme)

        xlims!(ax, 0, Tmax); ylims!(ax, 0, 1.0)




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



         # Plotting for GREEN light curve

         trajgreen = CircularBuffer{Point2f}(tail)

         fill!(trajgreen, Point2f(-20,0)) # add correct values to the circular buffer
 
         trajobsgreen = Observable(trajgreen) # make it an observable
 
         c = to_color(:green)
 
         tailcolgreen = [RGBAf(c.r, c.g, c.b, (i/tail)^2) for i in 1:tail]
 
         scatter!(ax, trajobsgreen; markersize=markersize,  color = tailcolgreen)
 
        
        

        t0 = time()

        while time() - t0 < Tmax

            t = time() - t0 

            next = nextimage() # get next image from webcam

            local val = zeros(Float32, 3)

            local μ = zeros(Float32, 3)

            @sync @async for index in maskidx#eachindex(next)

                @inbounds local v = next[index] - darkframe[index]
    
                mul!(val, A, [v.r;v.g;v.b])
                
                val .= max.(min.(val, 1.0), 0.0)

                μ .+= val

                @inbounds modifiedimage[index] = RGB{N0f8}(val[1], val[2], val[3])
                
            end

            imgobs[] = modifiedimage

            μ ./= length(maskidx)

            redval, greenval, blueval = μ[1], μ[2], μ[3]

            push!(μred,  redval)

            push!(μgreen, greenval)

            push!(μblue, blueval)

            push!(tsec, t)



            push!(trajobsblue[], Point2f(t, blueval)) # update blue curve
            push!(trajobsred[],  Point2f(t, redval))  # update red curve
            push!(trajobsgreen[],  Point2f(t, greenval))  # update green curve

            trajobsblue[] = trajobsblue[] # meaningless line to force update
            trajobsred[] = trajobsred[]   # meaningless line to force update
            trajobsgreen[] = trajobsgreen[]   # meaningless line to force update


            push!(imgarray, next-darkframe) # store webcam image

            sleep(0.001)

        end

    finally
      
        close(cam)

    end

    @printf("Recorded %d images\n", length(imgarray))

    #### KEEP COMMENTED OUT CODE BELOW ####

    # # verify that we have calculated mean values of CORRECTED image properly
    # verifymean  = zeros(3, length(imgarray))

    # convertrgbpixel(p) = max.(min.(A *  [p.r; p.g; p.b], 1.0), 0.0)

    # @inbounds for (indeximg, img) in enumerate(imgarray)
    #     for pixel in img
    #         verifymean[:,indeximg] += convertrgbpixel(pixel) / length(img)
    #     end
    # end

    return imgarray, tsec, μred, μgreen, μblue#, verifymean

    
end