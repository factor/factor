IN: scratchpad
USE: namespaces
USE: streams
USE: stdio
USE: test
USE: stack
USE: generic

[ "xyzzy" ] [ [ "xyzzy" write ] with-string ] unit-test

TRAITS: xyzzy-stream

M: xyzzy-stream fwrite-attr ( str style stream -- )
    [
        drop "<" delegate get fwrite
        delegate get fwrite
        ">" delegate get fwrite
    ] bind ;M

M: xyzzy-stream fclose ( stream -- )
    drop ;M

M: xyzzy-stream fflush ( stream -- )
    drop ;M

M: xyzzy-stream fauto-flush ( stream -- )
    drop ;M

C: xyzzy-stream ( stream -- stream )
    [ delegate set ] extend ;C

[
    "<xyzzy>"
] [
    [
        "stdio" get <xyzzy-stream> [
            "xyzzy" write
        ] with-stream
    ] with-string
] unit-test
