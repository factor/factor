! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences system
io.backend alien.strings memory.private ;
IN: memory

: instances ( quot -- seq )
    [ all-instances ] dip filter ; inline

: save-image ( path -- )
    normalize-path native-string>alien (save-image) ;

: save-image-and-exit ( path -- )
    normalize-path native-string>alien (save-image-and-exit) ;

: save ( -- ) image save-image ;
