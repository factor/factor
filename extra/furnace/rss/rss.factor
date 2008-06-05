! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel fry
rss http.server.responses furnace.actions ;
IN: furnace.rss

: <feed-content> ( body -- response )
    feed>xml "application/atom+xml" <content> ;

TUPLE: feed-action < action feed ;

: <feed-action> ( -- feed )
    feed-action new-action
        dup '[ , feed>> call <feed-content> ] >>display ;
