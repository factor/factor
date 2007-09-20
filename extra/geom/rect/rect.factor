
USING: kernel namespaces arrays sequences math.vectors
       mortar slot-accessors geom.pos geom.dim ;

IN: geom.rect

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: math

: v+y ( pos y -- pos ) 0 swap 2array v+ ;

: v-y ( pos y -- pos ) 0 swap 2array v- ;

: v+x ( pos x -- pos ) 0 2array v+ ;

: v-x ( pos x -- pos ) 0 2array v- ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: <rect>

<rect>
  <pos> class-slots <dim> class-slots append
  <pos> class-methods <dim> class-methods append { H{ } } append
  { H{ } }
4array <rect> set-global

! { 0 0 } { 0 0 } <rect> new

<rect> {

"top-left" !( rect -- point ) [ $pos ]

"top-right" !( rect -- point ) [ dup $pos swap <- width 1- v+x ]

"bottom-left" !( rect -- point ) [ dup $pos swap <- height 1- v+y ]

"bottom-right" !( rect -- point ) [ dup $pos swap $dim { 1 1 } v- v+ ]

} add-methods