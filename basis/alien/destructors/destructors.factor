! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors destructors effects functors generalizations
kernel parser sequences ;
IN: alien.destructors

TUPLE: alien-destructor alien ;

<FUNCTOR: define-destructor ( F -- )

F-destructor DEFINES-CLASS ${F}-destructor
<F-destructor> DEFINES <${F}-destructor>
&F DEFINES &${F}
|F DEFINES |${F}
N [ F stack-effect out>> length ]

WHERE

TUPLE: F-destructor < alien-destructor ;

: <F-destructor> ( alien -- destructor )
    F-destructor boa ; inline

M: F-destructor dispose alien>> F N ndrop ;

: &F ( alien -- alien ) dup <F-destructor> &dispose drop ; inline

: |F ( alien -- alien ) dup <F-destructor> |dispose drop ; inline

;FUNCTOR>

SYNTAX: DESTRUCTOR: scan-word define-destructor ;
