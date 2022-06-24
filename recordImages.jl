using VideoIO, GLMakie, Printf
using ColorTypes, FixedPointNumbers, LinearAlgebra, Statistics

function recordImages(Tmax = 10; A = Matrix(I, 3, 3), dev = dev, seewebcam = true)
    
    VideoIO.DEFAULT_CAMERA_OPTIONS["video_size"] = "320x240"

    VideoIO.DEFAULT_CAMERA_OPTIONS["framerate"] = 10

    cam = VideoIO.opencamera(dev)

    nextimage() = rotr90(read(cam))

    typeofimg = typeof(nextimage())

    imgarray = Array{typeofimg}(undef, 0)

    modifiedimage = nextimage()


    try

        imgobs = Observable(nextimage())

        fig = Figure()

        if seewebcam

            display(fig)   

            image(fig[1,1], imgobs)

        end
        

        t0 = time()


        while time() - t0 < Tmax

            
            next = nextimage() # get next image from webcam

            local val = zeros(Float32, 3)


            @sync if seewebcam 

                @async for index in eachindex(next)

                    @inbounds local v = next[index]
        
                    mul!(val, A, [v.r;v.g;v.b])
                    
                    val .= min.(val, 1.0)

                    val .= max.(val, 0.0)

                    @inbounds modifiedimage[index] = RGB{N0f8}(val[1], val[2], val[3])
                  
                end

                imgobs[] = modifiedimage

            end

            push!(imgarray, next) # store webcam image

            sleep(0.001)

        end

    finally
      
        close(cam)

    end

    @printf("Recorded %d images\n", length(imgarray))

    return imgarray

end