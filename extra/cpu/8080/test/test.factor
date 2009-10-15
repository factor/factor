USING: 
    accessors
    combinators
    cpu.8080
    cpu.8080.emulator
    io
    io.files
    io.encodings.ascii
    kernel 
    math
    math.bits
    sequences
    tools.time
;
IN: cpu.8080.test

: step ( cpu -- )
  #! Run a single 8080 instruction
  [ read-instruction ] keep ! n cpu
  over get-cycles over inc-cycles
  [ swap instructions nth call( cpu -- ) ] keep
  [ pc>> HEX: FFFF bitand ] keep 
  [ (>>pc) ] keep 
  process-interrupts ;

: test-step ( cpu -- cpu )
  [ step ] keep dup cpu. ;

: invaders ( -- seq )
  {
    { HEX: 0000 "invaders/invaders.h" }
    { HEX: 0800 "invaders/invaders.g" }
    { HEX: 1000 "invaders/invaders.f" }
    { HEX: 1800 "invaders/invaders.e" }
  } ;

: test-cpu ( -- cpu )
  <cpu> invaders over load-rom* dup cpu. ;

: test-n ( n -- )
  test-cpu swap [ test-step ] times drop ;

: run-n ( cpu n -- cpu )
  [ dup step ] times ;

: each-8bit ( n quot -- )
  [ 8 <bits> ] dip each ; inline

: >ppm ( cpu filename -- cpu )
  #! Dump the current screen image to a ppm image file with the given name.
  ascii [
    "P3" print
    "256 224" print
    "1" print
    224 [
      32 [
        over 32 * over +  HEX: 2400 + ! cpu h w addr
        [ pick ] dip swap ram>> nth [
          [
            " 0 0 0" write
          ] [
            " 1 1 1" write
          ] if
        ] each-8bit drop
      ] each drop nl
    ] each
  ] with-file-writer ;

: time-test ( -- )
  test-cpu [ 1000000 run-n drop ] time ;
