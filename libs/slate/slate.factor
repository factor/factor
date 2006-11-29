REQUIRES: libs/vars ;
USING: kernel namespaces gadgets vars ;
IN: slate

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: slate action ns ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C: slate ( -- slate )
dup delegate>gadget
[ ] over set-slate-action
H{ } clone over set-slate-ns ;

M: slate pref-dim* ( slate -- ) drop { 100 100 0 } ;

M: slate draw-gadget* ( slate -- ) dup slate-ns swap slate-action bind ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

: action> ( -- quot ) slate> slate-action ;

: >action ( quot -- ) slate> set-slate-action ;

: .slate ( -- ) slate> relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: slate-window ( -- ) <slate> dup >slate "Slate" open-titled-window ;
