! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: memory
USING: kernel sequences vectors system ;

: (each-object) ( quot -- )
    next-object dup
    [ swap [ call ] keep (each-object) ] [ 2drop ] if ; inline

: each-object ( quot -- )
    begin-scan (each-object) end-scan ; inline

: (instances) ( obj quot seq -- )
    >r over >r call [ r> r> push ] [ r> r> 2drop ] if ; inline

: instances ( quot -- seq )
    10000 <vector> [
        -rot [ (instances) ] 2keep
    ] each-object nip ; inline

: save ( -- ) image save-image ;
