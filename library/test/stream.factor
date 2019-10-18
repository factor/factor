IN: scratchpad
USE: namespaces
USE: streams
USE: stdio
USE: test
USE: generic
USE: kernel

[ "xyzzy" ] [ [ "xyzzy" write ] with-string ] unit-test

TRAITS: xyzzy-stream

M: xyzzy-stream fwrite-attr ( str style stream -- )
    [
        drop "<" delegate get fwrite
        delegate get fwrite
        ">" delegate get fwrite
    ] bind ;

M: xyzzy-stream fclose ( stream -- )
    drop ;

M: xyzzy-stream fflush ( stream -- )
    drop ;

M: xyzzy-stream fauto-flush ( stream -- )
    drop ;

C: xyzzy-stream ( stream -- stream )
    [ delegate set ] extend ;

[
    "<xyzzy>"
] [
    [
        stdio get <xyzzy-stream> [
            "xyzzy" write
        ] with-stream
    ] with-string
] unit-test
