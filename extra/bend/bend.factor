! Copyright (C) 2024 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra classes.tuple
hashtables kernel parser quotations sequences stack-checker
vocabs.parser words ;
IN: bend

: fold ( ... obj branches -- ... value )
    [
        [ dup callable? [ first dupd instance? ] unless ] find nip first2 pick
    ] keep '[
        [ tuple-class? [ tuple-slots ] [ drop f ] if ] [ nip all-slots ] 2bi
        [ class>> _ class-of swap [ class<= ] [ object = not ] bi and
        [ _ fold ] when ] [ ] 2map-as
    ] dip compose call( ... -- ... value ) ; inline recursive

SYNTAX: BEND[
    gensym dup
    dup "fork" associate [ parse-quotation ] with-words
    dup infer define-declared suffix! ;
