! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables colors
       sorting qualified unicode.collation math.order
       ui ui.gadgets ui.gadgets.panes ui.gadgets.editors
       ui.gadgets.scrollers ui.commands ui.gadgets.frames ui.gestures
       ui.gadgets.tabs ui.gadgets.grids ui.gadgets.packs ui.gadgets.labels
       io io.styles namespaces calendar calendar.format models continuations
       irc.client irc.client.private irc.messages
       irc.ui.commandparser irc.ui.load ;

RENAME: join sequences => sjoin

IN: irc.ui

SYMBOL: listener

SYMBOL: client

TUPLE: ui-window < tabbed client ;

TUPLE: irc-tab < frame listener client window userlist ;

: write-color ( str color -- )
    foreground associate format ;
: dark-red T{ rgba f 0.5 0.0 0.0 1 } ;
: dark-green T{ rgba f 0.0 0.5 0.0 1 } ;

: dot-or-parens ( string -- string )
    dup empty? [ drop "." ]
    [ "(" prepend ")" append ] if ;

GENERIC: write-irc ( irc-message -- )

M: ping write-irc
    drop "* Ping" blue write-color ;

M: privmsg write-irc
    "<" blue write-color
    [ irc-message-sender write ] keep
    "> " blue write-color
    trailing>> write ;

M: notice write-irc
    [ type>> blue write-color ] keep
    ": " blue write-color
    trailing>> write ;

TUPLE: own-message message nick timestamp ;

: <own-message> ( message nick -- own-message )
    now own-message boa ;

M: own-message write-irc
    "<" blue write-color
    [ nick>> bold font-style associate format ] keep
    "> " blue write-color
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

: full-mode ( message -- mode )
    parameters>> rest " " sjoin ;

M: mode write-irc
    "* " blue write-color
    [ irc-message-sender write ] keep
    " has applied mode " blue write-color
    [ full-mode write ] keep
    " to " blue write-color
    channel>> write ;

M: nick write-irc
    "* " blue write-color
    [ irc-message-sender write ] keep
    " is now known as " blue write-color
    trailing>> write ;

M: unhandled write-irc
    "UNHANDLED: " write
    line>> blue write-color ;

M: irc-end write-irc
    drop "* You have left IRC" dark-red write-color ;

M: irc-disconnected write-irc
    drop "* Disconnected" dark-red write-color ;

M: irc-connected write-irc
    drop "* Connected" dark-green write-color ;

M: irc-listener-end write-irc
    drop ;

M: irc-message write-irc
    drop ; ! catch all unimplemented writes, THIS WILL CHANGE    

: time-happened ( irc-message -- timestamp )
    [ timestamp>> ] [ 2drop now ] recover ;

: print-irc ( irc-message -- )
    [ time-happened timestamp>hms write " " write ]
    [ write-irc nl ] bi ;

: send-message ( message -- )
    [ print-irc ]
    [ listener get write-message ] bi ;

GENERIC: handle-inbox ( tab message -- )

: value-labels ( assoc val -- seq )
    '[ nip , = ] assoc-filter keys sort-strings [ <label> ] map ;

: add-gadget-color ( pack seq color -- pack )
    '[ , >>color add-gadget ] each ;

: update-participants ( tab -- )
    [ userlist>> [ clear-gadget ] keep ]
    [ listener>> participants>> ] bi
    [ +operator+ value-labels dark-green add-gadget-color ]
    [ +voice+ value-labels blue add-gadget-color ]
    [ +normal+ value-labels black add-gadget-color ] tri drop ;

M: participant-changed handle-inbox
    drop update-participants ;

M: object handle-inbox
    nip print-irc ;

: display ( stream tab -- )
    '[ , [ [ t ]
           [ , dup listener>> read-message handle-inbox ]
           [  ] while ] with-output-stream ] "ircv" spawn drop ;

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
     '[ , irc-tab set , parse-message ] with-output-stream ;

irc-editor "general" f {
    { T{ key-down f f "RET" } editor-send }
    { T{ key-down f f "ENTER" } editor-send }
} define-command-map

: new-irc-tab ( listener ui-window class -- irc-tab )
    new-frame
    swap >>window
    swap >>listener
    <irc-pane> [ <scroller> @center grid-add ] keep
    <irc-editor> <scroller> @bottom grid-add ;

M: irc-tab graft*
    [ listener>> ] [ window>> client>> ] bi add-listener ;

M: irc-tab ungraft*
    [ listener>> ] [ window>> client>> ] bi remove-listener ;

TUPLE: irc-channel-tab < irc-tab userlist ;

: <irc-channel-tab> ( listener ui-window -- irc-tab )
    irc-tab new-irc-tab
    <pile> [ <scroller> @right grid-add ] keep >>userlist ;

TUPLE: irc-server-tab < irc-tab ;

: <irc-server-tab> ( listener -- irc-tab )
    f irc-server-tab new-irc-tab ;

M: irc-server-tab ungraft*
    [ window>> client>> terminate-irc ]
    [ listener>> ] [ window>> client>> ] tri remove-listener ;

: <irc-nick-tab> ( listener ui-window -- irc-tab )
    irc-tab new-irc-tab ;

M: irc-tab pref-dim*
    drop { 480 480 } ;

: join-channel ( name ui-window -- )
    [ dup <irc-channel-listener> ] dip
    [ <irc-channel-tab> swap ] keep
    add-page ;

: query-nick ( nick ui-window -- )
    [ dup <irc-nick-listener> ] dip
    [ <irc-nick-tab> swap ] keep
    add-page ;

: irc-window ( ui-window -- )
    [ ]
    [ client>> profile>> server>> ] bi
    open-window ;

: ui-connect ( profile -- ui-window )
    <irc-client>
    { [ [ <irc-server-listener> ] dip add-listener ]
      [ listeners>> +server-listener+ swap at <irc-server-tab> dup
        "Server" associate ui-window new-tabbed [ swap (>>window) ] keep ]
      [ >>client ]
      [ connect-irc ] } cleave ;

: server-open ( server port nick password channels -- )
    [ <irc-profile> ui-connect [ irc-window ] keep ] dip
    [ over join-channel ] each drop ;

: main-run ( -- ) run-ircui ;

MAIN: main-run
