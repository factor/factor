! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.short-circuit
constructors continuations io.encodings.utf8 io.files kernel
make math math.order modern.lexer modern.paths modern.slices
sequences sequences.extras sequences.generalizations sets
shuffle splitting strings syntax.modern unicode vocabs.loader ;
IN: modern

ERROR: long-opening-mismatch tag open string n ch ;
ERROR: unexpected-terminator string n slice ; ! ] } ) ;
ERROR: compound-syntax-disallowed seq n obj ;

! (( )) [[ ]] {{ }}
MACRO:: read-double-matched ( open-ch -- quot: ( string n tag ch -- string n' seq ) )
    2 open-ch <string>
    open-ch 1string
    2 open-ch matching-delimiter <string>
    :> ( openstr2 openstr1 closestr2 ) ! "[[" "[" "]]"
    |[ string n tag! ch |
        ch {
            { char: = [
                tag 1 cut-slice* drop tag! ! tag of (=( is ( here, fix it
                string n openstr1 slice-until-include [ -1 modify-from ] dip :> ( string' n' opening ch )
                ch open-ch = [ tag openstr2 string n ch long-opening-mismatch ] unless
                opening matching-delimiter-string :> needle

                string' n' needle slice-til-string :> ( string'' n'' payload closing )
                string n''
                tag opening payload closing 4array
            ] }
            { open-ch [
                tag 1 cut-slice* swap tag! 1 modify-to :> opening
                string n 1 + closestr2 slice-til-string :> ( string' n' payload closing )
                string n'
                tag opening payload closing 4array
            ] }
            [ [ tag openstr2 string n ] dip long-opening-mismatch ]
        } case
     ] ;

: read-double-matched-bracket ( string n tag ch -- string n' seq ) char: \[ read-double-matched ;
! : read-double-matched-paren ( string n tag ch -- string n' seq ) char: \( read-double-matched ;
! : read-double-matched-brace ( string n tag ch -- string n' seq ) char: \{ read-double-matched ;

DEFER: lex-factor-top
DEFER: lex-factor
! For implementing [ { (
: lex-until ( string n tag-sequence -- string n' payload )
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
                _ _ _ unexpected-eof
            ] if*
        ] loop
    ] { } make ;

DEFER: section-close?
DEFER: upper-colon?
DEFER: lex-factor-nested
: lex-colon-until ( string n tag-sequence -- string n' payload )
    '[
        [
            lex-factor-nested dup f like [ , ] when* [
                dup [
                    ! This is for ending COLON: forms like ``A: PRIVATE>``
                    dup section-close? [
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

MACRO:: read-matched ( ch -- quot: ( string n tag -- string n' slice' ) )
    ch dup matching-delimiter {
        [ drop "=" swap prefix ]
        [ nip 1string ]
    } 2cleave :> ( openstreq closestr1 ) ! [= ]
    |[ string n tag |
        string n tag
        2over nth-check-eof {
            { [ dup openstreq member? ] [ ch read-double-matched ] } ! (=( or ((
            { [ dup blank? ] [
                drop dup '[ _ matching-delimiter-string closestr1 2array members lex-until ] dip
                swap unclip-last 3array
            ] } ! ( foo )
            [ drop [ slice-til-whitespace drop ] dip span-slices ] ! (foo)
        } cond
    ] ;

: read-bracket ( string n slice -- string n' slice' ) char: \[ read-matched ;
: read-brace ( string n slice -- string n' slice' ) char: \{ read-matched ;
: read-paren ( string n slice -- string n' slice' ) char: \( read-matched ;
: read-string-payload ( string n -- string n' )
    dup [
        { char: \\ char: \" } slice-until-include {
            { f [ drop ] }
            { char: \" [ drop ] }
            { char: \\ [ drop next-char-from drop read-string-payload ] }
        } case
    ] [
        f unexpected-eof
    ] if ;

:: read-string ( string n tag -- string n' seq )
    string n read-string-payload nip :> n'
    string
    n'
    n' [ string n f unexpected-eof ] unless
    n n' 1 - string <slice>
    n' 1 - n' string <slice>
    tag -rot 3array ;

: take-comment ( string n slice -- string n' comment )
    2over ?nth-of char: \[ = [
        [ 1 + ] dip 1 modify-to 2over ?nth-of read-double-matched-bracket
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

: ensure-tokens ( string n seq -- string n seq )
    dup [ terminator? ] any? [ unexpected-terminator ] when ;

: read-lowercase-colon ( string n slice -- string n' lowercase-colon )
    dup [ char: \: = ] count-tail
    '[
        _ [
            slice-til-not-whitespace drop <ws> ! XXX: whitespace here
            [ dup [ f unexpected-eof ] unless ] dip
            [ lex-factor ] dip swap 2array
        ] replicate
        ensure-tokens
    ] dip swap 2array ;

: (strict-upper?) ( string -- ? )
    {
        ! All chars must...
        [
            [
                { [ char: A char: Z between? ] [ "':-\\#" member? ] } 1||
            ] all?
        ]
        ! At least one char must...
        [ [ { [ char: A char: Z between? ] [ char: \' = ] } 1|| ] any? ]
    } 1&& ;

: strict-upper? ( string -- ? )
    { [ ":" sequence= ] [ (strict-upper?) ] } 1|| ;

! <A <A: but not <A>
: section-open? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ rest strict-upper? ]
        [ ">" tail? not ]
    } 1&& ;

: html-self-close? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ rest strict-upper? not ]
        [ [ blank? ] any? not ]
        [ "/>" tail? ]
    } 1&& ;

: html-full-open? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ second char: / = not ]
        [ rest strict-upper? not ]
        [ [ blank? ] any? not ]
        [ ">" tail? ]
    } 1&& ;

: html-half-open? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ second char: / = not ]
        [ rest strict-upper? not ]
        [ [ blank? ] any? not ]
        [ ">" tail? not ]
    } 1&& ;

: html-close? ( string -- ? )
    {
        [ "</" head? ]
        [ length 2 >= ]
        [ rest strict-upper? not ]
        [ [ blank? ] any? not ]
        [ ">" tail? ]
    } 1&& ;

: special-acute? ( string -- ? )
    {
        [ section-open? ]
        [ html-self-close? ]
        [ html-full-open? ]
        [ html-half-open? ]
        [ html-close? ]
    } 1|| ;

: upper-colon? ( string -- ? )
    dup { [ length 0 > ] [ [ char: \: = ] all? ] } 1&& [
        drop t
    ] [
        {
            [ length 2 >= ]
            [ "\\" head? not ] ! XXX: good?
            [ ":" tail? ]
            [ dup [ char: \: = ] find drop head strict-upper? ]
        } 1&&
    ] if ;

: section-close? ( string -- ? )
    {
        [ length 2 >= ]
        [ "\\" head? not ] ! XXX: good?
        [ ">" tail? ]
        [
            {
                [ but-last strict-upper? ]
                [ { [ ";" head? ] [ rest but-last strict-upper? ] } 1&& ]
            } 1||
        ]
    } 1&& ;

: read-til-semicolon ( string n slice -- string n' semi )
    [ but-last ";" append ";" "--" ")" 4array lex-colon-until ] keep
    swap
    ! What ended the FOO: .. ; form?
    ! Remove the ; from the payload if present
    ! XXX: probably can remove this, T: is dumb
    ! Also in stack effects ( T: int -- ) can be ended by -- and )
    dup ?last {
        { [ dup ";" sequence= ] [ drop unclip-last 3array ] }
        { [ dup ";" tail? ] [ drop unclip-last 3array ] }
        { [ dup "--" sequence= ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup "]" sequence= ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup "}" sequence= ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup ")" sequence= ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] } ! (n*quot) breaks
        { [ dup section-close? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        { [ dup upper-colon? ] [ drop unclip-last -rot 2array [ rewind-slice ] dip ] }
        [ drop 2array ]
    } cond ;

: read-colon ( string n slice -- string n' colon )
    {
        { [ dup strict-upper? ] [ read-til-semicolon ] }
        { [ dup ":" tail? ] [ dup ":" head? [ read-lowercase-colon ] unless ] } ! :foo: vs foo:
        [ ]
    } cond ;

: read-acute-html ( string n slice -- string n' acute )
    {
        ! <FOO <FOO:
        { [ dup section-open? ] [
            [
                matching-section-delimiter 1array lex-until
            ] keep swap unclip-last 3array
        ] }
        ! <foo/>
        { [ dup html-self-close? ] [
            ! do nothing special
        ] }
        ! <foo>
        { [ dup html-full-open? ] [
            dup [
                rest-slice
                dup ">" tail? [ but-last-slice ] when
                "</" ">" surround 1array lex-until unclip-last
            ] dip -rot 3array
        ] }
        ! <foo
        { [ dup html-half-open? ] [
            ! n seq slice
            [ { ">" "/>" } lex-until ] dip
            ! n seq slice2 slice
            over ">" sequence= [
                "</" ">" surround array '[ _ lex-until ] dip unclip-last
                -rot roll unclip-last [ 3array ] 2dip 3array
            ] [
                ! self-contained
                swap unclip-last 3array
            ] if
        ] }
        ! </foo>
        { [ dup html-close? ] [
            ! Do nothing
        ] }
        [ [ slice-til-whitespace drop ] dip span-slices ]
    } cond ;

: read-acute ( string n slice -- string n' acute )
    [ matching-section-delimiter 1array lex-until ] keep swap unclip-last 3array ;

! Words like append! and suffix! are allowed for now.
: read-exclamation ( string n slice -- string n' obj )
    dup { [ "!" sequence= ] [ "#!" sequence= ] } 1||
    [ take-comment ] [ merge-slice-til-whitespace ] if ;

! \ foo    ! push the word, don't call it
! \\ foo bar  ! push two words
! \        ! error, expects another token
! \\       ! error, expects two tokens
! \ \abc{  ! push the abc{ word
! \ abc{ } ! push the ``abc{ }`` form for running later
: (read-backslash) ( string n slice -- string n' obj )
    merge-slice-til-whitespace dup "\\" tail? [
        ! \ foo, M\ foo
        dup [ char: \\ = ] count-tail
        '[
            _ [
                slice-til-not-whitespace drop
                [ <ws> ] [ "escaped string" unexpected-eof ] if*
                [ lex-factor ] dip
                swap 2array
            ] replicate
            ensure-tokens
        ] dip swap 2array
    ] when ;

DEFER: lex-factor-top*
: read-backslash ( string n slice -- string n' obj )
    ! foo\ so far, could be foo\bar{
    ! remove the \ and continue til delimiter/eof
    [ "\"!:[{(<>\s\r\n" slice-til-either ] dip swap [ span-slices ] dip
    over "\\" head? [
        drop
        ! \\  ! done, \ turns parsing off, \\ is complete token
        ! \ foo
        dup "\\" sequence= [ (read-backslash) ] [ merge-slice-til-whitespace ] if
    ] [
        ! foo\ or foo\bar (?)
        over "\\" tail? [ drop (read-backslash) ] [ lex-factor-top* ] if
    ] if ;

! If the slice is 0 width, we stopped on whitespace before any token.
! Return it to the main loop as a ws form.
: read-token-or-whitespace ( string n slice -- string n' slice/f )
    dup length 0 = [
        merge-slice-til-not-whitespace <ws>
    ] when ;

: lex-factor-fallthrough ( string n/f slice/f ch/f -- string n'/f literal )
    {
        { char: \\ [ read-backslash ] }
        { char: \[ [ read-bracket ] }
        { char: \{ [ read-brace ] }
        { char: \( [ read-paren ] }
        { char: \] [ ] }
        { char: \} [ ] }
        { char: \) [ ] }
        { char: \" [ read-string ] }
        { char: \! [ read-exclamation ] }
        { char: > [
            [ [ char: > = not ] slice-until-exclude drop ] dip merge-slices
            dup section-close? [
                [ slice-til-whitespace drop ] dip ?span-slices
            ] unless
        ] }
        { f [ ] }
    } case ;

! Inside a FOO: or a <FOO FOO>
: lex-factor-nested* ( n/f string slice/f ch/f -- n'/f string literal )
    {
        ! Nested ``A: a B: b`` so rewind and let the parser get it top-level
        { char: \: [
            ! A: B: then interrupt the current parser
            ! A: b: then keep going
            merge-slice-til-whitespace
            dup { [ upper-colon? ] [ ":" = ] } 1||
            ! dup upper-colon?
            [ rewind-slice f ]
            [ read-colon ] if
        ] }
        { char: < [
            ! FOO: a b <BAR: ;BAR>
            ! FOO: a b <BAR BAR>
            ! FOO: a b <asdf>
            ! FOO: a b <asdf asdf>

            ! if we are in a FOO: and we hit a <BAR or <BAR:
            ! then end the FOO:
            ! Don't rewind for a <foo/> or <foo></foo>
            [ slice-til-whitespace drop ] dip span-slices
            dup section-open? [ rewind-slice f ] when
        ] }

        ! Two cases: zero width slice if we found whitespace token, otherwise text token
        { char: \s [ read-token-or-whitespace ] }
        { char: \r [ read-token-or-whitespace ] }
        { char: \n [ read-token-or-whitespace ] }
        [ lex-factor-fallthrough ]
    } case ;

: lex-factor-nested ( n/f string -- n'/f string literal )
    "\"\\!:[{(]})<>\s\r\n" slice-til-either lex-factor-nested* ; inline

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
            ! read-acute-html
            dup section-open? [ read-acute ] when
        ] }

        ! Two cases: zero width slice if we found whitespace token, otherwise text token
        { char: \s [ read-token-or-whitespace ] }
        { char: \r [ read-token-or-whitespace ] }
        { char: \n [ read-token-or-whitespace ] }
        [ lex-factor-fallthrough ]
    } case ;

: lex-factor-top ( string/f n/f -- string/f n'/f literal )
    "\"\\!:[{(]})<>\s\r\n" slice-til-either lex-factor-top* ; inline

: check-for-compound-syntax ( seq n/f obj -- seq n/f obj )
    dup length 1 > [ compound-syntax-disallowed ] when ;

: check-compound-loop ( string/f n/f -- string/f n/f ? )
    [ ] [ ?nth-of ] [ ?1- ?nth-of ] 2tri
    [ blank? ] bi@ or not ! no blanks between tokens
    over and ; ! and a valid index

: lex-factor ( string/f n/f -- string n'/f literal/f )
    [
        ! Compound syntax loop
        [
            lex-factor-top f like [ , ] when*
            ! concatenated syntax ( a )[ a 1 + ]( b )
            check-compound-loop
        ] loop
    ] { } make
    check-for-compound-syntax
    ! concat ! "ALIAS: n*quot (n*quot)" string>literals ... breaks here
    ?first f like ;

: string>literals ( string -- sequence )
    [
        0 [ lex-factor [ , ] when* dup ] loop
    ] { } make 2nip ;

: vocab>literals ( vocab -- sequence )
    ".private" ?tail drop
    vocab-source-path utf8 file-contents string>literals ;

: path>literals ( path -- sequence )
    utf8 file-contents string>literals ;



: lex-paths ( vocabs -- assoc )
    [ [ path>literals ] [ nip ] recover ] map-zip ;

: lex-vocabs ( vocabs -- assoc )
    [ [ vocab>literals ] [ nip ] recover ] map-zip ;

: failed-lexing ( assoc -- assoc' ) [ nip array? ] assoc-reject ;

: lex-core ( -- assoc ) core-vocabs lex-vocabs ;
: lex-basis ( -- assoc ) basis-vocabs lex-vocabs ;
: lex-extra ( -- assoc ) extra-vocabs lex-vocabs ;
: lex-roots ( -- assoc ) lex-core lex-basis lex-extra 3append ;

: lex-docs ( -- assoc ) all-docs-paths lex-paths ;
: lex-tests ( -- assoc ) all-tests-paths lex-paths ;

: lex-all ( -- assoc )
    lex-roots lex-docs lex-tests 3append ;
