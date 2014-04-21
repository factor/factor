! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel quoting sequences splitting ;
IN: html.parser.utils

: trim1 ( seq ch -- newseq )
    [ [ ?head-slice drop ] [ ?tail-slice drop ] bi ] 2keep drop like ;

: single-quote ( str -- newstr ) "'" dup surround ;

: double-quote ( str -- newstr ) "\"" dup surround ;

: quote ( str -- newstr )
    CHAR: ' over member?
    [ double-quote ] [ single-quote ] if ;

: ?quote ( str -- newstr ) dup quoted? [ quote ] unless ;

CONSTANT: html-entities H{
    { "&quot;" "\"" }
    { "&lt;" "<" }
    { "&gt;" ">" }
    { "&amp;" "&" }
    { "&#39;" "'" }
}

: html-unescape ( str -- str' )
    html-entities [ replace ] assoc-each ;

: html-escape ( str -- str' )
    html-entities [ swap replace ] assoc-each ;
