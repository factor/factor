USE: test
USE: image
USE: namespaces
USE: stdio

[ "ab\0\0" ] [ 4 "ab" align-string ] unit-test

[ { 0 } ] [
    [ "\0\0\0\0" emit-chars ] with-minimal-image
] unit-test

[ { 6815845 7077996 7274528 7798895 7471212 6553600 } ]
[
    [
        "big-endian" on
        [ "hello world" pack-string ] with-minimal-image
    ] with-scope
] unit-test

[ "\0\0\0\0\u000f\u000e\r\u000c" ]
[
    [ image-magic write-big-endian-64 ] with-string
] unit-test
