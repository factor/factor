
USING: accessors ui L-system ;

IN: L-system.models.abop-1

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: abop-1 ( L-system -- L-system )
  
  L-parser-dialect >>commands

  "c(12)FFAL" >>axiom

  {
    { "A" "F [ & '(.8) !       B L ] >(137) ' !(.9) A" }
    { "B" "F [ - '(.8) !(.9) $ C L ]        ' !(.9) C" }
    { "C" "F [ + '(.8) !(.9) $ B L ]        ' !(.9) B" }
    
    { "L" " ~ c(8) { +(30) f -(120) f -(120) f }" }
  }
  >>rules ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: main ( -- ) [ <L-system> abop-1 "L-system" open-window ] with-ui ;

MAIN: main
