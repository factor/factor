
USING: accessors ui L-system ;

IN: L-system.models.abop-5-angular

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-5-angular ( L-system -- L-system )

  L-parser-dialect >>commands

  "&(90)+(90)a" >>axiom

  {
    { "a" "F[+(45)l][-(45)l]^;ca" }

    { "l" "j" }
    { "j" "h" }
    { "h" "s" }
    { "s" "d" }
    { "d" "x" }
    { "x" "a" }

    { "F" "'(1.17)F'(.855)" }
  }
    >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-5-angular "L-system" open-window ] with-ui ;

MAIN: main

