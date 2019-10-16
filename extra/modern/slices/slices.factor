! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math sequences
sequences.deep sequences.extras strings unicode sequences.private ;
IN: modern.slices

: ?1- ( n/f -- n'/f ) dup [ 1 - ] when ;
: ?1+ ( n/f -- n'/f ) dup [ 1 + ] when ;

: ?nth-of ( seq n/f -- elt/f )
    dup [
        2dup swap bounds-check? [ swap nth-unsafe ] [ 2drop f ] if
    ] [
        nip
    ] if ; inline

: >strings ( seq -- str )
    [ dup slice? [ >string ] when ] deep-map ;

: matching-section-delimiter ( string -- string' )
    dup ":" tail? [
        rest but-last ";" ">" surround
    ] [
        rest ">" append
    ] if ;

ERROR: unexpected-end string n ;
: nth-check-eof ( string n -- nth )
    2dup ?nth-of [ 2nip ] [ unexpected-end ] if* ;

! Allow eof
: next-char-from ( string n/f -- string n'/f ch/f )
    dup [
        2dup ?nth-of dup [ [ 1 + ] dip ] when
    ] [
        f
    ] if ;

: find-from' ( ... seq n quot: ( ... elt -- ... ? ) -- ... i elt )
    swapd find-from ; inline

: find-from* ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt ? )
    [ find-from ] 2keep drop
    pick [ drop t ] [ length -rot nip f ] if ; inline

: find-from*' ( ... seq n quot: ( ... elt -- ... ? ) -- ... i elt ? )
    swapd find-from* ; inline

:: (slice-until) ( string n quot -- string n' slice/f ch/f )
    string n quot find-from' :> ( n' ch )
    string n'
    n n' string ?<slice>
    ch ; inline

: slice-until ( string n quot -- string n' slice/f )
    (slice-until) drop ; inline

! Don't include the whitespace in the slice
:: slice-til-quot ( string n quot -- string n'/f slice/f ch/f )
    n [
        ! BUG: (slice-until) is broken here?!
        string n quot find-from' :> ( n' ch )
        string n'
        n n' string ?<slice>
        ch
    ] [
        string f f f
    ] if ; inline

: slice-til-whitespace ( string n -- string n' slice/f ch/f )
    [ "\s\r\n" member? ] slice-til-quot ; inline

: slice-til-not-whitespace ( string n -- string n' slice/f ch/f )
    [ "\s\r\n" member? not ] slice-til-quot ; inline

: skip-whitespace ( string n/f -- string n'/f )
    slice-til-not-whitespace 2drop ;

: empty-slice-end ( seq -- slice )
    [ length dup ] [ ] bi <slice> ; inline

:: slice-til-eol ( string n -- string n' slice/f ch/f )
    n [
        string n '[ "\r\n" member? ] find-from' :> ( n' ch )
        string n'
        n n' string ?<slice>
        ch
    ] [
        string n
        string empty-slice-end
        f
    ] if ; inline

: merge-slice-til-whitespace ( string n slice --  string n' slice' )
    over [
        [ slice-til-whitespace drop ] dip merge-slices
    ] when ;

: merge-slice-til-not-whitespace ( string n slice --  string n' slice' )
    over [
        [ slice-til-not-whitespace drop ] dip merge-slices
    ] when ;

:: slice-til-separator-inclusive ( string n tokens -- string n' slice/f ch/f )
    string n '[ tokens member? ] find-from' [ ?1+ ] dip  :> ( n' ch )
    string
    n'
    n n' string ?<slice>
    ch ; inline

! Takes at least one character if not whitespace
:: slice-til-either ( string n tokens -- string n'/f slice/f ch/f )
    n [
        string n '[ tokens member? ] find-from'
        dup "\s\r\n" member? [ [ ?1+ ] dip ] unless :> ( n' ch )
        string
        n'
        n n' string ?<slice>
        ch
    ] [
        string f f f
    ] if ; inline

ERROR: subseq-expected-but-got-eof string n expected ;

:: slice-til-string ( string n search --  string n'/f payload end-string )
    search string n subseq-start-from :> n'
    n' [ string n search subseq-expected-but-got-eof ] unless
    string
    search length n' +
    n n' string ?<slice>
    n' dup search length + string ?<slice> ;

: modify-from ( slice n -- slice' )
    '[ from>> _ + ] [ to>> ] [ seq>> ] tri <slice> ;

: modify-to ( slice n -- slice' )
    [ [ from>> ] [ to>> ] [ seq>> ] tri ] dip
    swap [ + ] dip <slice> ;

: rewind-slice ( string n slice -- string n' )
    over [
        length -
    ] [
        nip [ [ length ] bi@ - ] keepd swap
    ] if ; inline
