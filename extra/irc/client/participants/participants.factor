! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators irc.client.base
irc.client.chats kernel sequences splitting ;
IN: irc.client.participants

TUPLE: participant nick operator voice ;
: <participant> ( name -- participant )
    {
        { [ "@" ?head ] [ t f ] }
        { [ "+" ?head ] [ f t ] }
        [ f f ]
    } cond participant boa ;

GENERIC: has-participant? ( name irc-chat -- ? )
M: irc-chat         has-participant? 2drop f ;
M: irc-channel-chat has-participant? participants>> key? ;

: rename-X ( new old assoc quot: ( obj value -- obj ) -- )
    '[ delete-at* drop swap @ ] [ nip set-at ] 3bi ; inline

: rename-nick-chat ( new old -- ) irc> chats>> [ >>name ] rename-X ;
: rename-participant ( new old chat -- ) participants>> [ >>nick ] rename-X ;
: part-participant ( nick irc-chat -- ) participants>> delete-at ;
: participant-chats ( nick -- seq ) chats> [ has-participant? ] with filter ;

: quit-participant ( nick -- )
    dup participant-chats [ part-participant ] with each ;

: rename-participant* ( new old -- )
    [ dup participant-chats [ rename-participant ] 2with each ]
    [ dup chat> [ rename-nick-chat ] [ 2drop ] if ]
    2bi ;

: join-participant ( nick irc-channel-chat -- )
    participants>> [ <participant> dup nick>> ] dip set-at ;

: apply-mode ( ? participant mode -- )
    {
        { CHAR: o [ operator<< ] }
        { CHAR: v [ voice<< ] }
        [ 3drop ]
    } case ;

: apply-modes ( mode-line participant -- )
    [ unclip CHAR: + = ] dip
    '[ [ _ _ ] dip apply-mode ] each ;

: change-participant-mode ( mode channel nick -- )
    swap chat> participants>> at apply-modes ;

: ?clear-participants ( channel-chat -- )
    dup clear-participants>> [
        f >>clear-participants participants>> clear-assoc
    ] [ drop ] if ;
