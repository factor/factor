
USING: accessors ui L-system ;

IN: L-system.models.abop-2

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-2 ( L-system -- L-system )

  L-parser-dialect >>commands

  [ 30 >>angle ] >>turtle-values

  "c(12)FAL" >>axiom

  {
    { "A" "F [&'(.7)!BL] >(137) [&'(.6)!BL] >(137) '(.9) !(.9) A" }
    
    { "B" "F [- '(.7) !(.9) $ C L] '(.9) !(.9) C" }
    { "C" "F [+ '(.7) !(.9) $ B L] '(.9) !(.9) B" }

    { "L" "~c(8){+f(.1)-f(.1)-f(.1)+|+f(.1)-f(.1)-f(.1)}" }

  } >>rules ;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-2 "L-system" open-window ] with-ui ;

MAIN: main
