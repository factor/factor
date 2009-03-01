! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables colors
       sorting unicode.collation math.order
       ui ui.gadgets ui.gadgets.panes ui.gadgets.editors
       ui.gadgets.scrollers ui.commands ui.gadgets.frames ui.gestures
       ui.gadgets.tabs ui.gadgets.grids ui.gadgets.packs ui.gadgets.labels
       io io.styles namespaces calendar calendar.format models continuations
       irc.client irc.client.private irc.messages
       irc.ui.commandparser irc.ui.load vocabs.loader classes prettyprint ;

RENAME: join sequences => sjoin

IN: irc.ui

SYMBOL: chat

SYMBOL: client

TUPLE: ui-window < tabbed client ;

M: ui-window ungraft*
    client>> terminate-irc ;

TUPLE: irc-tab < frame chat client window ;

: write-color ( str color -- )
    foreground associate format ;
CONSTANT: dark-red T{ rgba f 0.5 0.0 0.0 1 }
CONSTANT: dark-green T{ rgba f 0.0 0.5 0.0 1 }
CONSTANT: dark-blue T{ rgba f 0.0 0.0 0.5 1 }

: dot-or-parens ( string -- string )
    [ "." ]
    [ "(" prepend ")" append ] if-empty ;

GENERIC: write-irc ( irc-message -- )

M: ping write-irc
    drop "* Ping" blue write-color ;

M: privmsg write-irc
    "<" dark-blue write-color
    [ irc-message-sender write ] keep
    "> " dark-blue write-color
    trailing>> write ;

M: notice write-irc
    [ type>> dark-blue write-color ] keep
    ": " dark-blue write-color
    trailing>> write ;

TUPLE: own-message message nick timestamp ;

: <own-message> ( message nick -- own-message )
    now own-message boa ;

M: own-message write-irc
    "<" dark-blue write-color
    [ nick>> bold font-style associate format ] keep
    "> " dark-blue write-color
    message>> write ;

M: join write-irc
    "* " dark-green write-color
    irc-message-sender write
    " has entered the channel." dark-green write-color ;

M: part write-irc
    "* " dark-red write-color
    [ irc-message-sender write ] keep
    " has left the channel" dark-red write-color
    trailing>> dot-or-parens dark-red write-color ;

M: quit write-irc
    "* " dark-red write-color
    [ irc-message-sender write ] keep
    " has left IRC" dark-red write-color
    trailing>> dot-or-parens dark-red write-color ;

M: kick write-irc
    "* " dark-red write-color
    [ irc-message-sender write ] keep
    " has kicked " dark-red write-color
    [ who>> write ] keep
    " from the channel" dark-red write-color
    trailing>> dot-or-parens dark-red write-color ;

M: mode write-irc
    "* " dark-blue write-color
    [ name>> write ] keep
    " has applied mode " dark-blue write-color
    [ mode>> write ] keep
    " to " dark-blue write-color
    parameter>> write ;

M: nick write-irc
    "* " dark-blue write-color
    [ irc-message-sender write ] keep
    " is now known as " blue write-color
    trailing>> write ;

M: unhandled write-irc
    "UNHANDLED: " write
    line>> dark-blue write-color ;

M: irc-end write-irc
    drop "* You have left IRC" dark-red write-color ;

M: irc-disconnected write-irc
    drop "* Disconnected" dark-red write-color ;

M: irc-connected write-irc
    drop "* Connected" dark-green write-color ;

M: irc-chat-end write-irc
    drop ;

M: irc-message write-irc
    "UNIMPLEMENTED" write
    [ class pprint ] keep
    ": " write
    line>> dark-blue write-color ;

GENERIC: time-happened ( message -- timestamp )

M: irc-message time-happened timestamp>> ;

M: object time-happened drop now ;

: print-irc ( irc-message -- )
    [ time-happened timestamp>hms write " " write ]
    [ write-irc nl ] bi ;

: send-message ( message -- )
    [ print-irc ]
    [ chat get speak ] bi ;

GENERIC: handle-inbox ( tab message -- )

: value-labels ( assoc val -- seq )
    '[ nip _ = ] assoc-filter keys sort-strings [ <label> ] map ;

: add-gadget-color ( pack seq color -- pack )
    '[ _ >>color add-gadget ] each ;

M: object handle-inbox
    nip print-irc ;

: display ( stream tab -- )
    '[ _ [ [ t ]
           [ _ dup chat>> hear handle-inbox ]
           while ] with-output-stream ] "ircv" spawn drop ;

: <irc-pane> ( tab -- tab pane )
    <scrolling-pane>
    [ <pane-stream> swap display ] 2keep ;

TUPLE: irc-editor < editor outstream tab ;

: <irc-editor> ( tab pane -- tab editor )
    irc-editor new-editor
    swap <pane-stream> >>outstream ;

: editor-send ( irc-editor -- )
    { [ outstream>> ]
      [ [ irc-tab? ] find-parent ]
      [ editor-string ]
      [ "" swap set-editor-string ] } cleave
     '[ _ irc-tab set _ parse-message ] with-output-stream ;

irc-editor "general" f {
    { T{ key-down f f "RET" } editor-send }
    { T{ key-down f f "ENTER" } editor-send }
} define-command-map

: new-irc-tab ( chat ui-window class -- irc-tab )
    new-frame
    swap >>window
    swap >>chat
    <irc-pane> [ <scroller> @center grid-add ] keep
    <irc-editor> <scroller> @bottom grid-add ;

M: irc-tab graft*
    [ chat>> ] [ window>> client>> ] bi attach-chat ;

M: irc-tab ungraft*
    chat>> detach-chat ;

TUPLE: irc-channel-tab < irc-tab userlist ;

: <irc-channel-tab> ( chat ui-window -- irc-tab )
    irc-channel-tab new-irc-tab
    <pile> [ <scroller> @right grid-add ] keep >>userlist ;

: update-participants ( tab -- )
    [ userlist>> [ clear-gadget ] keep ]
    [ chat>> participants>> ] bi
    [ +operator+ value-labels dark-green add-gadget-color ]
    [ +voice+ value-labels blue add-gadget-color ]
    [ +normal+ value-labels black add-gadget-color ] tri drop ;

M: participant-changed handle-inbox
    drop update-participants ;

TUPLE: irc-server-tab < irc-tab ;

: <irc-server-tab> ( chat -- irc-tab )
    f irc-server-tab new-irc-tab ;

: <irc-nick-tab> ( chat ui-window -- irc-tab )
    irc-tab new-irc-tab ;

M: irc-tab pref-dim*
    drop { 480 480 } ;

: join-channel ( name ui-window -- )
    [ dup <irc-channel-chat> ] dip
    [ <irc-channel-tab> swap ] keep
    add-page ;

: query-nick ( nick ui-window -- )
    [ dup <irc-nick-chat> ] dip
    [ <irc-nick-tab> swap ] keep
    add-page ;

: irc-window ( ui-window -- )
    [ ]
    [ client>> profile>> server>> ] bi
    open-window ;

: ui-connect ( profile -- ui-window )
    <irc-client>
    { [ [ <irc-server-chat> ] dip attach-chat ]
      [ chats>> +server-chat+ swap at <irc-server-tab> dup
        "Server" associate ui-window new-tabbed [ swap (>>window) ] keep ]
      [ >>client ]
      [ connect-irc ] } cleave ;

: server-open ( server port nick password channels -- )
    [ <irc-profile> ui-connect [ irc-window ] keep ] dip
    [ over join-channel ] each drop ;

: main-run ( -- ) run-ircui ;

MAIN: main-run

"irc.ui.commands" require
