! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit continuations fry io.encodings.utf8
io.files kernel locals make math math.order modern.paths
modern.slices namespaces sequences sequences.deep sets
sequences.extras shuffle splitting splitting.monotonic strings
unicode ;
IN: modern

ERROR: string-expected-got-eof n string ;
ERROR: long-opening-mismatch tag open n string ch ;

! (( )) [[ ]] {{ }}
MACRO:: read-double-matched ( open-ch -- quot: ( n string tag ch -- n' string seq ) )
    open-ch dup matching-delimiter {
        [ drop 2 swap <string> ]
        [ drop 1string ]
        [ nip 2 swap <string> ]
    } 2cleave :> ( openstr2 openstr1 closestr2 )
    |[ n string tag! ch |
        ch {
            { char: = [
                tag 1 cut-slice* drop tag! ! tag of (=( is ( here, fix it
                n string openstr1 slice-til-separator-inclusive [ -1 modify-from ] dip :> ( n' string' opening ch )
                ch open-ch = [ tag openstr2 n string ch long-opening-mismatch ] unless
                opening matching-delimiter-string :> needle

                n' string' needle slice-til-string :> ( n'' string'' payload closing )
                n'' string
                tag opening payload closing 4array
            ] }
            { open-ch [
                tag 1 cut-slice* swap tag! 1 modify-to :> opening
                n 1 + string closestr2 slice-til-string :> ( n' string' payload closing )
                n' string
                tag opening payload closing 4array
            ] }
            [ [ tag openstr2 n string ] dip long-opening-mismatch ]
        } case
     ] ;

: read-double-matched-paren ( n string tag ch -- n' string seq ) char: \( read-double-matched ;
: read-double-matched-bracket ( n string tag ch -- n' string seq ) char: \[ read-double-matched ;
: read-double-matched-brace ( n string tag ch -- n' string seq ) char: \{ read-double-matched ;

DEFER: lex-factor-top
DEFER: lex-factor
ERROR: lex-expected-but-got-eof n string expected ;
! For implementing [ { (
: lex-until ( n string tag-sequence -- n' string payload )
    3dup '[
        [
            lex-factor-top dup f like [ , ] when* [
                dup [
                    ! } gets a chance, but then also full seq { } after recursion...
                    [ _ ] dip '[ _ sequence= ] any? not
                ] [
                    drop t ! loop again?
                ] if
            ] [
                _ _ _ lex-expected-but-got-eof
            ] if*
        ] loop
    ] { } make ;

DEFER: section-close?
DEFER: upper-colon?
: lex-colon-until ( n string tag-sequence -- n' string payload )
    '[
        [
            lex-factor-top dup f like [ , ] when* [
                dup [
                    dup { [ section-close? ] [ upper-colon? ] } 1|| [
                        drop f
                    ] [
                        ! } gets a chance, but then also full seq { } after recursion...
                        [ _ ] dip '[ _ sequence= ] any? not
                    ] if
                ] [
                    drop t ! loop again?
                ] if
            ] [
                f
            ] if*
        ] loop
    ] { } make ;

: split-double-dash ( seq -- seqs )
    dup [ { [ "--" sequence= ] } 1&& ] split-when
    dup length 1 > [ nip ] [ drop ] if ;

MACRO:: read-matched ( ch -- quot: ( n string tag -- n' string slice' ) )
    ch dup matching-delimiter {
        [ drop "=" swap prefix ]
        [ nip 1string ]
    } 2cleave :> ( openstreq closestr1 )  ! [= ]
    |[ n string tag |
        n string tag
        2over nth-check-eof {
            { [ dup openstreq member? ] [ ch read-double-matched ] } ! (=( or ((
            { [ dup blank? ] [
                drop dup '[ _ matching-delimiter-string closestr1 2array members lex-until ] dip
                swap unclip-last 3array ] } ! ( foo )
            [ drop [ slice-til-whitespace drop ] dip span-slices ]  ! (foo)
        } cond
    ] ;

: read-bracket ( n string slice -- n' string slice' ) char: \[ read-matched ;
: read-brace ( n string slice -- n' string slice' ) char: \{ read-matched ;
: read-paren ( n string slice -- n' string slice' ) char: \( read-matched ;
: read-string-payload ( n string -- n' string )
    over [
        { char: \\ char: \" } slice-til-separator-inclusive {
            { f [ drop ] }
            { char: \" [ drop ] }
            { char: \\ [ drop next-char-from drop read-string-payload ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

:: read-string ( n string tag -- n' string seq )
    n string read-string-payload drop :> n'
    n' string
    n' [ n string string-expected-got-eof ] unless
    n n' 1 - string <slice>
    n' 1 - n' string <slice>
    tag -rot 3array ;

: take-comment ( n string slice -- n' string comment )
    2over ?nth char: \[ = [
        [ 1 + ] 2dip 2over ?nth read-double-matched-bracket
    ] [
        [ slice-til-eol drop ] dip swap 2array
    ] if ;

: terminator? ( slice -- ? )
    {
        [ ";" sequence= ]
        [ "]" sequence= ]
        [ "}" sequence= ]
        [ ")" sequence= ]
    } 1|| ;

ERROR: expected-length-tokens n string length seq ;
: ensure-no-false ( n string seq -- n string seq )
    dup [ length 0 > ] all? [ [ length ] keep expected-length-tokens ] unless ;

ERROR: token-expected n string obj ;
ERROR: unexpected-terminator n string slice ;
: read-lowercase-colon ( n string slice -- n' string lowercase-colon )
    dup [ char: \: = ] count-tail
    '[
        _ [ lex-factor ] replicate ensure-no-false dup [ token-expected ] unless
        dup terminator? [ unexpected-terminator ] when
    ] dip swap 2array ;

: (strict-upper?) ( string -- ? )
    {
        [
            [
                { [ char: A char: Z between? ] [ ":-\\" member? ] } 1||
            ] all?
        ]
        [ [ char: A char: Z between? ] any? ] ! XXX: what?
    } 1&& ;

: strict-upper? ( string -- ? )
    { [ ":" sequence= ] [ (strict-upper?) ] } 1|| ;

! <a <a: but not <a>
: section-open? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ rest strict-upper? ]
        [ ">" tail? not ]
    } 1&& ;

: upper-colon? ( string -- ? )
    {
        [ length 2 >= ]
        [ ":" tail? ]
        [ dup [ char: : = ] find drop head strict-upper? ]
    } 1&& ;

: section-close? ( string -- ? )
    {
        [ length 2 >= ]
        [ ">" tail? ]
        [
            {
                [ but-last strict-upper? ]
                [ { [ ";" head? ] [ rest but-last strict-upper? ] } 1&& ]
            } 1||
        ]
    } 1&& ;

: read-til-semicolon ( n string slice -- n' string semi )
    dup '[ but-last ";" append ";" 2array { "--" ")" } append lex-colon-until ] dip
    swap
    ! What ended the FOO: .. ; form?
    ! Remove the ; from the payload if present
    ! Also in stack effects ( T: int -- ) can be ended by -- and )
    dup ?last {
        { [ dup ";" tail? ] [ drop unclip-last 3array ] }
        { [ dup "--" tail? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup ")" tail? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup section-close? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup upper-colon? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        [ drop 2array ]
    } cond ;

ERROR: colon-word-must-be-all-uppercase-or-lowercase n string word ;
: read-colon ( n string slice -- n' string colon )
    {
        { [ dup strict-upper? ] [ read-til-semicolon ] }
        { [ dup ":" tail? ] [ dup ":" head? [ read-lowercase-colon ] unless ] } ! :foo: vs foo:
        [ "here for some reason" throw ]
    } cond ;

: read-acute ( n string slice -- n' string acute )
    [ matching-section-delimiter 1array lex-until ] keep swap unclip-last 3array ;

! Words like append! and suffix! are allowed for now.
: read-exclamation ( n string slice -- n' string obj )
    dup { [ "!" sequence= ] [ "#!" sequence= ] } 1||
    [ take-comment ] [ merge-slice-til-whitespace ] if ;

ERROR: no-backslash-payload n string slice ;
: (read-backslash) ( n string slice -- n' string obj )
    merge-slice-til-whitespace dup "\\" tail? [
        ! \ foo, M\ foo
        dup [ char: \\ = ] count-tail
        '[
            _ [ skip-blank-from slice-til-whitespace drop ] replicate
            ensure-no-false
            dup [ no-backslash-payload ] unless
        ] dip swap 2array
    ] when ;

DEFER: lex-factor-top*
: read-backslash ( n string slice -- n' string obj )
    ! foo\ so far, could be foo\bar{
    ! remove the \ and continue til delimiter/eof
    [ "\"!:[{(<>\s\r\n" slice-til-either ] dip swap [ span-slices ] dip
    over "\\" head? [
        drop
        ! \ foo
        dup "\\" sequence= [ (read-backslash) ] [ merge-slice-til-whitespace ] if
    ] [
        ! foo\ or foo\bar (?)
        over "\\" tail? [ drop (read-backslash) ] [ lex-factor-top* ] if
    ] if ;

! If the slice is 0 width, we stopped on whitespace.
! Advance the index and read again!
: read-token-or-whitespace ( n string slice -- n' string slice/f )
    dup length 0 = [ [ 1 + ] 2dip drop lex-factor-top ] when ;

! Inside a FOO: or a <FOO FOO>
: lex-factor-nested ( n/f string slice/f ch/f -- n'/f string literal )
    {
        { char: \\ [ read-backslash ] }
        { char: \[ [ read-bracket ] }
        { char: \{ [ read-brace ] }
        { char: \( [ read-paren ] }
        { char: \] [ ] }
        { char: \} [ ] }
        { char: \) [ ] }
        { char: \s [ read-token-or-whitespace ] }
        { char: \r [ read-token-or-whitespace ] }
        { char: \n [ read-token-or-whitespace ] }
        { char: \" [ read-string ] }
        { char: \! [ read-exclamation ] }
        { char: > [
            [ [ char: > = not ] slice-until ] dip merge-slices
            dup section-close? [
                [ slice-til-whitespace drop ] dip ?span-slices
            ] unless
        ] }
        { f [ ] }
    } case ;

: lex-factor-top* ( n/f string slice/f ch/f -- n'/f string literal )
    {
        { char: \: [ merge-slice-til-whitespace read-colon ] }
        { char: < [
            ! FOO: a b <BAR: ;BAR>
            ! FOO: a b <BAR BAR>
            ! FOO: a b <asdf>
            ! FOO: a b <asdf asdf>

            ! if we are in a FOO: and we hit a <BAR or <BAR:
            ! then end the FOO:
            [ slice-til-whitespace drop ] dip span-slices
            dup section-open? [ read-acute ] when
        ] }
        [ lex-factor-nested ]
    } case ;

: lex-factor-top ( n/f string -- n'/f string literal )
    ! skip-whitespace
    "\"\\!:[{(]})<>\s\r\n" slice-til-either
    lex-factor-top* ; inline

ERROR: compound-syntax-disallowed seq i obj ;
: check-for-compound-syntax ( seq -- seq' )
    dup [ length 1 > ] find
    [ compound-syntax-disallowed ] [ drop ] if* ;

: lex-factor ( n/f string/f -- n'/f string literal/f )
    [
        ! Compound syntax loop
        [
            lex-factor-top
            f like [ , ] when*
            ! concatenated syntax ( a )[ a 1 + ]( b )
            [ ]
            [ peek-from blank? ]
            [ previous-from blank? or not ] 2tri pick and
        ] loop
    ] { } make
    ! check-for-compound-syntax
    ! concat
    f like ;

: string>literals ( string -- sequence )
    [ 0 ] dip [
        [ lex-factor [ , ] when* over ] loop
    ] { } make 2nip ;

: vocab>literals ( vocab -- sequence )
    ".private" ?tail drop
    modern-source-path utf8 file-contents string>literals ;

: path>literals ( path -- sequence )
    utf8 file-contents string>literals ;

: lex-paths ( vocabs -- assoc )
    [ [ path>literals ] [ nip ] recover ] map-zip ;

: lex-vocabs ( vocabs -- assoc )
    [ [ vocab>literals ] [ nip ] recover ] map-zip ;

: failed-lexing ( assoc -- assoc' ) [ nip array? ] assoc-reject ;

: lex-core ( -- assoc ) core-bootstrap-vocabs lex-vocabs ;
: lex-basis ( -- assoc ) basis-vocabs lex-vocabs ;
: lex-extra ( -- assoc ) extra-vocabs lex-vocabs ;
: lex-roots ( -- assoc ) lex-core lex-basis lex-extra 3append ;

: lex-docs ( -- assoc ) all-docs-paths lex-paths ;
: lex-tests ( -- assoc ) all-tests-paths lex-paths ;

: lex-all ( -- assoc )
    lex-roots lex-docs lex-tests 3append ;
