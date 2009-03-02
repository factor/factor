! Copyright (C) 2009 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test id3 combinators ;
IN: id3.tests

: id3-params ( id3 -- title artist album year comment genre )
    {
        [ id3-title ]
        [ id3-artist ]
        [ id3-album ]
        [ id3-year ]
        [ id3-comment ]
        [ id3-genre ]
    } cleave ;

[
   "BLAH"
   "ARTIST"
   "ALBUM"
   "2009"
   "COMMENT"
   "Bluegrass"
] [ "vocab:id3/tests/blah.mp3" file-id3-tags id3-params ] unit-test

[
    "Anthem of the Trinity"
    "Terry Riley"
    "Shri Camel"
    f
    f
    "Classical"
] [ "vocab:id3/tests/blah2.mp3" file-id3-tags id3-params ] unit-test

[    
   "Stormy Weather"
   "Frank Sinatra"
   "Night and Day Frank Sinatra"
    f
   "eng, AG# 08E1C12E"
   "Big Band"
] [ "vocab:id3/tests/blah3.mp3" file-id3-tags id3-params ] unit-test

