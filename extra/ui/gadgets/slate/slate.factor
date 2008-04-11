
USING: kernel namespaces opengl ui.render ui.gadgets ;

IN: ui.gadgets.slate

TUPLE: slate action dim graft ungraft
       button-down
       button-up
       key-down
       key-up ;

: <slate> ( action -- slate )
  slate construct-gadget
  tuck set-slate-action
  { 100 100 } over set-slate-dim
  [ ] over set-slate-graft
  [ ] over set-slate-ungraft ;

M: slate pref-dim* ( slate -- dim ) slate-dim ;

M: slate draw-gadget* ( slate -- )
   origin get swap slate-action with-translation ;

M: slate graft* ( slate -- ) slate-graft call ;

M: slate ungraft* ( slate -- ) slate-ungraft call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: key-pressed-value

: key-pressed? ( -- ? ) key-pressed-value get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: mouse-pressed-value

: mouse-pressed? ( -- ? ) mouse-pressed-value get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: key-value

: key ( -- key ) key-value get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: button-value

: button ( -- val ) button-value get ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: combinators ui.gestures accessors ;

! M: slate handle-gesture* ( gadget gesture delegate -- ? )
!    drop nip
!    {
!      {
!        [ dup key-down? ]
!        [
       
!          key-down-sym key-value set
!          key-pressed-value on
!          t
!        ]
!      }
!      { [ dup key-up?   ] [ drop key-pressed-value off t ] }
!      {
!        [ dup button-down? ]
!        [
!          button-down-# mouse-button-value set
!          mouse-pressed-value on
!          t
!        ]
!      }
!      { [ dup button-up? ] [ drop mouse-pressed-value off t ] }
!      { [ t             ] [ drop                       t ] }
!    }
!    cond ;

M: slate handle-gesture* ( gadget gesture delegate -- ? )
   rot drop swap         ! delegate gesture
   {
     {
       [ dup key-down? ]
       [
         key-down-sym key-value set
         key-pressed-value on
         key-down>> dup [ call ] [ drop ] if
         t
       ]
     }
     {
       [ dup key-up?   ]
       [
         key-pressed-value off
         drop
         key-up>> dup [ call ] [ drop ] if
         t
       ] }
     {
       [ dup button-down? ]
       [
         button-down-# button-value set
         mouse-pressed-value on
         button-down>> dup [ call ] [ drop ] if
         t
       ]
     }
     {
       [ dup button-up? ]
       [
         mouse-pressed-value off
         drop
         button-up>> dup [ call ] [ drop ] if
         t
       ]
     }
     { [ t ] [ 2drop t ] }
   }
   cond ;