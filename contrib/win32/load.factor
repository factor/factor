IN: win32
USING: alien compiler kernel parser sequences words ;

win32? [
    "user" "user32.dll" "stdcall" add-library
    "kernel" "kernel32.dll" "stdcall" add-library
] [
    ! something with wine here?
] if

[ "utils.factor" "types.factor" "kernel32.factor" "user32.factor" ]

[ "contrib/win32/" swap append run-file ] each

"win32" words [ try-compile ] each
