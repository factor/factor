! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets kernel math
namespaces vectors sequences math.vectors math.geometry.rect ;
IN: ui.gadgets.borders

TUPLE: border < gadget
{ size initial: { 0 0 } }
{ fill initial: { 0 0 } }
{ align initial: { 1/2 1/2 } } ;

: new-border ( child class -- border )
    new-gadget swap add-gadget ; inline

: <border> ( child gap -- border )
    swap border new-border
        swap dup 2array >>size ;

: <filled-border> ( child gap -- border )
    <border> { 1 1 } >>fill ;

M: border pref-dim*
    [ size>> 2 v*n ] keep
    gadget-child pref-dim v+ ;

: border-major-dim ( border -- dim )
    [ dim>> ] [ size>> 2 v*n ] bi v- ;

: border-minor-dim ( border -- dim )
    gadget-child pref-dim ;

: scale ( a b s -- c )
    tuck { 1 1 } swap v- [ v* ] 2bi@ v+ ;

: border-dim ( border -- dim )
    [ border-major-dim ] [ border-minor-dim ] [ fill>> ] tri scale ;

: border-loc ( border dim -- loc )
    [ [ size>> ] [ align>> ] [ border-major-dim ] tri ] dip
    v- v* v+ [ >fixnum ] map ;

: border-child-rect ( border -- rect )
    dup border-dim [ border-loc ] keep <rect> ;

M: border layout*
    dup border-child-rect swap gadget-child
    over loc>> >>loc
    swap dim>> >>dim
    drop ;

M: border focusable-child*
    gadget-child ;
