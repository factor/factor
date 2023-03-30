! File: cnc.tools.resurface
! Version: 0.1
! DRI: Dave Carlton
! Description: Build gcode to resurface 
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cnc cnc.gcode cnc.job cnc.jobs cnc.machine cnc.tools formatting
io kernel math multiline sequences io.encodings.utf8 io.files math.parser
cnc.bit cnc.machine.1F command-line namespaces variables generalizations sequences.generalizations prettyprint ;
IN: cnc.tools

:: do-x ( gcodes x ymax step -- gcodes )
    gcodes
    x ymax          "X %.02f Y %.02f" sprintf  suffix
    x step +  ymax  "X %.02f Y %.02f" sprintf  suffix
    x step +  0     "X %.02f Y %.02f" sprintf  suffix
    ;

:: do-y ( gcodes y xmax step -- gcodes )
    gcodes
    xmax          y "X %.02f Y %.02f" sprintf  suffix
    xmax   y step + "X %.02f Y %.02f" sprintf  suffix
    0      y step + "X %.02f Y %.02f" sprintf  suffix
    ;

:: surface-x ( gcodes toolpath -- gcodes )  ! assume starts at home, ends at home
    toolpath machine>> x-max>> :> xmax
    toolpath machine>> y-max>> :> ymax
    toolpath bit>> stepover>> >number :> step
    0 :> x!  0 :> y! 
    gcodes
    [ x xmax <= ]
    (( up over down over ))
    [   x ymax step do-x
        x step 2 * + x!
        x 0 "X %.02f Y %.02f" sprintf  suffix
    ]  while
B    but-last ! do last step to remaining distance
    xmax step /mod nip :> laststep  x step - :> lastx
    lastx laststep + 0 "X %.02f Y %.02f" sprintf  suffix
    lastx ymax laststep do-x 
    ;
 
:: surface-y ( gcodes toolpath -- gcodes )  ! assume starts at home, ends at home
    toolpath machine>> x-max>> :> xmax
    toolpath machine>> y-max>> :> ymax
    toolpath bit>> stepover>> >number :> step
    0 :> x!  0 :> y!
    gcodes
    [ y ymax < ]
    (( across up back up ))
    [   y xmax step do-y
        y step 2 * + y!
        0 y "X %.02f Y %.02f" sprintf  suffix
    ]  while
    but-last ! do last step to remaining distance
    ymax step /mod nip :> laststep  y step - :> lasty
    0 lasty laststep + "X %.02f Y %.02f" sprintf  suffix
    lasty xmax laststep do-y 
    ;

: <surface-job> ( xmax ymax -- machine )
    <1F>
    "Resurface" >>name
    "Resurface Job" >>model
    swap >>y-max
    swap >>x-max ;

FROM: cnc.gcode => f ; 
:: resurfacex ( toolpath -- )
    "~/Desktop/"  toolpath machine>> name>> "-x" append  append  ".gcode" append  :> path
    preamble
    g1 0 x 0 y toolpath bit>> feed_rate>> f suffix
    3 M toolpath bit>> spindle_speed>>  s suffix
    g1 toolpath bit>> stepdown>> >number  neg z  
    toolpath bit>> plunge_rate>> f  suffix
    g1 0 x 0 y toolpath bit>> feed_rate>> f suffix
    toolpath surface-x
    g0 10 z  suffix
    g0 0 x 0 y  suffix
    g1 toolpath bit>> stepdown>> >number  neg z  suffix
    92 G  0 z  suffix
    path utf8 [
        [ print ] each
    ] with-file-writer ;

:: resurfacey ( toolpath -- )
    "~/Desktop/"  toolpath machine>> name>> "-y" append  append  ".gcode" append  :> path
    preamble
    g1 0 x 0 y toolpath bit>> feed_rate>> f suffix
    3 M toolpath bit>> spindle_speed>> s  suffix
    g1 toolpath bit>> stepdown>> >number  neg z
    toolpath bit>> plunge_rate>> f suffix
    g1 0 x 0 y toolpath bit>> feed_rate>> f suffix
    toolpath surface-y
    g0 10 z  suffix
    g0 0 x 0 y  suffix
    g1 toolpath bit>> stepdown>> >number neg z  suffix
    92 G  0 z  suffix
    path utf8 [
        [ print ] each
    ] with-file-writer ;

:: bounds-check ( toolpath -- )
    "~/Desktop/"  toolpath machine>> name>> append  " Boundary.gcode" append  utf8  
    [ toolpath boundary ] with-file-writer ;

SYMBOL: LAST-TOOLPATH
FROM: cnc.bit => >mm ; 
: bit-resurface ( bit xmax ymax -- )
    <surface-job> <toolpath>
    dup LAST-TOOLPATH set
    [ resurfacex  ] keep
    [ resurfacey  ] keep
    bounds-check
    ;

: resurface ( xmax ymax -- bit )
    "mukaj-togif" bit-id= 
    1 >>stepdown-mm  2 >>rate_units  1.2 >>feed_rate  0.6 >>plunge_rate
    rot rot [ bit-resurface ] keep ;
    
GLOBAL: xmax
GLOBAL: ymax
GLOBAL: bitsize
GLOBAL: speed
GLOBAL: feed
GLOBAL: depth
GLOBAL: help

FROM: syntax => f ;
: reset-globals ( -- )
    { "help" "xmax" "ymax" "bitsize" "speed" "feed" "depth" } [ f swap set-global ] each ;
    
: usage ( -- )
    "resurface --xmax=n --ymax=n --bitsize=n --speed=n --feed=n --depth=n" print
    "  All values are in mm" print
    ;

! : (resurface-args) ( -- )
!     "help" get-global
!     [ usage ]
!     [
!         { "xmax" "ymax" "bitsize" "speed" "feed" "depth" } [ get-global ] map  
!         f over member?
!         [ drop  usage ] 
!         [ [ string>number ] map
!           6 firstn  resurface
!           "Resurface files have been written to the desktop" print
!         ]
!         if
!     ] if
!     ;

! : resurface-args ( -- )
!     reset-globals
!     command-line get parse-command-line  (resurface-args)
!     ;

! : resurface-test ( -- )
!     reset-globals
!     { "factor" "--xmax=200" "--ymax=200" "--bitsize=40" "--speed=16000" "--feed=3000" "--depth=0.5" }
!     parse-command-line 
!     (resurface-args) ; 
    
! MAIN: resurface-args

