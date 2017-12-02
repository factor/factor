! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 ;
IN: alien.destructors

TUPLE: alien-destructor alien ;

SAME-FUNCTOR: destructor ( F: existing-word -- ) [[
USING: accessors alien.destructors effects generalizations
destructors kernel literals sequences ;

TUPLE: ${F}-destructor < alien-destructor ;

: <${F}-destructor> ( alien -- destructor )
    ${F}-destructor boa ; inline

: &${F} ( alien -- alien ) dup <${F}-destructor> &dispose drop ; inline

: |${F} ( alien -- alien ) dup <${F}-destructor> |dispose drop ; inline

M: ${F}-destructor dispose alien>> ${F} $[ \ ${F} stack-effect out>> length ] ndrop ;

]]
