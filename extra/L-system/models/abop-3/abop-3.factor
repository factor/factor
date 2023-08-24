
USING: accessors ui L-system ;

IN: L-system.models.abop-3

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-3 ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 30 >>angle ] >>turtle-values

  "c(12)FA" >>axiom

 {
   { "A" "!(.9)t(.4)FB>(94)B>(132)B" }
   { "B" "[&t(.4)F$A]" }
   { "F" "'(1.25)F'(.8)" }
 }
   >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-3 "L-system" open-window ] with-ui ;

MAIN: main
