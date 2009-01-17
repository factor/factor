! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors destructors accessors kernel lexer words ;
IN: alien.destructors

FUNCTOR: define-destructor ( F -- )

F IS ${F}
F-destructor DEFINES ${F}-destructor
&F DEFINES &${F}
|F DEFINES |${F}

WHERE

TUPLE: F-destructor alien disposed ;

M: F-destructor dispose* alien>> F execute ;

: &F ( alien -- alien )
    dup f F-destructor boa &dispose drop ; inline

: |F ( alien -- alien )
    dup f F-destructor boa |dispose drop ; inline

;FUNCTOR

: DESTRUCTOR: scan define-destructor ; parsing