
USING: accessors ui L-system ;

IN: L-system.models.abop-4

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-4 ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 18 >>angle ] >>turtle-values

  "c(12)&(20)N" >>axiom

  {
    {
      "N"
      "FII[&(60)rY]>(90)[&(45)'(0.8)rA]>(90)[&(60)rY]>(90)[&(45)'(0.8)rD]!FIK"
    }
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
  }
    >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-4 "L-system" open-window ] with-ui ;

MAIN: main
