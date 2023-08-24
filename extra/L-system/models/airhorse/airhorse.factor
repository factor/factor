
USING: accessors ui L-system ;

IN: L-system.models.airhorse

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: airhorse ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 10 >>angle ] >>turtle-values

  "C" >>axiom

  {
    { "C" "LBW" }

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
  }
    >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> airhorse "L-system" open-window ] with-ui ;

MAIN: main
