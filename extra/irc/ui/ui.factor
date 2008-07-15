! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables
       ui ui.gadgets ui.gadgets.panes ui.gadgets.editors
       ui.gadgets.scrollers ui.commands ui.gadgets.frames ui.gestures
       ui.gadgets.tabs ui.gadgets.grids
       io io.styles namespaces irc.client irc.client.private
       irc.messages irc.messages.private irc.ui.commandparser
       calendar calendar.format ;

IN: irc.ui

SYMBOL: listener

SYMBOL: client

TUPLE: ui-window client tabs ;

: write-color ( str color -- )
    foreground associate format ;
: red { 0.5 0 0 1 } ;
: green { 0 0.5 0 1 } ;
: blue { 0 0 1 1 } ;

: dot-or-parens ( string -- string )
    dup empty? [ drop "." ]
    [ "(" prepend ")" append ] if ;

GENERIC: write-irc ( irc-message -- )

M: privmsg write-irc
    "<" blue write-color
    [ prefix>> parse-name write ] keep
    "> " blue write-color
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
    "* " green write-color
    prefix>> parse-name write
    " has entered the channel." green write-color ;

M: part write-irc
    "* " red write-color
    [ prefix>> parse-name write ] keep
    " has left the channel" red write-color
    trailing>> dot-or-parens red write-color ;

M: quit write-irc
    "* " red write-color
    [ prefix>> parse-name write ] keep
    " has left IRC" red write-color
    trailing>> dot-or-parens red write-color ;

M: irc-end write-irc
    drop "* You have left IRC" red write-color ;

M: irc-disconnected write-irc
    drop "* Disconnected" red write-color ;

M: irc-connected write-irc
    drop "* Connected" green write-color ;

M: irc-message write-irc
    drop ; ! catch all unimplemented writes, THIS WILL CHANGE    

: print-irc ( irc-message -- )
    [ timestamp>> timestamp>hms write " " write ]
    [ write-irc nl ] bi ;

: send-message ( message -- )
    [ print-irc ]
    [ listener get write-message ] bi ;

: display ( stream listener -- )
    '[ , [ [ t ]
           [ , read-message print-irc ]
           [  ] while ] with-output-stream ] "ircv" spawn drop ;

: <irc-pane> ( listener -- pane )
    <scrolling-pane>
    [ <pane-stream> swap display ] keep ;

TUPLE: irc-editor < editor outstream listener client ;

: <irc-editor> ( pane listener client -- editor )
    [ irc-editor new-editor
    swap >>listener swap <pane-stream> >>outstream
    ] dip >>client ;

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

TUPLE: irc-page < frame listener client ;

: <irc-page> ( listener client -- irc-page )
    irc-page new-frame
    [ g swap client>> >>client swap [ swap (>>listener) ] keep
      [ <irc-pane> [ <scroller> g @center grid-add ] keep ]
      [ g client>> <irc-editor> <scroller> g @bottom grid-add ] bi
      g ] with-gadget ;

M: irc-page graft*
    [ listener>> ] [ client>> ] bi
    add-listener ;

M: irc-page ungraft*
    [ listener>> ] [ client>> ] bi
    remove-listener ;

: join-channel ( name ui-window -- )
    [ dup <irc-channel-listener> ] dip
    [ <irc-page> swap ] keep
    tabs>> add-page ;

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
