function darkframeprocedure()

    tprint(Panel(RenderableText("\nWe will capture the darkframe, the image that appears when no activity is shown on the screen.
    \nBefore proceeding:
    \n • Ensure that the screen shows no activity.
    \n • Make sure the camera is correctly pointing to the screen.
    \nWe will now record a few frames. Press enter to continue with recording.",width=60),
    title="{bold}Record darkframe{/bold}", 
    title_justify=:centre))

    pressanykey()

    webcamimages, = recordImages_nodarkframe(4; A = Matrix(I, 3, 3), dev=GLOBALDEV)
    

    tprint(Panel(RenderableText("\nThe recording was completed. You will now be shown a few frames and you can choose which ones look representative. Please press enter to continue.",width=60),
    title="{bold}Record darkframe{/bold}", 
    title_justify=:centre))

    pressanykey()

    selectedindices = zeros(Int,0)

    options = ["yes","no","exit"]

    howmanyimages = 5

    while length(selectedindices) < howmanyimages
       
        local randindex = ceil(Int, length(webcamimages))
       
        local fig = Figure()
        
        display(fig)   

        image(fig[1,1], webcamimages[randindex])

        local choice = request("Is this frame represenative of the darkframe?", RadioMenu(options))

        if choice == 1
            push!(selectedindices, randindex)
        elseif choice == 2
            # do nothing
        else 
            break
        end

        @printf("Need another %d images\n", howmanyimages-length(selectedindices))
        
    end

    
    DONE_darkframe = length(selectedindices) == howmanyimages
    
    darkframe = DONE_darkframe ? mean(webcamimages[selectedindices]) : nothing

    return DONE_darkframe, darkframe

end
