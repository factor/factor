USING: kernel parser sequences stdio ;
[
    "/library/sdl/sdl.factor"
    "/library/sdl/sdl-video.factor"
    "/library/sdl/sdl-event.factor"
    "/library/sdl/sdl-gfx.factor"
    "/library/sdl/sdl-keysym.factor"
    "/library/sdl/sdl-keyboard.factor"
    "/library/sdl/sdl-ttf.factor"
    "/library/sdl/sdl-utils.factor"
] [
    dup print run-resource
] each
