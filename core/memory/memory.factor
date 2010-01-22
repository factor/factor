! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings io.backend io.pathnames kernel
memory.private sequences system ;
IN: memory

: instances ( quot -- seq )
    [ all-instances ] dip filter ; inline

: saving-path ( path -- saving-path path )
    [ ".saving" append ] keep
    [ native-string>alien ] bi@ ;

: save-image ( path -- )
    normalize-path saving-path (save-image) ;

: save-image-and-exit ( path -- )
    normalize-path saving-path (save-image-and-exit) ;

: save ( -- ) image save-image ;
