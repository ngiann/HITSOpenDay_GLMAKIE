using VideoIO, GLMakie, Statistics

function test()
    
    t0 = time()

    cam = VideoIO.opencamera()

    try
        img = read(cam)
        obs_img = GLMakie.Observable(GLMakie.rotr90(img))
        scene = GLMakie.Scene(camera=GLMakie.campixel!, resolution=reverse(size(img)))
        GLMakie.image!(scene, obs_img)

        display(scene)

        fps = VideoIO.framerate(cam)
        while GLMakie.isopen(scene)
            
            img = read(cam)
            
            t = time()-t0

            obs_img[] = GLMakie.rotr90(img)
            
            # μ = mean(img)

            # scatter(t, μ.r)

            sleep(1 / fps)
        end

    finally
      close(cam)
    end

end