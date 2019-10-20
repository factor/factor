! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.parser arrays functors2 growable kernel lexer make
math.parser sequences vocabs.loader ;
FROM: sequences.private => nth-unsafe ;
QUALIFIED: vectors.functor
IN: specialized-vectors

MIXIN: specialized-vector

FUNCTOR: specialized-vector ( type: existing-word -- ) [[

USING: accessors alien alien.c-types alien.data classes growable
kernel math parser prettyprint.custom sequences
sequences.private specialized-arrays specialized-arrays.private
specialized-vectors vectors.functor ;
FROM: specialized-arrays.private => nth-c-ptr direct-like ;

<<
SPECIALIZED-ARRAY: ${type}
>>

<<
! For >foo-vector to be defined in time
VECTORIZED: ${type} ${type}-array <${type}-array>
>>

SYNTAX: ${type}-vector{ \ \} [ >${type}-vector ] parse-literal ;

INSTANCE: ${type}-vector specialized-vector

M: ${type}-vector contract 2drop ; inline

M: ${type}-vector element-size drop \ ${type} heap-size ; inline

M: ${type}-vector pprint-delims drop \ \${type}-vector{ \ \} ;

M: ${type}-vector >pprint-sequence ;

M: ${type}-vector pprint* pprint-object ;

M: ${type}-vector >c-ptr underlying>> underlying>> ; inline
M: ${type}-vector byte-length [ length ] [ element-size ] bi * ; inline

M: ${type}-vector direct-like drop <direct-${type}-array> ; inline
M: ${type}-vector nth-c-ptr underlying>> nth-c-ptr ; inline

M: ${type}-array like
    drop dup ${type}-array instance? [
        dup ${type}-vector instance? [
            [ >c-ptr ] [ length>> ] bi <direct-${type}-array>
        ] [ \ ${type} >c-array ] if
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
