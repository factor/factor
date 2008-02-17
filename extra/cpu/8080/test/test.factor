USING: kernel cpu.8080 cpu.8080.emulator math math io
tools.time combinators sequences io.files ;
IN: cpu.8080.test

: step ( cpu -- )
  #! Run a single 8080 instruction
  [ read-instruction ] keep ! n cpu
  over get-cycles over inc-cycles
  [ swap instructions case ] keep
  [ cpu-pc HEX: FFFF bitand ] keep 
  [ set-cpu-pc ] keep 
  process-interrupts ;


: test-step ( cpu -- cpu )
  [ step ] keep dup cpu. ;

: test-cpu ( -- cpu )
  <cpu> "invaders.rom" over load-rom dup cpu. ;

: test-n ( n -- )
  test-cpu swap [ test-step ] times drop ;

: run-n ( cpu n -- cpu )
  [ dup step ] times ;

: each-8bit ( n quot -- )
  8 -rot [ >r bit? r> call ] 2curry each ; inline

: >ppm ( cpu filename -- cpu )
  #! Dump the current screen image to a ppm image file with the given name.
  <file-writer> [
    "P3" print
    "256 224" print
    "1" print
    224 [
      32 [
        over 32 * over +  HEX: 2400 + ! cpu h w addr
        >r pick r> swap cpu-ram nth [
          0 = [
            " 0 0 0" write
          ] [
            " 1 1 1" write
          ] if
        ] each-8bit drop
      ] each drop nl
    ] each
  ] with-stream ;

: time-test ( -- )
  test-cpu [ 1000000 run-n drop ] time ;
