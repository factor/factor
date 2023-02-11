! Copyright (C) 2009 Tim Wawrzynczak
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test id3 combinators grouping id3.private
sequences math ;
IN: id3.tests

: id3-params ( id3 -- title artist album year comment genre )
    {
        [ title ]
        [ artist ]
        [ album ]
        [ year ]
        [ comment ]
        [ genre ]
    } cleave ;

{
    "BLAH"
    "ARTIST"
    "ALBUM"
    "2009"
    "COMMENT"
    "Bluegrass"
} [ "vocab:id3/tests/blah.mp3" mp3>id3 id3-params ] unit-test

{
    "Anthem of the Trinity"
    "Terry Riley"
    "Shri Camel"
    f
    f
    "Classical"
} [ "vocab:id3/tests/blah2.mp3" mp3>id3 id3-params ] unit-test

{
    "Stormy Weather"
    "Frank Sinatra"
    "Night and Day Frank Sinatra"
     f
    "eng, AG# 08E1C12E"
    "Big Band"
} [ "vocab:id3/tests/blah3.mp3" mp3>id3 id3-params ] unit-test


{ t }
[ 10000 <iota> [ synchsafe>sequence sequence>synchsafe ] map [ < ] monotonic? ] unit-test
