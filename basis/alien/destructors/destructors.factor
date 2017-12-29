! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 ;
IN: alien.destructors

TUPLE: alien-destructor alien ;

INLINE-FUNCTOR: destructor ( f: existing-word -- ) [[
    USING: accessors alien.destructors effects generalizations
    destructors kernel literals sequences ;

    TUPLE: ${f}-destructor < alien-destructor ;

    : <${f}-destructor> ( alien -- destructor )
        ${f}-destructor boa ; inline

    : &${f} ( alien -- alien ) dup <${f}-destructor> &dispose drop ; inline

    : |${f} ( alien -- alien ) dup <${f}-destructor> |dispose drop ; inline

    M: ${f}-destructor dispose alien>> ${f} $[ \ ${f} stack-effect out>> length ] ndrop ;
]]
