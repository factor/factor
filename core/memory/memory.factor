! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences arrays system ;
IN: memory

: (each-object) ( quot: ( obj -- ) -- )
    [ next-object dup ] swap [ drop ] while ; inline

: each-object ( quot -- )
    begin-scan [ (each-object) ] [ end-scan ] [ ] cleanup ; inline

: instances ( quot -- seq )
    pusher [ each-object ] dip >array ; inline

: save ( -- ) image save-image ;

: save-image* ( path args -- )
    "#!" vm append swap "-shebang\n" 3array " " join
    (save-image*) ; inline
