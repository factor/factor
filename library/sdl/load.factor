USING: alien io kernel parser sequences ;

{
    { [ os "macosx" = ] [ ] }
    { [ os "win32" = ] [ "sdl" "sdl.dll" "cdecl" add-library ] }
    { [ t ] [ "sdl" "libSDL.so" "cdecl" add-library ] }
} cond

[
    "/library/sdl/sdl.factor"
    "/library/sdl/sdl-video.factor"
    "/library/sdl/sdl-event.factor"
    "/library/sdl/sdl-keysym.factor"
    "/library/sdl/sdl-keyboard.factor"
    "/library/sdl/sdl-utils.factor"
] [
    dup print run-resource
] each
