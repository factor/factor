! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel namespaces smtp ;
IN: site-watcher.email

SYMBOL: site-watcher-from
site-watcher-from [ "factor-site-watcher@gmail.com" ] initialize

: send-site-email ( watching-site body subject -- )
    [ account>> email>> ] 2dip
    pick [
        [ <email> site-watcher-from get >>from ] 3dip
        [ 1array >>to ] [ >>body ] [ >>subject ] tri* send-email
    ] [ 3drop ] if ;
