
USING: kernel namespaces threads math math.vectors quotations sequences
       opengl
       opengl.gl
       colors
       ui
       ui.gestures
       ui.gadgets
       ui.gadgets.packs
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.lib
       ui.gadgets.slate
       ui.gadgets.theme
       vars rewrite-closures
       self pos ori turtle opengl.camera
       lsys.tortoise lsys.tortoise.graphics
       lsys.strings.rewrite lsys.strings.interpret ;

       ! lsys.strings
       ! lsys.strings.rewrite
       ! lsys.strings.interpret

IN: lsys.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: camera

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: model

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display ( -- )

black gl-clear

GL_FLAT glShadeModel

GL_PROJECTION glMatrixMode
glLoadIdentity
-1 1 -1 1 1.5 200 glFrustum

GL_MODELVIEW glMatrixMode

glLoadIdentity

camera> do-look-at

GL_FRONT_AND_BACK GL_LINE glPolygonMode

white gl-color

GL_LINES glBegin { 0 0 0 } gl-vertex { 0 0 1 } gl-vertex glEnd

color> set-color

model> glCallList ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: result>model ( -- )
slate> find-gl-context
model> GL_COMPILE glNewList result> interpret glEndList ;

: build-model ( -- )
tortoise-stack> delete-all
vertices> delete-all
reset-turtle
default-values> call
model-values> call
result>model
[ display ] closed-quot slate> set-slate-action
slate> relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: hashtables namespaces.lib ui.gadgets.handler ;

: camera-action ( quot -- quot )
[ drop [ ] camera> with-self slate> relayout-1 ] make* closed-quot ;

VAR: frame
VAR: handler

DEFER: model-chooser
DEFER: scene-chooser
DEFER: empty-model

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lsys-controller ( -- )

{

[ "Load" <label> dup reverse-video-theme ]

[ "Models" <label> [ drop model-chooser ] closed-quot <bevel-button> ]
[ "Scenes" <label> [ drop scene-chooser ] closed-quot <bevel-button> ]

[ "Model" <label> dup reverse-video-theme ]

[ "Iterate" <label> [ drop iterate build-model ] closed-quot <bevel-button> ]
[ "Build model" <label> [ drop build-model ] closed-quot <bevel-button> ]

[ "Camera" <label> dup reverse-video-theme ]

[ "Turn left" <label> [ 5 turn-left ] camera-action <bevel-button> ]
[ "Turn right" <label> [ 5 turn-right ] camera-action <bevel-button> ]
[ "Pitch down" <label> [ 5 pitch-down ] camera-action <bevel-button> ]
[ "Pitch up" <label> [ 5 pitch-up ] camera-action <bevel-button> ]

[ "Forward - a"  <label> [  1 step-turtle ] camera-action <bevel-button> ]
[ "Backward - z" <label> [ -1 step-turtle ] camera-action <bevel-button> ]

[ "Roll left - q" <label> [ 5 roll-left ] camera-action <bevel-button> ]
[ "Roll right - w" <label> [ 5 roll-right ] camera-action <bevel-button> ]

[ "Strafe left - (alt)" <label> [ 1 strafe-left ] camera-action <bevel-button> ]
[ "Strafe right - (alt)" <label> [ 1 strafe-right ] camera-action <bevel-button> ]
[ "Strafe down - (alt)" <label> [ 1 strafe-up ] camera-action <bevel-button> ]
[ "Strafe up - (alt)" <label> [ 1 strafe-down ] camera-action <bevel-button> ]

[ "View 1 - 1" <label>
  [ pos> norm reset-turtle 90 turn-left step-turtle 180 turn-left ]
  camera-action <bevel-button> ]

[ "View 2 - 2" <label>
  [ pos> norm reset-turtle 90 pitch-up step-turtle 180 pitch-down ]
  camera-action <bevel-button> ]

[ "View 3 - 3" <label>
  [ pos> norm reset-turtle step-turtle 180 turn-left ]
  camera-action <bevel-button> ]

[ "View 4 - 4" <label>
  [ pos> norm reset-turtle 45 turn-left 45 pitch-up step-turtle 180 turn-left ]
  camera-action <bevel-button> ]

} make*
[ [ gadget, ] curry ] map concat ! Hack
make-pile 1 over set-pack-fill "L-system control" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lsys-viewer ( -- )

[ ] <slate> >slate
{ 400 400 } clone slate> set-slate-dim

{

{ T{ key-down f f "LEFT" }  [ [ 5 turn-left ] camera-action ] }
{ T{ key-down f f "RIGHT" } [ [ 5 turn-right ] camera-action ] }
{ T{ key-down f f "UP" }    [ [ 5 pitch-down ] camera-action ] }
{ T{ key-down f f "DOWN" }  [ [ 5 pitch-up ] camera-action ] }

{ T{ key-down f f "a" } [ [ 1 step-turtle ] camera-action ] }
{ T{ key-down f f "z" } [ [ -1 step-turtle ] camera-action ] }

{ T{ key-down f f "q" } [ [ 5 roll-left ] camera-action ] }
{ T{ key-down f f "w" } [ [ 5 roll-right ] camera-action ] }

{ T{ key-down f { A+ } "LEFT" }  [ [ 1 strafe-left ] camera-action ] }
{ T{ key-down f { A+ } "RIGHT" } [ [ 1 strafe-right ] camera-action ] }
{ T{ key-down f { A+ } "UP" }    [ [ 1 strafe-up ] camera-action ] }
{ T{ key-down f { A+ } "DOWN" }  [ [ 1 strafe-down ] camera-action ] }

{ T{ key-down f f "1" }
  [ [ pos> norm reset-turtle 90 turn-left step-turtle 180 turn-left ]
    camera-action ] }

{ T{ key-down f f "2" }
  [ [ pos> norm reset-turtle 90 pitch-up step-turtle 180 pitch-down ]
    camera-action ] }

{ T{ key-down f f "3" }
[ [ pos> norm reset-turtle step-turtle 180 turn-left ]
    camera-action ] }

{ T{ key-down f f "4" }
[ [ pos> norm reset-turtle 45 turn-left 45 pitch-up step-turtle 180 turn-left ]
    camera-action ] }

! } [ make* ] map alist>hash <handler> >handler

} [ make* ] map >hashtable <handler> >handler

slate> handler> set-gadget-delegate

handler> "L-system view" open-window

slate> find-gl-context
1 glGenLists >model

<turtle> >camera

[ camera> >self
  reset-turtle 45 turn-left 45 pitch-up 5 step-turtle 180 turn-left
] with-scope

init-color-table

<tortoise> >self

V{ } clone >tortoise-stack

V{ } clone >vertices

empty-model

build-model

;

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
camera> with-self slate> relayout-1 ;

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
[ reset-turtle 90 pitch-down -70 step-turtle 50 strafe-up ] camera> with-self
slate> relayout-1 ;

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
camera> with-self slate> relayout-1 ;

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
[ reset-turtle { 0 4 4 } >pos 90 pitch-down ]
camera> with-self slate> relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-3 ( -- ) lparser-dialect   [ 30 >angle   5 >thickness ] >model-values

H{ { "A" "!(.9)t(.4)FB>(94)B>(132)B" }
   { "B" "[&t(.4)F$A]" }
   { "F" "'(1.25)F'(.8)" }
} >rules

"c(12)FA" >result ;

: abop-3-scene ( -- )
abop-3 11 iterations build-model
[ reset-turtle { 0 47 29 } >pos 90 pitch-down ] camera> with-self
slate> relayout-1 ;

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
  { 53 25 36 } >pos
  { { 0.57 -0.14 -0.80 } { -0.81 -0.18 -0.54 } { -0.07 0.97 -0.22 } }
  >ori
] camera> with-self slate> relayout-1 ;

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

: empty-model ( -- )
lparser-dialect
[ ] >model-values
" " >result
H{ } >rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: model-chooser ( -- )

{
[ "abop-1" <label> [ drop abop-1 build-model ] closed-quot <bevel-button> ]
[ "abop-2" <label> [ drop abop-2 build-model ] closed-quot <bevel-button> ]
[ "abop-3" <label> [ drop abop-3 build-model ] closed-quot <bevel-button> ]
[ "abop-4" <label> [ drop abop-4 build-model ] closed-quot <bevel-button> ]
[ "abop-5" <label> [ drop abop-5 build-model ] closed-quot <bevel-button> ]
[ "abop-6" <label> [ drop abop-6 build-model ] closed-quot <bevel-button> ]
[ "tree-5" <label> [ drop tree-5 build-model ] closed-quot <bevel-button> ]
[ "airhorse" <label> [ drop airhorse build-model ] closed-quot <bevel-button> ]
[ "spiral-0" <label> [ drop spiral-0 build-model ] closed-quot <bevel-button> ]
[ "koch" <label> [ drop koch build-model ] closed-quot <bevel-button> ]
} make*
[ [ gadget, ] curry ] map concat ! Hack
make-pile 1 over set-pack-fill "L-system models" open-window ;

: scene-chooser ( -- )
{
[ "abop-1" <label> [ drop abop-1-scene ] closed-quot <bevel-button> ]
[ "abop-2" <label> [ drop abop-2-scene ] closed-quot <bevel-button> ]
[ "tree-5" <label> [ drop tree-5-scene ] closed-quot <bevel-button> ]
} make*
[ [ gadget, ] curry ] map concat ! Hack
make-pile 1 over set-pack-fill "L-system scenes" open-window ;

: lsys-window* ( -- )
[ lsys-controller lsys-viewer ] with-ui ;

MAIN: lsys-window*