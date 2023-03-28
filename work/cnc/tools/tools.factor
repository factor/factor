! File: cnc.tools
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cnc cnc.gcode cnc.job cnc.jobs cnc.machine formatting
io kernel math multiline sequences io.encodings.utf8 io.files math.parser
cnc.machine.1F command-line namespaces variables generalizations sequences.generalizations prettyprint ;
IN: cnc.tools

TUPLE: toolpath  id machine bit gcode ;
: <toolpath> ( bit machine -- toolpath )
    toolpath new
    swap >>machine
    swap >>bit
    ;

FROM: cnc.gcode => f ;

:: boundary ( toolpath -- )   
    toolpath machine>> x-max>> :> xmax
    toolpath machine>> y-max>> :> ymax
    { }
    90 G +g
    g1 3000 f +g
    g1 10 z +g
    g1 0 x 0 y +g
    g1 xmax x +g
    g1 ymax y +g
    g1 0 x +g
    g1 0 y +g
    [ print ] each
    ;
    
: preamble ( -- {gcodes} )   ! Set absolute, mm, move z up, home, move z down to 1 mm
    { }
    absolute +g  mm +g
    g0 10 z  1500 f +g
    home-xy 1000 f +g
    g0 1 z +g
    ;
        

