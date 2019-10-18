! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel quoting sequences splitting ;
IN: html.parser.utils

: trim1 ( seq ch -- newseq )
    [ [ ?head-slice drop ] [ ?tail-slice drop ] bi ] keepd like ;

: single-quote ( str -- newstr ) "'" dup surround ;

: double-quote ( str -- newstr ) "\"" dup surround ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: ?quote ( str -- newstr ) dup quoted? [ quote ] unless ;
