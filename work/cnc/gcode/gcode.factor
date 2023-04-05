! File: cnc.gcode
! Version: 0.1
! DRI: Dave Carlton
! Description: Build G-Code
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors cnc cnc.machine kernel make math math.parser multiline
namespaces sequences strings ;

IN: cnc.gcode

SYMBOL: cnc-machine
TUPLE: gcodes step feed bit-size codes ;

: <gcode> ( -- gcodes )
    gcodes new
    { } >>codes
    ;

: (gc) ( gcode n letter -- str )
    [ dup number? [ number>string +space ] when ] dip  prepend  append ;

: g0 ( -- gcode )   "G0 " ;
: g1 ( -- gcode )   "G1 " ;

: b ( gcode n -- gcode )  "B" (gc) ;
: e ( gcode n -- gcode )  "E" (gc) ;
: f ( gcode n -- gcode )  "F" (gc) ;
: g ( gcode n -- gcode )  "G" (gc) ;
: h ( gcode n -- gcode )  "H" (gc) ;
: i ( gcode n -- gcode )  "I" (gc) ;
: j ( gcode n -- gcode )  "J" (gc) ;
: s ( gcode n -- gcode )  "S" (gc) ;
: t ( gcode n -- gcode )  "T" (gc) ;
: p ( gcode n -- gcode )  "P" (gc) ;
: z ( gcode z -- gcode )  "Z" (gc) ;
: x ( gcode x -- gcode )  "X" (gc) ;
: y ( gcode y -- gcode )  "Y" (gc) ;
: m ( gcode n -- gcode )  "M" (gc) ;
: G ( n -- gcode )  "" swap g ;
: M ( n -- gcode )  "" swap m ;

: home-xy ( -- gcode )  g0 0 x 0 y ;

: home-z ( -- gcode )  g0 0 z ;

: +g ( seq gcode -- {gcodes} )  suffix ;

! G Codes
: arc-cw ( -- gcode )  2 G ;
: arc-ccw ( -- gcode )  3 G ;
: dwell ( seconds -- gcode )
    dup float?
    [ [ "G4 P" %  1000 * >integer  # ] "" make ]
    [ [ "G4 S" % # ] "" make ] if
    ;
: in ( -- gcode )  20 G ;
: mm ( -- gcode )  21 G ;
: auto-home ( -- gcode )  28 G ;
: zprobe ( -- gcode )  30 G ;
: probe-error ( -- gcode )  38.2 G ;
: probe-noerror ( -- gcode )  38.3 G ;
: machine-coord ( -- gcode )  53 G ;
: work-coord ( n -- gcode )
    7 over <
    [ 54 + ]
    [ 1 +  8 mod  number>string  "." prepend
      59 G prepend
    ] if
    ;   
: absolute ( -- gcode )  90 G ;
: relative ( -- gcode )  91 G ; 
: set-position ( -- gcode )  92 G ;    

! M Codes
!
! On Snapmaker 2 spindle can use either P or S
: spindle-cw ( -- gcode )  3 M ;
: spindle-ccw ( -- gcode ) 4 M ;
: spindle-on ( -- gc )  spindle-cw ;
: spindle-off ( -- gc )  5 M ;

: enable-steppers ( -- gc )  17 M ;
: disable-steppers ( -- gc )  18 M ;

: pause-hmi ( -- gc )  25 M ;
: print-time ( -- gc )  31 M ;
: debug-pins ( -- gc )  43 M ;
: pause-print ( -- gc )  76 M ;
: power-off ( -- gc )  81 M ;
: e-absolute ( -- gc )  83 M ;
: e-relative ( -- gc )  84 M ;
: set-axis-steps ( -- gc )  92 M ;
: temp-nowait ( -- gc )  104 M ; 
: temp-wait ( -- gc )  109 M ;    ! Set target temperature for E1 to 205 = set-temp-wait 1 e 205 s

: fan-on ( -- gc )  106 M ;
: fan-off ( -- gc )  107 M ;
: debug-level ( -- gc )  111 M ;
: stop ( -- gc )  112 M ;
: current-position ( -- gc )  114 M ;
: firmware ( -- gc )  115 M ;
: message ( -- gc )  117 M ;
: serial-print ( -- gc )  118 M ;
: endstop-states ( -- gc )  119 M ;
: enable-endstops ( -- gc )  120 M ;
: disable-endstops ( -- gc )  121 M ;
: bed-temp-nowait ( -- gc )  140 M ;
: bed-temp-wait ( -- gc )  190 M ;
: temp-report ( -- gc )  155 M ;
: filament-diameter ( -- gc )  200 M ;
: max-acceleration ( -- gc )  201 M ;
: max-feedrate ( -- gc )  203 M ;
: starting-acceleration ( -- gc )  204 M ;
: advanced-ettings ( -- gc )  205 M ;
: home-offsets ( -- gc )  206 M ;
: software-endstops ( -- gc )  211 M ;
: feedrate-percentage ( -- gc )  220 M ;
: set-pid ( -- gc )  301 M ;
: cold-extrude ( -- gc )  302 M ;
: finish-moves ( -- gc )  400 M ;
: deploy-probe ( -- gc )  401 M ;
: stow-probe ( -- gc )  402 M ;
: quick-stop ( -- gc )  410 M ;
: filament-runout ( -- gc )  412 M ;
: powerloss-recovery ( -- gc )  413 M ;
: bed-leveling-state ( -- gc )  420 M ;
: set-mesh-value ( -- gc )  421 M ;
: backlash-compensation ( -- gc )  425 M ;
: home-offsets-here ( -- gc )  428 M ;
: save-settings ( -- gc )  500 M ;
: restore-settings ( -- gc )  501 M ;
: factory-reset ( -- gc )  502 M ;
: report-settings ( -- gc )  503 M ;
: vlaidate-eeprom ( -- gcode )  504 M ;
: endstops-abort ( -- gcode )  540 M ;
: filament-change ( -- gcode )  600 M ;
: zprobe-offset ( -- gcode )  851 M ;
: linear-advance ( -- gcode )  900 M ;
: start-logging ( -- gcode )  928 M ;


