USING: kernel models namespaces math sequences arrays hashtables
gadgets gadgets-text gadgets-buttons generic ;
IN: action-field

TUPLE: field model ;

C: field ( model -- field )
<editor> over set-delegate
[ set-field-model ] keep
dup dup set-control-self ;

: field-commit ( field -- string )
[ editor-text ] keep
[ field-model [ dupd set-model ] when* ] keep
select-all ;

field "Field commands" {
    { "Clear input" T{ key-down f { C+ } "k" } [ control-model clear-doc ] }
    { "Accept input" T{ key-down f f "RETURN" } [ field-commit drop ] }
} define-commands

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: action-field quot ;

C: action-field ( quot -- action-field )
tuck set-action-field-quot f <model> [ add-connection ] 2keep
<field> over set-gadget-delegate ;

M: action-field model-changed ( action-field -- ) dup action-field-quot call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: variable-field ( var -- action-field )
unit [ editor-text ] swap append [ set ] append <action-field> ;

: number-field ( var -- action-field )
unit [ editor-text string>number ] swap append [ set ] append <action-field> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! [bind] [unbind] and [bound?] should probably be in a separate
! file. But right now boids and automata are the only programs which
! use this, and I don't want to add a new contrib file just for
! this. For now they'll live here. Maybe bind-button and
! bind-action-field should go into a gadgets-utils file eventually.
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [bind] ( ns quot -- quot ) \ bind 3array >quotation ;

: [unbind] ( quot -- quot ) second ;

: [bound?] ( quot -- ? )
dup length 3 = [ dup first hashtable? swap third \ bind = and ] [ f ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bind-button ( ns button -- ) tuck button-quot [bind] swap set-button-quot ;

: bind-action-field ( ns action-field -- )
tuck action-field-quot [bind] swap set-action-field-quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PROVIDE: contrib/action-field ;