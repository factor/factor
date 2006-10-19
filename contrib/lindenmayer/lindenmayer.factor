! Eduardo Cavazos - wayo.cavazos@gmail.com

REQUIRES: contrib/math
          contrib/vars
          contrib/slate
          contrib/lindenmayer/opengl
          contrib/lindenmayer/turtle
          contrib/lindenmayer/camera
          contrib/lindenmayer/camera-slate ;

USING: kernel alien namespaces arrays vectors math opengl sequences threads
       hashtables strings gadgets
       math-contrib vars slate turtle turtle-camera camera-slate
       opengl-contrib ;

IN: lindenmayer 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: record-vertex ( -- ) position> gl-vertex ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: polygon-vertex

: draw-forward ( length -- )
GL_LINES glBegin record-vertex step-turtle record-vertex glEnd ;

: move-forward ( length -- ) step-turtle polygon-vertex ;

: sneak-forward ( length -- ) step-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (v0 - v1) x (v1 - v2)

: polygon-normal ( {_v0_v1_v2_} -- normal ) first3 dupd v- -rot v- swap cross ;

: (polygon) ( vertices -- )
GL_POLYGON glBegin dup polygon-normal gl-normal [ gl-vertex ] each glEnd ;

: polygon ( vertices -- ) dup length 3 >= [ (polygon) ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Maybe use an array instead of a vector

VAR: vertices

: start-polygon ( -- ) 0 <vector> >vertices ;

: finish-polygon ( -- ) vertices> polygon ;

: polygon-vertex ( -- ) position> vertices> push ;

: reset-vertices start-polygon ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lindenmayer string rewriting
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Maybe use an array instead of a quot in the work of segment

VAR: rules

: segment ( str -- seq )
{ { [ dup "" = ] [ drop [ ] ] }
  { [ dup length 1 = ] [ unit ] }
  { [ 1 over nth CHAR: ( = ]
    [ CHAR: ) over index 1 +		! str i
      2dup head				! str i head
      -rot tail				! head tail
      segment swap add* ] }
  { [ t ] [ dup 1 head swap 1 tail segment swap add* ] } }
cond ;

: lookup ( str -- str ) dup 1 head rules get hash dup [ nip ] [ drop ] if ;

: rewrite ( str -- str ) segment [ lookup ] map concat ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lindenmayer string interpretation
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: command-table

: segment-command ( seg -- command ) 1 head ;

: segment-parameter ( seg -- parameter )
dup length 1 - 2 swap rot subseq string>number ;

: segment-parts ( seg -- param command )
dup segment-parameter swap segment-command ;

: exec-command ( str -- ) command-table get hash dup [ call ] [ drop ] if ;

: exec-command-with-param ( param command -- )
command-table get hash dup [ peek unit call ] [ 2drop ] if ;

: (interpret) ( seg -- )
dup length 1 =
[ exec-command ] [ segment-parts exec-command-with-param ] if ;

: interpret ( str -- ) segment [ (interpret) ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lparser dialect
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: angle
VAR: len
VAR: thickness
VAR: color-index

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: set-thickness
DEFER: set-color-index

TUPLE: state position orientation angle len thickness color-index ;

VAR: states

: reset-state-stack ( -- ) V{ } clone >states ;

: save-state ( -- )
position> orientation> angle> len> thickness> color-index> <state>
states> push ;

: restore-state ( -- )
states> pop
dup state-position    >position
dup state-orientation >orientation
dup state-len         >len
dup state-angle       >angle
dup state-color-index set-color-index
dup state-thickness   set-thickness
drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scale-len ( m -- ) len> * >len ;

: scale-angle ( m -- ) angle> * >angle ;

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
} [ 1 set-color-alpha ] map color-table set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: material-color ( color -- )
GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE rot gl-material-fv ;

: set-color-index ( i -- )
dup >color-index color-table> nth dup gl-color material-color ;

: inc-color-index ( -- ) color-index> 1 + set-color-index ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-thickness ( i -- ) dup >thickness glLineWidth ;

: scale-thickness ( m -- ) thickness> * 0.5 max set-thickness ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: default-values
VAR: model-values

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lparser-dialect ( -- )

[ 1 >len   45 >angle   1 >thickness   2 >color-index ] >default-values

H{ { "+" [ angle get     turn-left ] }
   { "-" [ angle get     turn-right ] }
   { "&" [ angle get     pitch-down ] }
   { "^" [ angle get     pitch-up ] }
   { "<" [ angle get     roll-left ] }
   { ">" [ angle get     roll-right ] }

   { "|" [ 180.0         rotate-y ] }
   { "%" [ 180.0         rotate-z ] }
   { "$" [ roll-until-horizontal ]  }

   { "F" [ len get     draw-forward ] }
   { "Z" [ len get 2 / draw-forward ] }
   { "f" [ len get     move-forward ] }
   { "z" [ len get 2 / move-forward ] }
   { "g" [ len get     sneak-forward ] }
   { "." [ polygon-vertex ] }

   { "[" [ save-state ] }
   { "]" [ restore-state ] }
   { "{" [ start-polygon ] }
   { "}" [ finish-polygon ] }

   { "/" [ 1.1 scale-len ] } ! double quote command in lparser
   { "'" [ 0.9 scale-len ] }
   { ";" [ 1.1 scale-angle ] }
   { ":" [ 0.9 scale-angle ] }
   { "?" [ 1.4 scale-thickness ] }
   { "!" [ 0.7 scale-thickness ] }

   { "c" [ color-index> 1 + color-table get length mod set-color-index ] }

} command-table set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: axiom
VAR: result

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate ( -- ) result> rewrite >result ;

: iterations ( n -- ) [ iterate ] times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: model

: init-model ( -- ) 1 glGenLists >model ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display ( -- )

black gl-clear-color

GL_FLAT glShadeModel

GL_PROJECTION glMatrixMode
glLoadIdentity
-1 1 -1 1 1.5 200 glFrustum

GL_MODELVIEW glMatrixMode

glLoadIdentity

[ do-look-at ] camera> with-turtle

GL_COLOR_BUFFER_BIT glClear

GL_FRONT_AND_BACK GL_LINE glPolygonMode

white gl-color
GL_LINES glBegin { 0 0 0 } gl-vertex { 0 0 1 } gl-vertex glEnd

color-index> set-color-index

model> glCallList ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-turtle ( -- ) <turtle> >turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-camera ( -- ) <turtle> >camera ;

: reset-camera ( -- ) [
reset-turtle
45 turn-left
45 pitch-up
5 step-turtle
180 turn-left
] camera> with-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( -- )
<camera-slate> >slate
namespace slate> set-slate-ns
slate> "L-system" open-titled-window
[ display ] >action ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
init-turtle
init-turtle-stack
init-camera reset-camera
init-model

2 >color-index
init-color-table

init-slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: result>model ( -- )
[ model> GL_COMPILE glNewList result> interpret glEndList ] >action .slate ;

: build-model ( -- )
reset-state-stack
reset-vertices
reset-turtle
default-values> call
model-values> call
result>model
3000 sleep
[ display ] >action .slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Examples
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: koch ( -- ) lparser-dialect   [ 90 >angle ] >model-values

H{ { "K" "[[a|b] '(0.41)f'(2.439) |<(60) [a|b]]" }
   { "k" "[ c'(0.5) K]" }
   { "a" "[d <(120) d <(120) d ]" }
   { "b" "e" }
   { "e" "[^ '(.2887)f'(3.4758) &(180)      +z{.-(120)f-(120)f}]" }
   { "d" "[^ '(.2887)f'(3.4758) &(109.5111) +zk{.-(120)f-(120)f}]" }
} >rules

"K" >result ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: spiral-0 ( -- ) lparser-dialect   [ 10 >angle 5 >thickness ] >model-values

"[P]|[P]" >result

H{ { "P" "[A]>>>>>>>>>[cB]>>>>>>>>>[ccC]>>>>>>>>>[cccD]" }
   { "A" "F+;'A" }
   { "B" "F!+F+;'B" }
   { "C" "F!^+F^+;'C" }
   { "D" "F!>^+F>^+;'D" }
} >rules ;

: spiral-0-scene ( -- )
spiral-0
22 iterations
build-model
[ reset-turtle 90 turn-left 16 step-turtle 180 turn-left ]
camera> with-turtle .slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tree-5 ( -- ) lparser-dialect   [ 5 >angle   1 >thickness ] >model-values

"c(4)FFS" >result

H{ { "S" "FFR>(60)R>(60)R>(60)R>(60)R>(60)R>(30)S" }
   { "R" "[Ba]" }
   { "a" "$tF[Cx]Fb" }
   { "b" "$tF[Dy]Fa" }
   { "B" "&B" }
   { "C" "+C" }
   { "D" "-D" }

   { "x" "a" }
   { "y" "b" }

   { "F" "'(1.25)F'(.8)" }
} >rules ;

: tree-5-scene ( -- )
tree-5
9 iterations
build-model
[ reset-turtle 90 pitch-down -70 step-turtle 50 strafe-up ] camera> with-turtle
.slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-1 ( -- ) lparser-dialect   [ 45 >angle   5 >thickness ] >model-values

H{ { "A" "F[&'(.8)!BL]>(137)'!(.9)A" }
   { "B" "F[-'(.8)!(.9)$CL]'!(.9)C" }
   { "C" "F[+'(.8)!(.9)$BL]'!(.9)B" }

   { "L" "~c(8){+(30)f-(120)f-(120)f}" }
} >rules

"c(12)FFAL" >result ;

: abop-1-scene ( -- )
abop-1
8 iterations
build-model
[ reset-turtle
  90 pitch-up 7 step-turtle 90 pitch-down 4 step-turtle 90 pitch-down ]
camera> with-turtle .slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-2 ( -- ) lparser-dialect   [ 30 >angle   5 >thickness ] >model-values

H{ { "A" "F[&'(.7)!BL]>(137)[&'(.6)!BL]>(137)'(.9)!(.9)A" }
   { "B" "F[-'(.7)!(.9)$CL]'(.9)!(.9)C" }
   { "C" "F[+'(.7)!(.9)$BL]'(.9)!(.9)B" }

   { "L" "~c(8){+(45)f(.1)-(45)f(.1)-(45)f(.1)+(45)|+(45)f(.1)-(45)f(.1)-(45)f(.1)}" }

} >rules

"c(12)FAL" >result ;

: abop-2-scene ( -- )
abop-2
7 iterations
build-model
[ reset-turtle { 0 4 4 } >position 90 pitch-down ]
camera> with-turtle .slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-3 ( -- ) lparser-dialect   [ 30 >angle   5 >thickness ] >model-values

H{ { "A" "!(.9)t(.4)FB>(94)B>(132)B" }
   { "B" "[&t(.4)F$A]" }
   { "F" "'(1.25)F'(.8)" }
} >rules

"c(12)FA" >result ;

: abop-3-scene ( -- )
abop-3 11 iterations build-model
[ reset-turtle { 0 47 29 } >position 90 pitch-down ] camera> with-turtle
.slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-4 ( -- ) lparser-dialect   [ 18 >angle   5 >thickness ] >model-values

H{ { "N" "FII[&(60)rY]>(90)[&(45)'(0.8)rA]>(90)[&(60)rY]>(90)[&(45)'(0.8)rD]!FIK" }
   { "Y" "[c(4){++l.--l.--l.++|++l.--l.--l.}]" }
   { "l" "g(.2)l" }
   { "K" "[!c(2)FF>w>(72)w>(72)w>(72)w>(72)w]" }
   { "w" "[c(2)^!F][c(5)&(72){-(54)f(3)+(54)f(3)|-(54)f(3)+(54)f(3)}]" }
   { "f" "_" }

   { "A" "B" }
   { "B" "C" }
   { "C" "D" }
   { "D" "E" }
   { "E" "G" }
   { "G" "H" }
   { "H" "N" }

   { "I" "FoO" }
   { "O" "FoP" }
   { "P" "FoQ" }
   { "Q" "FoR" }
   { "R" "FoS" }
   { "S" "FoT" }
   { "T" "FoU" }
   { "U" "FoV" }
   { "V" "FoW" }
   { "W" "FoX" }
   { "X" "_" }

   { "o" "$t(-0.03)" }
   { "r" "~(30)" }
} >rules

"c(12)&(20)N" >result ;

: abop-4-scene ( -- )
abop-4 21 iterations build-model
[ reset-turtle
  { 53 25 36 } >position
  { { 0.57 -0.14 -0.80 } { -0.81 -0.18 -0.54 } { -0.07 0.97 -0.22 } }
  >orientation
] camera> with-turtle .slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-5 ( -- ) lparser-dialect   [ 5 >angle   5 >thickness ] >model-values

H{ { "a" "F[+(45)l][-(45)l]^;ca" }

   { "l" "j" }
   { "j" "h" }
   { "h" "s" }
   { "s" "d" }
   { "d" "x" }
   { "x" "a" }

   { "F" "'(1.17)F'(.855)" }
} >rules

"&(90)+(90)a" >result ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-6 ( -- ) lparser-dialect   [ 5 >angle   5 >thickness ] >model-values

"&(90)+(90)FFF[-(120)'(.6)x][-(60)'(.8)x][+(120)'(.6)x][+(60)'(.8)x]x" >result

H{ { "a" "F[cdx][cex]F!(.9)a" }
   { "x" "a" }

   { "d" "+d" }
   { "e" "-e" }

   { "F" "'(1.25)F'(.8)" }
} >rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: airhorse ( -- ) lparser-dialect [ 10 >angle 5 >thickness ] >model-values

"C" >result

H{ { "C" "LBW" }

   { "B" "[[''aH]|[g]]" }
   { "a" "Fs+;'a" }
   { "g" "Ft+;'g" }
   { "s" "[::cc!!!!&&[FFcccZ]^^^^FFcccZ]" }
   { "t" "[c!!!!&[FF]^^FF]" }

   { "L" "O" }
   { "O" "P" }
   { "P" "Q" }
   { "Q" "R" }
   { "R" "U" }
   { "U" "X" }
   { "X" "Y" }
   { "Y" "V" }
   { "V" "[cc!!!&(90)[Zp]|[Zp]]" }
   { "p" "h>(120)h>(120)h" }
   { "h" "[+(40)!F'''p]" }

   { "H" "[cccci[>(50)dcFFF][<(50)ecFFF]]" }
   { "d" "Z!&Z!&:'d" }
   { "e" "Z!^Z!^:'e" }
   { "i" "-:/i" }

   { "W" "[%[!!cb][<<<!!cb][>>>!!cb]]" }
   { "b" "Fl!+Fl+;'b" }
   { "l" "[-cc{--z++z++z--|--z++z++z}]" }
} >rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! These should be moved into a separate file. They are used to pretty
! print matricies and vectors.

USING: styles prettyprint io ;

: decimal-places ( n d -- n )
10 swap ^ tuck * >fixnum swap /f ;

! : .mat ( matrix -- ) [ [ 2 decimal-places ] map ] map . ;

: .mat ( matrix -- )
H{ { table-gap 4 } { table-border 4 } }
[ 2 decimal-places pprint ]
tabular-output ;

: .vec ( vector -- ) [ 2 decimal-places ] map . ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PROVIDE: lindenmayer ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!