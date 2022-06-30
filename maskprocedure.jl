function maskprocedure()

    tprint(Panel(RenderableText("\nWe will capture a {red bold}red{/red bold} image for the purpose of working out the pixels that correspond to the actual viewing area.
    \nBefore proceeding:
    \n • Ensure that you see a {red bold}red{/red bold} image that covers the entire screen.
    \n • Make sure the camera is correctly pointing to the screen.
    \nWe will now record a few frames. Press enter to continue with recording.",width=60),
    title="{bold}Define mask indices{/bold}", 
    title_justify=:centre))

    pressanykey()

    webcamimages, = recordImages_nodarkframe(2; A = Matrix(I, 3, 3), dev=GLOBALDEV)
    

    tprint(Panel(RenderableText("\nThe recording was completed. You will now need to determine a numerical value that segments the vieweing area. Please press enter to continue.",width=60),
    title="{bold}Define mask indices{/bold}", 
    title_justify=:centre))

    pressanykey()

    DONE_mask = false

    valuesofoptions = 0:0.1:1

    options = map(string, valuesofoptions)

    secondoptions = ["yes", "no, please repeat", "exit"]

    maskidx = nothing


    while ~DONE_mask
      
        local choice = request("Choose a value", RadioMenu(options, pagesize = length(options)))

        local val = valuesofoptions[choice]

        local fig = Figure()
        
        display(fig)   

        maskidx = getmaskinred(webcamimages[end]; val = val)
        
        Fake = zeros(size(webcamimages[end])); Fake[maskidx] .= 1; 

        image(fig[1,1], webcamimages[end])

        for i in 1:5
    
            image!(webcamimages[end])
           
            sleep(0.5)
           
            image!(Fake)

            sleep(0.5)

        end


        local secondchoice = request("Is this OK?", RadioMenu(secondoptions))

        if secondchoice == 1
       
            DONE_mask = true
       
        elseif secondchoice == 2
            
            DONE_mask = false 
       
        else 
       
            DONE_mask = false
            break # exit loop
       
        end

    end

    
    return DONE_mask, maskidx

end
