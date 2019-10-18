! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: smtp namespaces accessors kernel arrays site-watcher.db ;
IN: site-watcher.email

SYMBOL: site-watcher-from
site-watcher-from [ "factor-site-watcher@gmail.com" ] initialize

: send-site-email ( watching-site body subject -- )
    [ account>> email>> ] 2dip
    pick [
        [ <email> site-watcher-from get >>from ] 3dip
        [ 1array >>to ] [ >>body ] [ >>subject ] tri* send-email
    ] [ 3drop ] if ;
