! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables colors
       ui ui.gadgets ui.gadgets.panes ui.gadgets.editors
       ui.gadgets.scrollers ui.commands ui.gadgets.frames ui.gestures
       ui.gadgets.tabs ui.gadgets.grids ui.gadgets.packs ui.gadgets.labels
       io io.styles namespaces calendar calendar.format models continuations
       irc.client irc.client.private irc.messages irc.messages.private
       irc.ui.commandparser irc.ui.load qualified ;

RENAME: join sequences => sjoin

IN: irc.ui

SYMBOL: listener

SYMBOL: client

TUPLE: ui-window client tabs ;

TUPLE: irc-tab < frame listener client userlist ;

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
    [ prefix>> parse-name write ] keep
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
    prefix>> parse-name write
    " has entered the channel." dark-green write-color ;

M: part write-irc
    "* " dark-red write-color
    [ prefix>> parse-name write ] keep
    " has left the channel" dark-red write-color
    trailing>> dot-or-parens dark-red write-color ;

M: quit write-irc
    "* " dark-red write-color
    [ prefix>> parse-name write ] keep
    " has left IRC" dark-red write-color
    trailing>> dot-or-parens dark-red write-color ;

: full-mode ( message -- mode )
    parameters>> rest " " sjoin ;

M: mode write-irc
    "* " blue write-color
    [ prefix>> parse-name write ] keep
    " has applied mode " blue write-color
    [ full-mode write ] keep
    " to " blue write-color
    channel>> write ;

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

: filter-participants ( pack alist val color -- pack )
   '[ , = [ <label> , >>color add-gadget ] [ drop ] if ] assoc-each ;

: update-participants ( tab -- )
    [ userlist>> [ clear-gadget ] keep ]
    [ listener>> participants>> ] bi
    [ +operator+ dark-green filter-participants ]
    [ +voice+ blue filter-participants ]
    [ +normal+ black filter-participants ] tri drop ;

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

TUPLE: irc-editor < editor outstream listener client ;

: <irc-editor> ( tab pane -- tab editor )
    over irc-editor new-editor
    swap listener>> >>listener swap <pane-stream> >>outstream
    over client>> >>client ;

: editor-send ( irc-editor -- )
    { [ outstream>> ]
      [ listener>> ]
      [ client>> ]
      [ editor-string ]
      [ "" swap set-editor-string ] } cleave
     '[ , listener set , client set , parse-message ] with-output-stream ;

irc-editor "general" f {
    { T{ key-down f f "RET" } editor-send }
    { T{ key-down f f "ENTER" } editor-send }
} define-command-map

: <irc-tab> ( listener client -- irc-tab )
    irc-tab new-frame
    swap client>> >>client swap >>listener
    <irc-pane> [ <scroller> @center grid-add ] keep
    <irc-editor> <scroller> @bottom grid-add ;

: <irc-channel-tab> ( listener client -- irc-tab )
    <irc-tab>
    <pile> [ <scroller> @right grid-add ] keep >>userlist ;

: <irc-server-tab> ( listener client -- irc-tab )
    <irc-tab> ;

M: irc-tab graft*
    [ listener>> ] [ client>> ] bi add-listener ;

M: irc-tab ungraft*
    [ listener>> ] [ client>> ] bi remove-listener ;

M: irc-tab pref-dim*
    drop { 480 480 } ;

: join-channel ( name ui-window -- )
    [ dup <irc-channel-listener> ] dip
    [ <irc-channel-tab> swap ] keep
    tabs>> add-page ;

: irc-window ( ui-window -- )
    [ tabs>> ]
    [ client>> profile>> server>> ] bi
    open-window ;

: ui-connect ( profile -- ui-window )
    <irc-client> ui-window new over >>client swap
    [ connect-irc ]
    [ [ <irc-server-listener> ] dip add-listener ]
    [ listeners>> +server-listener+ swap at over <irc-tab>
      "Server" associate <tabbed> >>tabs ] tri ;

: server-open ( server port nick password channels -- )
    [ <irc-profile> ui-connect [ irc-window ] keep ] dip
    [ over join-channel ] each drop ;

: main-run ( -- ) run-ircui ;

MAIN: main-run
