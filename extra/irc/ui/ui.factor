! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables
       ui ui.gadgets.panes ui.gadgets.editors ui.gadgets.scrollers
       ui.commands ui.gadgets.frames ui.gestures ui.gadgets.tabs
       io io.styles namespaces irc.client irc.messages ;

IN: irc.ui

SYMBOL: client

TUPLE: ui-window client tabs ;

: write-color ( str color -- )
    foreground associate format ;
: red { 0.5 0 0 1 } ;
: green { 0 0.5 0 1 } ;
: blue { 0 0 1 1 } ;

: prefix>nick ( prefix -- nick )
    "!" split first ;

GENERIC: write-irc ( irc-message -- )

M: privmsg write-irc
    "<" blue write-color
    [ prefix>> prefix>nick write ] keep
    ">" blue write-color
    " " write
    trailing>> write ;

M: join write-irc
    "* " green write-color
    prefix>> prefix>nick write
    " has entered the channel." green write-color ;

M: part write-irc
    "* " red write-color
    [ prefix>> prefix>nick write ] keep
    " has left the channel(" red write-color
    trailing>> write
    ")" red write-color ;

M: quit write-irc
    "* " red write-color
    [ prefix>> prefix>nick write ] keep
    " has left IRC(" red write-color
    trailing>> write
    ")" red write-color ;

M: irc-end write-irc
    drop "* You have left IRC" red write-color ;

M: irc-disconnected write-irc
    drop "* Disconnected" red write-color ;

M: irc-connected write-irc
    drop "* Connected" green write-color ;

M: irc-message write-irc
    drop ; ! catch all unimplemented writes, THIS WILL CHANGE    

: print-irc ( irc-message -- )
    write-irc nl ;

: send-message ( message listener client -- )
    "<" blue write-color
    profile>> nickname>> bold font-style associate format
    ">" blue write-color
    " " write
    over write nl
    out-messages>> mailbox-put ;

: display ( stream listener -- )
    '[ , [ [ t ]
           [ , read-message print-irc ]
           [  ] while ] with-output-stream ] "ircv" spawn drop ;

: <irc-pane> ( listener -- pane )
    <scrolling-pane>
    [ <pane-stream> swap display ] keep ;

TUPLE: irc-editor outstream listener client ;

: <irc-editor> ( pane listener client -- editor )
    [ <editor> irc-editor construct-editor
    swap >>listener swap <pane-stream> >>outstream
    ] dip client>> >>client ;

: editor-send ( irc-editor -- )
    { [ outstream>> ]
      [ editor-string ]
      [ listener>> ]
      [ client>> ]
      [ "" swap set-editor-string ] } cleave
    '[ , , , send-message ] with-output-stream ;

irc-editor "general" f {
    { T{ key-down f f "RET" } editor-send }
    { T{ key-down f f "ENTER" } editor-send }
} define-command-map

: irc-page ( name pane editor tabbed -- )
    [ [ <scroller> @bottom frame, ! editor
        <scroller> @center frame, ! pane
      ] make-frame swap ] dip add-page ;

: join-channel ( name ui-window -- )
    [ dup <irc-channel-listener> ] dip
    [ client>> add-listener ]
    [ drop <irc-pane> dup ]
    [ [ <irc-editor> ] keep ] 2tri
    tabs>> irc-page ;

: irc-window ( ui-window -- )
    [ tabs>> ]
    [ client>> profile>> server>> ] bi
    open-window ;

: ui-connect ( profile -- ui-window )
    <irc-client> ui-window new over >>client swap
    [ connect-irc ]
    [ listeners>> +server-listener+ swap at <irc-pane> <scroller>
      "Server" associate <tabbed> >>tabs ] bi ;

: freenode-connect ( -- ui-window )
    "irc.freenode.org" 8001 "factor-irc" f
    <irc-profile> ui-connect [ irc-window ] keep ;
