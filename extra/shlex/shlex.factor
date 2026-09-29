USING: arrays ascii combinators combinators.short-circuit kernel
locals math sequences splitting strings vectors ;
IN: shlex

ERROR: shlex-unclosed-quote quote ;
ERROR: shlex-missing-escape ;

! Like Python's shlex.split(s, comments=False, posix=True).
:: shlex-split ( string comments? posix? -- tokens )
    V{ } clone :> tokens
    V{ } clone :> token!
    f :> started?!
    f :> quote!
    f :> escaped?!
    f :> comment?!
    [
        started? [
            token >string tokens push
            V{ } clone token!
            f started?!
        ] when
    ] :> finish-token
    string [| ch |
        {
            { [ comment? ] [
                ch CHAR: \n = [ f comment?! ] when
            ] }
            { [ escaped? ] [
                quote [
                    ch quote = ch CHAR: \\ = or
                    [ CHAR: \\ token push ] unless
                ] when
                ch token push
                f escaped?!
            ] }
            { [ quote ] [
                ch quote = [
                    posix? [
                        ch token push
                        finish-token call
                    ] unless
                    f quote!
                ] [
                    posix? quote CHAR: " = and ch CHAR: \\ = and
                    [ t escaped?! ] [ ch token push ] if
                ] if
            ] }
            { [ comments? ch CHAR: # = and ] [
                t comment?!
                posix? [ finish-token call ] when
            ] }
            { [ ch blank? ] [ finish-token call ] }
            { [ posix? ch CHAR: \\ = and ] [
                t started?! t escaped?!
            ] }
            { [ ch "'\"" member? posix? started? not or and ] [
                ch quote!
                t started?!
                posix? [ ch token push ] unless
            ] }
            [ ch token push t started?! ]
        } cond
    ] each
    escaped? [ shlex-missing-escape ] when
    quote [ quote shlex-unclosed-quote ] when
    finish-token call
    tokens >array ;

: parse-shlex ( string -- tokens ) f t shlex-split ;

<PRIVATE

: shlex-safe? ( ch -- ? )
    { [ alpha? ] [ "_@%+=:,./-" member? ] } 1|| ;

PRIVATE>

: shlex-quote ( string -- quoted )
    [ "''" ] [
        dup [ shlex-safe? ] all? [
            "'" "'\"'\"'" replace "'" dup surround
        ] unless
    ] if-empty ;

: shlex-join ( tokens -- string )
    [ shlex-quote ] map " " join ;
