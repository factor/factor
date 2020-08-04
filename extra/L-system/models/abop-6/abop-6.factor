
USING: accessors ui L-system ;

IN: L-system.models.abop-6

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-6 ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 5 >>angle ] >>turtle-values

  ! "&(90)+(90)FFF[-(120)'(.6)x][-(60)'(.8)x][+(120)'(.6)x][+(60)'(.8)x]x"
  "FFF[-(120)'(.6)x][-(60)'(.8)x][+(120)'(.6)x][+(60)'(.8)x]x"
  >>axiom

  {
    { "a" "F[cdx][cex]F!(.9)a" }
    { "x" "a" }

    { "d" "+d" }
    { "e" "-e" }

    { "F" "'(1.25)F'(.8)" }
  }
    >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-6 "L-system" open-window ] with-ui ;

MAIN: main

