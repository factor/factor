! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser arrays functors2 growable kernel lexer make
math.parser sequences vocabs.loader ;
FROM: sequences.private => nth-unsafe ;
QUALIFIED: vectors.functor
IN: specialized-vectors

MIXIN: specialized-vector

FUNCTOR: specialized-vector ( T: existing-word -- ) [[

USING: accessors alien alien.c-types alien.data classes growable
kernel math parser prettyprint.custom sequences
sequences.private specialized-arrays specialized-arrays.private
specialized-vectors vectors.functor ;
FROM: specialized-arrays.private => nth-c-ptr direct-like ;

SPECIALIZED-ARRAY: ${T}

<<
! For >foo-vector to be defined in time
SPECIAL-VECTOR: ${T}
>>

SYNTAX: ${T}-vector{ \ } [ >${T}-vector ] parse-literal ;

INSTANCE: ${T}-vector specialized-vector
INSTANCE: ${T}-vector growable

M: ${T}-vector contract 2drop ; inline

M: ${T}-vector element-size drop \ ${T} heap-size ; inline

M: ${T}-vector pprint-delims drop \ ${T}-vector{ \ } ;

M: ${T}-vector >pprint-sequence ;

M: ${T}-vector pprint* pprint-object ;

M: ${T}-vector >c-ptr underlying>> underlying>> ; inline
M: ${T}-vector byte-length [ length ] [ element-size ] bi * ; inline

M: ${T}-vector direct-like drop <direct-${T}-array> ; inline
M: ${T}-vector nth-c-ptr underlying>> nth-c-ptr ; inline

M: ${T}-array like
    drop dup ${T}-array instance? [
        dup ${T}-vector instance? [
            [ >c-ptr ] [ length>> ] bi <direct-${T}-array>
        ] [ \ ${T} >c-array ] if
    ] unless ; inline

]]

<PRIVATE

: specialized-vector-vocab ( c-type -- vocab )
    [
        "specialized-vectors:functors:specialized-vector:" %
        ! [ vocabulary>> % "." % ]
        ! [ name>> % ":" % ]
        [ drop ]
        [ 1array hashcode number>string % ] bi
    ] "" make ;

PRIVATE>

: push-new ( vector -- new )
    [ length ] keep ensure nth-unsafe ; inline

SYNTAX: \SPECIALIZED-VECTORS:
    ";" [ parse-c-type define-specialized-vector ] each-token ;

{ "specialized-vectors" "mirrors" } "specialized-vectors.mirrors" require-when
