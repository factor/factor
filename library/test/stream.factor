IN: scratchpad
USE: namespaces
USE: streams
USE: stdio
USE: test


[ "xyzzy" ] [ [ "xyzzy" write ] with-string ] unit-test

[
    "<xyzzy>"
] [
    [
        [
            "stdio" get <extend-stream> [
                [ "<" write write ">" write ] "fwrite" set
                [ "<" write write ">" print ] "fprint" set
            ] extend "stdio" set
            
            "xyzzy" write
        ] with-scope
    ] with-string
] unit-test
