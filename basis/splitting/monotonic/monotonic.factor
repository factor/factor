! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: make namespaces sequences kernel fry ;
IN: splitting.monotonic

: ,, ( obj -- ) building get peek push ;
: v, ( -- ) V{ } clone , ;
: ,v ( -- ) building get dup peek empty? [ dup pop* ] when drop ;

: (monotonic-split) ( seq quot -- newseq )
    [
        [ dup unclip suffix ] dip
        v, '[ over ,, @ [ v, ] unless ] 2each ,v
    ] { } make ; inline

: monotonic-split ( seq quot -- newseq )
    over empty? [ 2drop { } ] [ (monotonic-split) ] if ; inline
