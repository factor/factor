! Copyright (C) 2009 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test id3 id3.private ;
IN: id3.tests

[
    T{ id3-info
       { title "BLAH" }
       { artist "ARTIST" }
       { album "ALBUM" }
       { year "2009" }
       { comment "COMMENT" }
       { genre "Bluegrass" }
    }
] [ "resource:extra/id3/tests/blah.mp3" file-id3-tags ] unit-test

[
    T{ id3-info
       { title "Anthem of the Trinity" }
       { artist "Terry Riley" }
       { album "Shri Camel" }
       { genre "Classical" }
    }
] [ "resource:extra/id3/tests/blah2.mp3" file-id3-tags ] unit-test

[    
    T{ id3-info
       { title "Stormy Weather" }
       { artist "Frank Sinatra" }
       { album "Night and Day Frank Sinatra" }
       { comment "eng, AG# 08E1C12E" }
       { genre "Big Band" }
    }
] [ "resource:extra/id3/tests/blah3.mp3" file-id3-tags ] unit-test

