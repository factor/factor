! File: sander.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2018 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math math.parser namespaces sequences prettyprint io.files io.encodings.utf8 ;
IN: gcode.sander

CONSTANT: bedX 200
CONSTANT: bedY 180
CONSTANT: wipeSize 20
SYMBOL: posX
SYMBOL: posY
SYMBOL: direction

: numAppend ( string n -- string )
    number>string append
    ;
: space ( string -- 'string )
    " " append ;

: XRight ( -- string )
    "G1 X" bedX numAppend space ;
: XLeft ( -- string )
    "G1 X-" bedX numAppend space ;

: YUp ( -- string )
    "G1 Y" bedY numAppend space ;
: YDown ( -- string )
    "G1 Y-" bedY numAppend space ;

: (wipe) ( string -- string )
    wipeSize numAppend space ;

: YBack ( -- string )
    "Y" (wipe) 
    posY get wipeSize + posY set
    posY get bedY >
    [ 1 direction set ] when
    ;

: YForward ( -- string )
    "Y-" (wipe) 
    posY get wipeSize - posY set
    posY get 0 <=
    [ 0 direction set ] when
    ;

: XBack ( -- string )
    "X" (wipe) 
    posX get wipeSize + posX set
    posX get bedX >
    [ 1 direction set ] when
    ;

: XForward ( -- string )
    "X-" (wipe) 
    posX get wipeSize - posX set
    posX get 0 <=
    [ 0 direction set ] when
    ;

: direction? ( -- bool )
    direction get 0=
    ;

: (wipey) ( -- string )
    direction? 
    [ YBack ]
    [ YForward ]
    if
;

: (wipex) ( -- string )
    direction? 
    [ XBack ]
    [ XForward ]
    if
;

SYMBOL: gcode-lines

: save-line ( string -- )
    gcode-lines get swap suffix
    gcode-lines set
    ;

: wipeX ( -- )
    XRight (wipey) append  save-line
    XLeft  save-line
    ;

: wipeY ( -- )
    YUp  (wipex) append  save-line
    YDown save-line ;

: start ( -- )
    0 posY set
    0 posX set
    0 direction set
    { } gcode-lines set
    "G91" save-line
    "G1 F7200" save-line
    ;

: finish ( -- )
    "G1 X0 Y0 Z50" save-line
    "M84" save-line
    ;

: wipes ( n -- )
    dup
    <iota> [ drop wipeX ] each
    "G1 X0 Y0 ; Switch direction" save-line
    <iota> [ drop wipeY ] each
    finish
;

CONSTANT: sander-file "/Users/davec/Downloads/sander.gcode"

: save-gcode ( -- )
    gcode-lines get sander-file utf8 set-file-lines
    ;
