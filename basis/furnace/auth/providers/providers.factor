! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.parser random sequences ;
IN: furnace.auth.providers

TUPLE: user
username realname
password salt
email ticket capabilities profile deleted changed? ;

: <user> ( username -- user )
    user new
        swap >>username
        0 >>deleted ;

GENERIC: get-user ( username provider -- user/f )

GENERIC: update-user ( user provider -- )

GENERIC: new-user ( user provider -- user/f )

! Password recovery support

:: issue-ticket ( email username provider -- user/f )
    username provider get-user :> user
    user [
        user email>> length 0 > [
            user email>> email = [
                user
                256 random-bits >hex >>ticket
                dup provider update-user
            ] [ f ] if
        ] [ f ] if
    ] [ f ] if ;

:: claim-ticket ( ticket username provider -- user/f )
    username provider get-user :> user
    user [
        user ticket>> ticket = [
            user f >>ticket dup provider update-user
        ] [ f ] if
    ] [ f ] if ;

! For configuration

: add-user ( provider user -- provider )
    over new-user [ "User exists" throw ] when ;
