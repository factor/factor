! Eduardo Cavazos - wayo.cavazos@gmail.com

REQUIRES: math ;

USING: kernel alien namespaces arrays vectors math opengl math-contrib
       parser sequences hashtables strings ;

IN: lindenmayer 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-matrix >r { } make r> group ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: RU ( angle -- RU ) deg>rad
[ dup cos ,	dup sin ,	0 ,
  dup sin neg ,	dup cos ,	0 ,
  0 ,		0 ,		1 , ] 3 make-matrix nip ;

: RL ( angle -- RL ) deg>rad
[ dup cos ,	0 ,		dup sin neg ,
  0 ,		1 ,		0 ,
  dup sin ,	0 ,		dup cos , ] 3 make-matrix nip ;

: RH ( angle -- RH ) deg>rad
[ 1 ,		0 ,		0 ,
  0 ,		dup cos ,	dup sin neg ,
  0 ,		dup sin ,	dup cos , ] 3 make-matrix nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: position
SYMBOL: orientation

: rotate-U ( angle -- ) RU orientation get swap m. orientation set ;
: rotate-L ( angle -- ) RL orientation get swap m. orientation set ;
: rotate-H ( angle -- ) RH orientation get swap m. orientation set ;

: step ( length -- )
>r position get orientation get 0 0 r> 3array m.v v+ position set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: record-vertex ( -- ) position get first3 glVertex3f ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rotate-z     rotate-U ;
: rotate-y neg rotate-L ;
: rotate-x neg rotate-H ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reset ( -- ) { 0 0 0 } position set 3 identity-matrix orientation set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: sequences : length* length ; USE: lindenmayer

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: polygon-vertex

: draw-forward ( length -- )
GL_LINES glBegin record-vertex step record-vertex glEnd ;

: move-forward ( length -- ) step polygon-vertex ;

: sneak-forward ( length -- ) step ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! (v0 - v1) x (v1 - v2)

: polygon-normal ( { v0 v1 v2 } -- normal )
0 over nth over 1 swap nth v- swap
1 over nth swap 2 swap nth v- cross ;

! Test and replace with:
! 
! : v0-v1 ( { v0 v1 v2 } -- vec ) first2 v- ;
! 
! : v1-v2 ( { v0 v1 v2 } -- vec ) first3 v- nip ;
! 
! : polygon-normal ( { v0 v1 v2 } -- normal ) dup v0-v1 swap v1-v2 cross ;

! : polygon ( vertices -- )
! GL_POLYGON glBegin dup polygon-normal first3 glNormal3f
! [ first3 glVertex3f ] each glEnd ;

: polygon ( vertices -- )
dup length* 3 >=
[ GL_POLYGON glBegin dup polygon-normal first3 glNormal3f
  [ first3 glVertex3f ] each glEnd ]
[ drop ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: vertices

! V{ } vertices set-global

: start-polygon ( -- ) 0 <vector> vertices set ;

: finish-polygon ( -- ) vertices get polygon ;

: polygon-vertex ( -- ) position get vertices get push ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : setup-variables ( -- )
! V{ } vertices set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! How $ works:

!      V x H
! L = -------
!     |V x H|

! V : direction opposite to gravity

: V ( -- ) { 0 1 0 } ;

: H ( -- ) orientation get [ first  ] map ;
: L ( -- ) orientation get [ second ] map ;
: U ( -- ) orientation get [ third  ] map ;

: set-H ( { a b c } -- ) orientation get [ 0 swap set-nth ] 2each ;
: set-L ( { a b c } -- ) orientation get [ 1 swap set-nth ] 2each ;
: set-U ( { a b c } -- ) orientation get [ 2 swap set-nth ] 2each ;

: roll-until-horizontal ( -- ) V H cross dup norm v/n set-L ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lindenmayer string rewriting
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: rules

: segment ( str -- seq )
{ { [ dup "" = ] [ drop [ ] ] }
  { [ dup length* 1 = ] [ unit ] }
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

: last ( seq -- [ last-item ] ) dup length* 1- tail ;

SYMBOL: command-table

: segment-command ( seg -- command ) 1 head ;

: segment-parameter ( seg -- parameter )
dup length* 1 - 2 swap rot subseq parse call ;

: segment-parts ( seg -- param command )
dup segment-parameter swap segment-command ;

: exec-command ( str -- ) command-table get hash dup [ call ] [ drop ] if ;

: exec-command-with-param ( param command -- )
command-table get hash dup [ last call ] [ 2drop ] if ;

: (interpret) ( seg -- )
dup length* 1 =
[ exec-command ] [ segment-parts exec-command-with-param ] if ;

: interpret ( str -- ) segment [ (interpret) ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Lparser dialect
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: angle
SYMBOL: length
SYMBOL: thickness
SYMBOL: color-index

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: set-thickness
DEFER: set-color-index

TUPLE: state position orientation angle length thickness color-index ;

! SYMBOL: states V{ } states set-global

SYMBOL: states

: save-state ( -- )
position get orientation get angle get length get thickness get
color-index get <state>
states get push ;

: restore-state ( -- )
states get pop
dup state-position    position set
dup state-orientation orientation set
dup state-length      length set
dup state-angle       angle set
dup state-color-index set-color-index
dup state-thickness   set-thickness
drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scale-length ( m -- ) length get * length set ;

: scale-angle ( m -- ) angle get * angle set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: color-table

: setup-color-table ( -- )
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
} color-table set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: sequences

: >float-array ( seq -- )
dup length "float" <c-array> swap dup length >array
[ pick set-float-nth ] 2each ;

USE: lindenmayer

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: material-color ( r g b -- )
3array 1.0 add >float-array
GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE rot glMaterialfv ;

: set-color-index ( i -- )
dup color-index set color-table get nth dup
first3 glColor3f first3 material-color ;

: inc-color-index ( -- ) color-index get 1 + set-color-index ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-thickness ( i -- ) dup thickness set glLineWidth ;

: scale-thickness ( m -- ) thickness get * 0.5 max set-thickness ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: -rotate-y neg rotate-y ;
: -rotate-x neg rotate-x ;
: -rotate-z neg rotate-z ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: setup-variables ( -- )
V{ } vertices set   V{ } states set   setup-color-table ;

: lparser-dialect ( -- )

setup-variables

1 length set   45 angle set   1 thickness set   2 set-color-index

H{ { "+" [ angle get     rotate-y ] }
   { "-" [ angle get    -rotate-y ] }
   { "&" [ angle get     rotate-x ] }
   { "^" [ angle get    -rotate-x ] }
   { "<" [ angle get     rotate-z ] }
   { ">" [ angle get    -rotate-z ] }

   { "|" [ 180.0         rotate-y ] }
   { "%" [ 180.0         rotate-z ] }
   { "$" [ roll-until-horizontal ]  }

   { "F" [ length get     draw-forward ] }
   { "Z" [ length get 2 / draw-forward ] }
   { "f" [ length get     move-forward ] }
   { "z" [ length get 2 / move-forward ] }
   { "g" [ length get     sneak-forward ] }
   { "." [ polygon-vertex ] }

   { "[" [ save-state ] }
   { "]" [ restore-state ] }
   { "{" [ start-polygon ] }
   { "}" [ finish-polygon ] }

   { "/" [ 1.1 scale-length ] } ! double quote command in lparser
   { "'" [ 0.9 scale-length ] }
   { ";" [ 1.1 scale-angle ] }
   { ":" [ 0.9 scale-angle ] }
   { "?" [ 1.4 scale-thickness ] }
   { "!" [ 0.7 scale-thickness ] }

   { "c" [ color-index get 1 + color-table get length* mod set-color-index ] }

} command-table set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Examples
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: axiom
SYMBOL: result

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: koch ( -- ) lparser-dialect   90 angle set

H{ { "K" "[[a|b] '(0.41)f'(2.439) |<(60) [a|b]]" }
   { "k" "[ c'(0.5) K]" }
   { "a" "[d <(120) d <(120) d ]" }
   { "b" "e" }
   { "e" "[^ '(.2887)f'(3.4758) &(180)      +z{.-(120)f-(120)f}]" }
   { "d" "[^ '(.2887)f'(3.4758) &(109.5111) +zk{.-(120)f-(120)f}]" }
} rules set

"K" axiom set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: spiral-0 ( -- ) lparser-dialect  10 angle set-global  5 thickness set-global

"[P]|[P]" axiom set-global

H{ { "P" "[A]>>>>>>>>>[cB]>>>>>>>>>[ccC]>>>>>>>>>[cccD]" }
   { "A" "F+;'A" }
   { "B" "F!+F+;'B" }
   { "C" "F!^+F^+;'C" }
   { "D" "F!>^+F>^+;'D" }
} rules set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tree-5 ( -- ) lparser-dialect   5 angle set-global   1 thickness set-global

"c(4)FFS" axiom set-global

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
} rules set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-1 ( -- ) lparser-dialect   45 angle set-global   5 set-thickness

H{ { "A" "F[&'(.8)!BL]>(137)'!(.9)A" }
   { "B" "F[-'(.8)!(.9)$CL]'!(.9)C" }
   { "C" "F[+'(.8)!(.9)$BL]'!(.9)B" }

   { "L" "~c(8){+(30)f-(120)f-(120)f}" }
} rules set-global

"c(12)FFAL" axiom set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-2 ( -- ) lparser-dialect   30 angle set-global   5 thickness set-global

H{ { "A" "F[&'(.7)!BL]>(137)[&'(.6)!BL]>(137)'(.9)!(.9)A" }
   { "B" "F[-'(.7)!(.9)$CL]'(.9)!(.9)C" }
   { "C" "F[+'(.7)!(.9)$BL]'(.9)!(.9)B" }

   { "L" "~c(8){+(45)f(.1)-(45)f(.1)-(45)f(.1)+(45)|+(45)f(.1)-(45)f(.1)-(45)f(.1)}" }

} rules set-global

"c(12)FAL" axiom set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-3 ( -- ) lparser-dialect   30 angle set-global   5 thickness set-global

H{ { "A" "!(.9)t(.4)FB>(94)B>(132)B" }
   { "B" "[&t(.4)F$A]" }
   { "F" "'(1.25)F'(.8)" }
} rules set-global

"c(12)FA" axiom set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-4 ( -- ) lparser-dialect   18 angle set-global 5 thickness set-global

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
} rules set-global

"c(12)&(20)N" axiom set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-5 ( -- ) lparser-dialect   5 angle set-global   5 thickness set-global

H{ { "a" "F[+(45)l][-(45)l]^;ca" }

   { "l" "j" }
   { "j" "h" }
   { "h" "s" }
   { "s" "d" }
   { "d" "x" }
   { "x" "a" }

   { "F" "'(1.17)F'(.855)" }
} rules set-global

"&(90)+(90)a" axiom set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-6 ( -- ) lparser-dialect   5 angle set-global   5 thickness set-global

"&(90)+(90)FFF[-(120)'(.6)x][-(60)'(.8)x][+(120)'(.6)x][+(60)'(.8)x]x"
axiom set-global

H{ { "a" "F[cdx][cex]F!(.9)a" }
   { "x" "a" }

   { "d" "+d" }
   { "e" "-e" }

   { "F" "'(1.25)F'(.8)" }
} rules set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: airhorse ( -- ) lparser-dialect 10 angle set-global 5 thickness set-global

"C" axiom set-global

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
} rules set-global ;

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
