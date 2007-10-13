
USING: kernel math vectors sequences opengl.gl math.vectors
       math.matrices vars opengl self pos ori turtle lsys.tortoise

       lsys.strings.interpret ;

       ! lsys.strings

IN: lsys.tortoise.graphics

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (v0 - v1) x (v1 - v2)

: polygon-normal ( {_v0_v1_v2_} -- normal ) first3 dupd v- -rot v- swap cross ;

: (polygon) ( vertices -- )
GL_POLYGON glBegin
dup polygon-normal gl-normal [ gl-vertex ] each
glEnd ;

: polygon ( vertices -- ) dup length 3 >= [ (polygon) ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: vertices

! : init-vertices ( -- ) 0 <vector> >vertices ;

: start-polygon ( -- ) vertices> delete-all ;

: finish-polygon ( -- ) vertices> polygon ;

: polygon-vertex ( -- ) pos> vertices> push ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: record-vertex ( -- ) pos> gl-vertex ;

: draw-forward ( length -- )
GL_LINES glBegin record-vertex step-turtle record-vertex glEnd ;

: move-forward ( length -- ) step-turtle polygon-vertex ;

: sneak-forward ( length -- ) step-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scale-len ( m -- ) len> * >len ;

: scale-angle ( m -- ) angle> * >angle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-thickness ( i -- ) dup >thickness glLineWidth ;

: scale-thickness ( m -- ) thickness> * 0.5 max set-thickness ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: color-table

: init-color-table ( -- )
{ { 0    0    0 }    ! black
  { 0.5  0.5  0.5 }  ! grey
  { 1    0    0 }    ! red
  { 1    1    0 }    ! yellow
  { 0    1    0 }    ! green
  { 0.25 0.88 0.82 } ! turquoise
  { 0    0    1 }    ! blue
  { 0.63 0.13 0.94 } ! purple
  { 0.00 0.50 0.00 } ! dark green
  { 0.00 0.82 0.82 } ! dark turquoise
  { 0.00 0.00 0.50 } ! dark blue
  { 0.58 0.00 0.82 } ! dark purple
  { 0.50 0.00 0.00 } ! dark red
  { 0.25 0.25 0.25 } ! dark grey
  { 0.75 0.75 0.75 } ! medium grey
  { 1    1    1 }    ! white
} [ 1 add ] map >color-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: material-color ( color -- )
GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE rot gl-material ;

: set-color ( i -- )
dup >color color-table> nth dup gl-color material-color ;

: inc-color ( -- ) color> 1+ set-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: tortoise-stack

! : init-tortoise-stack ( -- ) V{ } clone >tortoise-stack ;

! : save-tortoise ( -- ) self> tortoise-stack> push ;

! : save-tortoise ( -- ) self> tortoise-stack> push   self> clone >self ;

: save-tortoise ( -- ) self> clone tortoise-stack> push ;

: restore-tortoise ( -- )
tortoise-stack> pop >self
color> set-color
thickness> set-thickness ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: default-values
VAR: model-values

: lparser-dialect ( -- )

[ 1 >len   45 >angle   1 >thickness   2 >color ] >default-values

H{ { "+" [ angle>     turn-left ] }
   { "-" [ angle>     turn-right ] }
   { "&" [ angle>     pitch-down ] }
   { "^" [ angle>     pitch-up ] }
   { "<" [ angle>     roll-left ] }
   { ">" [ angle>     roll-right ] }

   { "|" [ 180.0         rotate-y ] }
   { "%" [ 180.0         rotate-z ] }
   { "$" [ roll-until-horizontal ]  }

   { "F" [ len>     draw-forward ] }
   { "Z" [ len> 2 / draw-forward ] }
   { "f" [ len>     move-forward ] }
   { "z" [ len> 2 / move-forward ] }
   { "g" [ len>     sneak-forward ] }
   { "." [ polygon-vertex ] }

   { "[" [ save-tortoise ] }
   { "]" [ restore-tortoise ] }
   { "{" [ start-polygon ] }
   { "}" [ finish-polygon ] }

   { "/" [ 1.1 scale-len ] } ! double quote command in lparser
   { "'" [ 0.9 scale-len ] }
   { ";" [ 1.1 scale-angle ] }
   { ":" [ 0.9 scale-angle ] }
   { "?" [ 1.4 scale-thickness ] }
   { "!" [ 0.7 scale-thickness ] }

   { "c" [ color> 1 + color-table> length mod set-color ] }

} >command-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

