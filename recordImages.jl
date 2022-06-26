using VideoIO, GLMakie, Printf
using ColorTypes, FixedPointNumbers, LinearAlgebra, Statistics, ColorSchemeTools

function recordImages(Tmax = 10; A = Matrix(I, 3, 3), dev = dev, seewebcam = true)

    display("v1")
    
    VideoIO.DEFAULT_CAMERA_OPTIONS["video_size"] = "320x240"

    VideoIO.DEFAULT_CAMERA_OPTIONS["framerate"] = 10

    cam = VideoIO.opencamera(dev)

    nextimage() = rotr90(read(cam))

    modifiedimage = nextimage()

    imgarray = Array{typeof(modifiedimage)}(undef, 0)



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


            if seewebcam 

                for index in eachindex(next)

                    @inbounds local v = next[index]
        
                    mul!(val, A, [v.r;v.g;v.b])
                    
                    val .= max.(min.(val, 1.0), 0.0)

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

    function convertrgbpixel(p)
        
        local v = max.(min.(A *  [p.r; p.g; p.b], 1.0), 0.0)
        
        RGB{N0f8}(v[1], v[2], v[3])

    end

    for img in imgarray
        for i in eachindex(img)
            @inbounds img[i] = convertrgbpixel(img[i])
        end
    end

    return imgarray

    
end