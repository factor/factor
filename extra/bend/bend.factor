! Copyright (C) 2024 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes classes.algebra classes.tuple
combinators effects.parser kernel namespaces quotations
sequences sequences.deep splitting ;
IN: bend

<PRIVATE

: deep-map-postorder ( ... obj quot: ( ... elt -- ... elt' ) -- ... newobj )
    over branch? [ [ [ deep-map-postorder ] curry map ] keep ] when call ; inline recursive

PRIVATE>

: fold ( ... obj branches -- ... value )
    [
        [ dup callable? [ first dupd instance? ] unless ] find nip first2 pick
    ] keep '[
        [ tuple-class? [ tuple-slots ] [ drop f ] if ] [ nip all-slots ] 2bi
        [ class>> _ class-of swap [ class<= ] [ object = not ] bi and
        [ _ fold ] when ] [ ] 2map-as
    ] dip compose call( ... -- ... value ) ; inline recursive

SYMBOL: fork

: bend ( quot effect -- )
    [
        dupd \ bend 3array '[ dup sequence? [ { fork } _ replace ] when ] deep-map-postorder
    ] keep call-effect ; inline

SYNTAX: bend( \ bend parse-call-paren ;