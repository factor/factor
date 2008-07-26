! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel threads combinators concurrency.mailboxes
       sequences strings hashtables splitting fry assocs hashtables
       ui ui.gadgets ui.gadgets.panes ui.gadgets.editors
       ui.gadgets.scrollers ui.commands ui.gadgets.frames ui.gestures
       ui.gadgets.tabs ui.gadgets.grids ui.gadgets.lists ui.gadgets.labels
       io io.styles namespaces calendar calendar.format models
       irc.client irc.client.private irc.messages irc.messages.private
       irc.ui.commandparser irc.ui.load ;

IN: irc.ui

SYMBOL: listener

SYMBOL: client

TUPLE: ui-window client tabs ;

TUPLE: irc-tab < frame listener client listmodel ;

: write-color ( str color -- )
    foreground associate format ;
: red { 0.5 0 0 1 } ;
: green { 0 0.5 0 1 } ;
: blue { 0 0 1 1 } ;
: black { 0 0 0 1 } ;

: colors H{ { +operator+ { 0 0.5 0 1 } }
            { +voice+ { 0 0 1 1 } }
            { +normal+ { 0 0 0 1 } } } ;

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

M: mode write-irc
    "* " blue write-color
    [ name>> write ] keep
    " has applied mode " blue write-color
    [ mode>> write ] keep
    " to " blue write-color
    channel>> write ;

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

GENERIC: handle-inbox ( tab message -- )

: filter-participants ( assoc val -- alist )
    [ >alist ] dip
   '[ second , = ] filter ;

: update-participants ( tab -- )
    [ listmodel>> ] [ listener>> participants>> ] bi
    [ +operator+ filter-participants ]
    [ +voice+ filter-participants ]
    [ +normal+ filter-participants ] tri
    append append swap set-model ;

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

: <irc-list> ( -- gadget model )
    [ drop ]
    [ first2 [ <label> ] dip >>color ]
    { } <model> [ <list> ] keep ;

: <irc-tab> ( listener client -- irc-tab )
    irc-tab new-frame
    swap client>> >>client swap >>listener
    <irc-pane> [ <scroller> @center grid-add ] keep
    <irc-editor> <scroller> @bottom grid-add ;

: <irc-channel-tab> ( listener client -- irc-tab )
    <irc-tab>
    <irc-list> [ <scroller> @right grid-add ] dip >>listmodel
    [ update-participants ] keep ;

: <irc-server-tab> ( listener client -- irc-tab )
    <irc-tab> ;

M: irc-tab graft*
    [ listener>> ] [ client>> ] bi
    add-listener ;

M: irc-tab ungraft*
    [ listener>> ] [ client>> ] bi
    remove-listener ;

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
    [ listeners>> +server-listener+ swap at over <irc-tab>
      "Server" associate <tabbed> >>tabs ] bi ;

: server-open ( server port nick password channels -- )
    [ <irc-profile> ui-connect [ irc-window ] keep ] dip
    [ over join-channel ] each drop ;

: main-run ( -- ) run-ircui ;

MAIN: main-run
