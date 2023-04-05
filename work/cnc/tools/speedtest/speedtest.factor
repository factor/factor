! File: cnc.tools.speedtest
! Version: 0.1
! DRI: Dave Carlton
! Description: Build gcode file to test bits
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: cnc.machine.1F kernel namespaces cnc.job uuid accessors math calendar cnc.tools ;

IN: cnc.tools.speedtest

SYMBOLS: xstart ystart xend yend units ; 

FROM: cnc.tools.speedtest => units ; 
: use-inch ( -- )   25.4 units set ;
: use-mm ( -- )   1 units set ;

TUPLE: speed start inc ;

: (set-units) ( start inc object -- object )
    swap  units get *  >>inc
    swap  units get *  >>start ;
    
: <speed> ( start inc -- <speed> )
    speed new
    swap >>inc
    swap >>start ;

TUPLE: feed < speed ;
: <feed> ( start inc -- <feed> )
    feed new (set-units) ;

TUPLE: doc < speed ;
: <doc> ( start inc -- <doc> )
    doc new (set-units) ;

TUPLE: test-job < job speed feed doc bit ;

: <test-job> ( <bit> <speed> <feed> <doc> -- <test-job> )
    test-job new
    swap >>bit
    uuid1 >>job_id
    "speedtest" >>job_name
    today >>job_date
    <1F> >>machine_id
    swap >>speed
    swap >>feed
    swap >>doc
    ;
    
: testpath ( xstart ystart xend yend -- )
    "yend" set
    "xend" set
    "ystart" set
    "xstart" set
    ;

: speedtest ( bit -- job )
    use-mm
    8000 1000 <speed>
    800 100 <feed>
    .1 .1 <doc>
    <test-job>
    slots[ machine_id bit speed feed doc ]
    slots[ depth step ] 
    
    
    
    ;



