! Copyright (C) 2013-2014 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license
USING: accessors ascii base64 io io.encodings
io.encodings.string io.encodings.utf16 kernel make math
math.functions sequences splitting strings ;
IN: io.encodings.utf7

TUPLE: utf7codec dialect buffer ;

! These words encodes the difference between standard utf7 and the
! dialect used by IMAP which wants slashes replaced with commas when
! encoding and uses '&' instead of '+' as the escaping character.
: utf7 ( -- utf7codec )
    {
        { { } { } }
        { { CHAR: + } { CHAR: - } }
    } V{ } utf7codec boa ;

: utf7imap4 ( -- utf7codec )
    {
        { { CHAR: / } { CHAR: , } }
        { { CHAR: & } { CHAR: - } }
    } V{ } utf7codec boa ;

: >raw-base64 ( bytes -- bytes' )
    >string utf16be encode >base64 [ CHAR: = = ] trim-tail ;

: raw-base64> ( str -- str' )
    dup length 4 / ceiling 4 * CHAR: = pad-tail base64> utf16be decode ;

: encode-chunk ( repl-pair surround-pair chunk printable? -- bytes )
    [ swap [ first ] [ concat ] bi replace nip ]
    [ >raw-base64 -rot [ first2 replace ] [ first2 surround ] bi* ] if ;

: split-chunk ( str -- after before printable? )
    dup first printable? [
        [ 1 over ] dip '[ printable? _ = not ] find-from drop
        [ cut-slice ] [ f ] if* swap
    ] keep ;

: encode-utf7-string ( str codec -- bytes )
    dialect>> first2 rot '[
        [ dup empty? ] [
            split-chunk '[ 2dup _ _ encode-chunk % ] dip
        ] until
    ] B{ } make 3nip ;

M: utf7codec encode-string
    swapd encode-utf7-string swap stream-write ;

DEFER: emit-char

: decode-chunk ( dialect -- ch buffer )
    dup first2 swap [ second read-until drop ] [ first2 swap replace ] bi*
    [ second first first { } ] [ raw-base64> emit-char ] if-empty ;

: fill-buffer ( dialect -- ch buffer )
    dup second first first read1 dup swapd = [
        drop decode-chunk
    ] [ nip { } ] if ;

: emit-char ( dialect buffer -- ch buffer' )
    [ fill-buffer ] [ nip unclip swap ] if-empty ;

: replace-all! ( src dst -- )
    [ delete-all ] keep push-all ;

M: utf7codec decode-char
    swap [
        [ dialect>> ] [ buffer>> ] bi [ emit-char ] keep replace-all!
    ] with-input-stream ;
