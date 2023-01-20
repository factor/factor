! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.parser
classes fry functors growable kernel lexer make math parser
prettyprint.custom sequences specialized-arrays vocabs.generated
vocabs.loader vocabs.parser ;
FROM: sequences.private => nth-unsafe ;
FROM: specialized-arrays.private => nth-c-ptr direct-like ;
QUALIFIED: vectors.functor
IN: specialized-vectors

MIXIN: specialized-vector

<PRIVATE

<FUNCTOR: define-vector ( T -- )

V DEFINES-CLASS ${T}-vector

A          IS ${T}-array
<A>        IS <${A}>
<direct-A> IS <direct-${A}>

>V DEFERS >${V}
V{ DEFINES ${V}{

WHERE

V A <A> vectors.functor:define-vector

M: V contract 2drop ; inline

M: V element-size drop \ T heap-size ; inline

M: V pprint-delims drop \ V{ \ } ;

M: V >pprint-sequence ;

M: V pprint* pprint-object ;

M: V >c-ptr underlying>> underlying>> ; inline
M: V byte-length [ length ] [ element-size ] bi * ; inline

M: V direct-like drop <direct-A> ; inline
M: V nth-c-ptr underlying>> nth-c-ptr ; inline

M: A like
    drop dup A instance? [
        dup V instance? [
            [ >c-ptr ] [ length>> ] bi <direct-A>
        ] [ \ T >c-array ] if
    ] unless ; inline

SYNTAX: V{ \ } [ >V ] parse-literal ;

INSTANCE: V specialized-vector
INSTANCE: V growable

;FUNCTOR>

: specialized-vector-vocab ( c-type -- vocab )
    [
        "specialized-vectors.instances." %
        [ vocabulary>> % "." % ]
        [ name>> % ]
        bi
    ] "" make ;

PRIVATE>

: push-new ( vector -- new )
    [ length ] keep ensure nth-unsafe ; inline

: define-vector-vocab ( type -- vocab )
    underlying-type
    [ specialized-vector-vocab ] [ '[ _ define-vector ] ] bi
    generate-vocab ;

SYNTAX: SPECIALIZED-VECTORS:
    ";" [
        parse-c-type
        [ define-array-vocab use-vocab ]
        [ define-vector-vocab use-vocab ] bi
    ] each-token ;

SYNTAX: SPECIALIZED-VECTOR:
    scan-c-type
    [ define-array-vocab use-vocab ]
    [ define-vector-vocab use-vocab ] bi ;

{ "specialized-vectors" "mirrors" } "specialized-vectors.mirrors" require-when
