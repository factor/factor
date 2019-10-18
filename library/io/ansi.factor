! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: ansi
USING: lists kernel namespaces stdio streams strings
presentation generic ;

! <ansi-stream> raps the given stream in an ANSI stream. ANSI
! streams support the following character attributes:
! bold    - if not f, text is boldface.
! ansi-fg - foreground color
! ansi-bg - background color

! black   0
! red     1
! green   2
! yellow  3
! blue    4
! magenta 5
! cyan    6
! white   7

TUPLE: ansi-stream ;
C: ansi-stream ( stream -- stream ) [ set-delegate ] keep ;

: reset ( -- code )
    #! Reset ANSI color codes.
    "\e[0m" ; inline

: bold ( -- code )
    #! Switch on boldface.
    "\e[1m" ; inline

: fg ( color -- code )
    #! Set foreground color.
    "\e[3" swap "m" cat3 ; inline

: bg ( color -- code )
    #! Set foreground color.
    "\e[4" swap "m" cat3 ; inline

: ansi-attrs ( style -- )
    "bold"    over assoc [ bold , ] when
    "ansi-fg" over assoc [ fg , ] when*
    "ansi-bg" swap assoc [ bg , ] when* ;

M: ansi-stream stream-write-attr ( string style stream -- )
    >r [ ansi-attrs , reset , ] make-string r>
    delegate stream-write ;

IN: shells

: ansi
    stdio [ <ansi-stream> ] change tty ;
