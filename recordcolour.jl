function recordcolour(clr, darkframe, maskindices)

    tprint(Panel(RenderableText("\nWe will capture a {$clr bold}$clr{/$clr bold} image for the purpose of working out the pixels that correspond to the actual viewing area.
    \nBefore proceeding:
    \n • Ensure that you see a {$clr bold}$clr{/$clr bold} image that covers the entire screen.
    \n • Make sure the camera is correctly pointing to the screen.
    \nWe will now record a few frames. Press enter to continue with recording.",width=60),
    title="{$clr bold}Record $clr colour{/$clr bold}", 
    title_justify=:centre))

    pressanykey()

    webcamimages, = recordImages(darkframe, 2, maskindices; A = Matrix(I, 3, 3), dev=GLOBALDEV)
    

    tprint(Panel(RenderableText("\nThe recording was completed. You will now need to choose representaive frames. Please press enter to continue.",width=60),
    title="{$clr bold}Record $clr colour{/$clr bold}", 
    title_justify=:centre))

    pressanykey()

    selectedindices = zeros(Int,0)

    options = ["yes","no","exit"]

    howmanyimages = 3

    while length(selectedindices) < howmanyimages
       
        local randindex = ceil(Int, length(webcamimages))
       
        local fig = Figure()
        
        display(fig)   

        image(fig[1,1], webcamimages[randindex])

        local choice = request("Is this frame a good represenative of a $clr frame?", RadioMenu(options))

        if choice == 1
            push!(selectedindices, randindex)
        elseif choice == 2
            # do nothing
        else 
            break
        end

        @printf("Need another %d images\n", howmanyimages-length(selectedindices))
        
    end

    
    DONE = length(selectedindices) == howmanyimages
    
    colourmean = DONE ? reduce(hcat, [getmeanfromindices(w, maskindices) for w in webcamimages[selectedindices]]) : nothing

    return DONE, colourmean

end
