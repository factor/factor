! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors destructors accessors kernel parser words
combinators.smart ;
IN: alien.destructors

SLOT: alien

FUNCTOR: define-destructor ( F -- )

F-destructor DEFINES-CLASS ${F}-destructor
<F-destructor> DEFINES <${F}-destructor>
&F DEFINES &${F}
|F DEFINES |${F}

WHERE

TUPLE: F-destructor alien disposed ;

: <F-destructor> ( alien -- destructor ) f F-destructor boa ; inline

M: F-destructor dispose* [ alien>> F ] drop-outputs ;

: &F ( alien -- alien ) dup <F-destructor> &dispose drop ; inline

: |F ( alien -- alien ) dup <F-destructor> |dispose drop ; inline

;FUNCTOR

SYNTAX: DESTRUCTOR: scan-word define-destructor ;