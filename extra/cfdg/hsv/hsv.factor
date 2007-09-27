
USING: kernel combinators arrays sequences math combinators.lib ;

IN: cfdg.hsv

<PRIVATE

: H ( hsv -- H ) first ;

: S ( hsv -- S ) second ;

: V ( hsv -- V ) third ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Hi ( hsv -- Hi ) H 60 / floor 6 mod ;

: f ( hsv -- f ) [ H 60 / ] [ Hi ] bi - ;

: p ( hsv -- p ) [ S 1 swap - ] [ V ] bi * ;

: q ( hsv -- q ) [ [ f ] [ S ] bi * 1 swap - ] [ V ] bi * ;

: t ( hsv -- t ) [ [ f 1 swap - ] [ S ] bi * 1 swap - ] [ V ] bi * ;

PRIVATE>

! h [0,360)
! s [0,1]
! v [0,1]

: hsv>rgb ( hsv -- rgb )
dup Hi
{ { 0 [ [ V ] [ t ] [ p ] tri ] }
  { 1 [ [ q ] [ V ] [ p ] tri ] }
  { 2 [ [ p ] [ V ] [ t ] tri ] }
  { 3 [ [ p ] [ q ] [ V ] tri ] }
  { 4 [ [ t ] [ p ] [ V ] tri ] }
  { 5 [ [ V ] [ p ] [ q ] tri ] } } case 3array ;
