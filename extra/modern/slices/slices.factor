! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math sequences
sequences.deep sequences.extras strings unicode sequences.private ;
IN: modern.slices

ERROR: unexpected-eof string n expected ;

: ?1- ( n/f -- n'/f ) dup [ 1 - ] when ;
: ?1+ ( n/f -- n'/f ) dup [ 1 + ] when ;

: ?nth-of ( seq n/f -- elt/f )
    dup [
        2dup swap bounds-check? [ swap nth-unsafe ] [ 2drop f ] if
    ] [
        nip
    ] if ; inline

: >strings ( seq -- str )
    ! [ slice? ] deep-filter
    [ dup slice? [ >string ] when ] deep-map ;

: matching-section-delimiter ( string -- string' )
    dup ":" tail? [
        rest but-last ";" ">" surround
    ] [
        rest ">" append
    ] if ;

: slice-between ( slice1 slice2 -- slice )
    ! ensure-same-underlying
    slice-order-by-from
    [ to>> ]
    [ [ from>> 2dup < [ swap ] unless ] [ seq>> ] bi ] bi* <slice> ;

: slice-before ( slice -- slice' )
    [ drop 0 ] [ from>> ] [ seq>> ] tri <slice> ;

: nth-check-eof ( string n -- nth )
    2dup ?nth-of [ 2nip ] [ f unexpected-eof ] if* ;

! Allow eof
: next-char-from ( string n/f -- string n'/f ch/f )
    dup [ 2dup ?nth-of dup [ [ 1 + ] dip ] when ] [ f ] if ;

: find-from' ( ... seq n quot: ( ... elt -- ... ? ) -- ... i elt )
    swapd find-from ; inline

: find-from* ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt ? )
    [ find-from ] 2keep drop
    pick [ drop t ] [ length -rot nip f ] if ; inline

: find-from*' ( ... seq n quot: ( ... elt -- ... ? ) -- ... i elt ? )
    swapd find-from* ; inline

: slice-until-exclude ( string n quot -- string n' slice/f ch/f )
    over [
        [ drop ]
        [ find-from' ] 3bi ! ( string n n' ch )
        [ drop nip ]
        [ [ rot ?<slice> ] dip ] 4bi
    ] [
        drop f f
    ] if ; inline

: slice-until-include ( string n tokens -- string n' slice/f ch/f )
    over [
        '[ _ member? ]
        [ drop ]
        [ find-from' [ ?1+ ] dip ] 3bi ! ( string n n' ch )
        [ drop nip ]
        [ [ rot ?<slice> ] dip ] 4bi
    ] [
        drop f f
    ] if ; inline

: slice-til-whitespace ( string n -- string n' slice/f ch/f )
    [ "\s\r\n" member? ] slice-until-exclude ; inline

: slice-til-not-whitespace ( string n -- string n' slice/f ch/f )
    [ "\s\r\n" member? not ] slice-until-exclude ; inline

: skip-whitespace ( string n/f -- string n'/f )
    slice-til-not-whitespace 2drop ;

: slice-til-eol ( string n -- string n' slice/f ch/f )
    [ "\r\n" member? ] slice-until-exclude ; inline

: merge-slice-til-whitespace ( string n slice -- string n' slice' )
    over [
        [ slice-til-whitespace drop ] dip merge-slices
    ] when ;

: merge-slice-til-not-whitespace ( string n slice -- string n' slice' )
    over [
        [ slice-til-not-whitespace drop ] dip merge-slices
    ] when ;


! Whitespace is either found immediately, returning a zero-width slice
! OR we find it at the end of a token
:: slice-til-either ( string n tokens -- string n'/f slice/f ch/f )
    n [
        string n [ tokens member? ] find-from'
        dup "\s\r\n" member? [ [ ?1+ ] dip ] unless :> ( n' ch )
        string
        n'
        n n' string ?<slice>
        ch
    ] [
        string f f f
    ] if ; inline

ERROR: subseq-expected-but-got-eof string n expected ;

:: slice-til-string ( string n search -- string n'/f payload end-string )
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

: peek-from ( string n count -- string n slice )
    [ drop ] [ drop ] [ + ] 2tri reach ?<slice> ;