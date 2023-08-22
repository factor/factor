! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators furnace.actions furnace.utilities
http.server.responses io.encodings.utf8 kernel sequences
syndication ;
IN: furnace.syndication

GENERIC: feed-entry-title ( object -- string )

GENERIC: feed-entry-date ( object -- timestamp )

GENERIC: feed-entry-url ( object -- url )

GENERIC: feed-entry-description ( object -- description )

M: object feed-entry-description drop f ;

GENERIC: >entry ( object -- entry )

M: entry >entry ;

M: object >entry
    <entry>
        swap {
            [ feed-entry-title >>title ]
            [ feed-entry-date >>date ]
            [ feed-entry-url >>url ]
            [ feed-entry-description >>description ]
        } cleave ;

: process-entries ( seq -- seq' )
    20 index-or-length head-slice [
        >entry clone
        [ adjust-url ] change-url
    ] map ;

: <feed-content> ( body -- response )
    feed>xml "application/atom+xml" <content>
    "UTF-8" >>content-charset
    utf8 >>content-encoding ;

TUPLE: feed-action < action title url entries ;

: <feed-action> ( -- action )
    feed-action new-action
        dup '[
            feed new
                _
                [ title>> call >>title ]
                [ url>> call adjust-url >>url ]
                [ entries>> call process-entries >>entries ]
                tri
            <feed-content>
        ] >>display ;
