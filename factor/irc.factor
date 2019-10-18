: safe-word? ( word -- ? ) [ + - * / >realnum v+ v- v* v. v/ gcd
and mag2 max min neg not pow pred succ or recip rem round sq
sqrt deg2rad rad2deg fib fac harmonic . print car cdr cons
rplaca rplacd 2list 3list 2rlist append add assoc clone-list
contains count get last* last length list? nappend partition
reverse sort num-sort str-sort swons tree-contains uncons unique
unit unswons 2^ $ describe drop 2drop 2dup dupd dup nip 2nip nop
over 2over pick rot 2rot -rot 2-rot swap 2swap swapd 2swapd
transp 2transp tuck 2tuck ] contains ;

: safe? ( code -- ? )
    t swap [
        dup word? [
            safe-word? and
        ] [
            drop
        ] ifte
    ] each ;

: safe-call ( quot -- )
    dup safe? [
        call
    ] [
        "Contains prohibited words" print
    ] ifte ;

: safe-eval ( str -- )
    parse safe-call ;

: irc-register ( -- )
    "USER " write
    $user write " " write
    $host write " " write
    $server write " " write
    $realname write " " print

    "NICK " write
    $nick print ;

: irc-join ( channel -- )
    "JOIN " write print ;

: irc-message ( message recepients -- )
    "PRIVMSG " write write " :" write print ;

: irc-action ( message recepients -- )
    "ACTION " write write " :" write print ;

: keep-datastack ( quot -- )
    datastack$ [ call ] dip datastack@ drop ;

: <irc-stream> ( stream recepient -- stream )
    <stream> [
        @recepient
        @stdio
        <sbuf> @buf
        [
            dup $buf sbuf-append drop
            ends-with-newline? [
                $buf >str
                <sbuf> @buf
                "\n" split [ $recepient irc-message ] each
            ] when
        ] @fwrite
    ] extend ;

: irc-eval ( line -- )
    [ safe-eval ] keep-datastack drop ;

: irc-fact+ ( key value -- )
    $facts [ s@ ] bind ;

: irc-fact- ( key -- )
    $facts [ f s@ ] bind ;

: irc-fact ( key -- )
    dup $facts [ $ ] bind dup [
        swap write " is " write print
    ] [
        2drop
    ] ifte ;

: irc-facts ( -- )
    $facts [ vars-values ] bind [ cdr ] subset . ;

: groups/t ( string re -- groups )
    dup t = [
        nip
    ] [
        groups
    ] ifte ;

: with-irc-stream ( recepient quot -- )
    <namespace> [
        [ $stdio swap <irc-stream> @stdio ] dip
        call
    ] bind ;

: irc-handle-privmsg ( [ recepient message ] -- )
    uncons car swap
    [
        [
            ! These two are disabled for now.
            [ "eval (.+)"      , [ car irc-eval         ] ]
            ! [ "join (.+)"      , [ car irc-join         ] ]
            [ "see (.+)"       , [ car see terpri       ] ]
            [ "(facts)"        , [ drop irc-facts       ] ]
            [ "(.+?) is (.+)" , [ uncons car irc-fact+ ] ]
            [ "forget (.+)"  , [ car irc-fact-        ] ]
            [ "insult (.+)"    , [ car " sucks" cat2 print ] ]
            [ "(.+)"         , [ car irc-fact         ] ]
            [ t                , [ drop                 ] ]
        ] re-cond
    ] with-irc-stream ;

: irc-handle-join ( [ joined channel ] -- )
    uncons car
    [
        dup $nick = [
            "Hi " swap cat2 print
        ] unless
    ] with-irc-stream ;

: irc-input ( line -- )
    #! Handle a line of IRC input.
    dup
    ":.+?!.+? PRIVMSG (.+)?:(.+)" groups [
        irc-handle-privmsg
    ] when*
    dup ":(.+)!.+ JOIN :(.+)" groups [
        irc-handle-join
    ] when*

    global [ print ] bind ;

: irc-loop ( -- )
    read [ irc-input irc-loop ] when* ;

: irc ( channels -- )
    irc-register
    dup [ irc-join ] each
    [ "Hello everybody" swap irc-message ] each
    irc-loop ;

: irc-test
    "factorbot" @user
    "emu" @host
    "irc.freenode.net" @server
    "Factor" @realname
    "factorbot" @nick
    <namespace> @facts
    "irc.freenode.net" 6667 <client>
    <namespace> [ @stdio [ "#jedit" ] irc ] bind ;

!! "factor/irc.factor" run-file
