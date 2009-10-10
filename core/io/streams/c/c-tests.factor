USING: tools.test io.files io.files.temp io io.streams.c
io.encodings.ascii strings destructors kernel ;
IN: io.streams.c.tests

[ "hello world" ] [
    "hello world" "test.txt" temp-file ascii set-file-contents

    "test.txt" temp-file "rb" fopen <c-reader> stream-contents
    >string
] unit-test

[ 0 ]
[ "test.txt" temp-file "rb" fopen <c-reader> [ stream-tell ] [ dispose ] bi ] unit-test

[ 3 ] [
    "test.txt" temp-file "rb" fopen <c-reader>
    3 over stream-read drop
    [ stream-tell ] [ dispose ] bi
] unit-test
