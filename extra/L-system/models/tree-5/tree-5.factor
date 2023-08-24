
USING: accessors ui L-system ;

IN: L-system.models.tree-5

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tree-5 ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 5 >>angle ] >>turtle-values

  "c(4)FFS" >>axiom

  {
    { "S" "FFR>(60)R>(60)R>(60)R>(60)R>(60)R>(30)S" }
    { "R" "[Ba]" }
    { "a" "$tF[Cx]Fb" }
    { "b" "$tF[Dy]Fa" }
    { "B" "&B" }
    { "C" "+C" }
    { "D" "-D" }

    { "x" "a" }
    { "y" "b" }

    { "F" "'(1.25)F'(.8)" }
  }
    >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> tree-5 "L-system" open-window ] with-ui ;

MAIN: main
