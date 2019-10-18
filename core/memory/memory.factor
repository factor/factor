! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: memory
USING: arrays kernel sequences vectors system hashtables
kernel.private sbufs growable assocs namespaces quotations
math strings combinators ;

: (each-object) ( quot -- )
    next-object dup
    [ swap [ call ] keep (each-object) ] [ 2drop ] if ; inline

: each-object ( quot -- )
    begin-scan (each-object) end-scan ; inline

: instances ( quot -- seq )
    pusher >r each-object r> >array ; inline

: save ( -- ) image save-image ;
