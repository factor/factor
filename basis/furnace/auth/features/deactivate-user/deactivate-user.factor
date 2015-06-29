! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs namespaces accessors db db.tuples urls
http.server.dispatchers
furnace.asides
furnace.actions
furnace.auth
furnace.auth.providers ;
IN: furnace.auth.features.deactivate-user

: <deactivate-user-action> ( -- action )
    <action>
        [
            logged-in-user get
                1 >>deleted
                t >>changed?
            drop
            URL" $realm" end-aside
        ] >>submit ;

: allow-deactivation ( realm -- realm )
    <deactivate-user-action> <protected>
        "delete your profile" >>description
    "deactivate-user" add-responder ;

: allow-deactivation? ( -- ? )
    realm get responders>> "deactivate-user" swap key? ;
