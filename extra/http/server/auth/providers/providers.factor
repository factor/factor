! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel new-slots accessors random math.parser locals
sequences math crypto.sha2 ;
IN: http.server.auth.providers

TUPLE: user username realname password email ticket profile ;

: <user> user construct-empty H{ } clone >>profile ;

GENERIC: get-user ( username provider -- user/f )

GENERIC: update-user ( user provider -- )

GENERIC: new-user ( user provider -- user/f )

: check-login ( password username provider -- user/f )
    get-user dup [ [ password>> = ] keep and ] [ 2drop f ] if ;

: set-password ( user password -- user ) >>password ;

! Password recovery support

:: issue-ticket ( email username provider -- user/f )
    [let | user [ username provider get-user ] |
        user [
            user email>> length 0 > [
                user email>> email = [
                    user
                    256 random-bits >hex >>ticket
                    dup provider update-user
                ] [ f ] if
            ] [ f ] if
        ] [ f ] if
    ] ;

:: claim-ticket ( ticket username provider -- user/f )
    [let | user [ username provider get-user ] |
        user [
            user ticket>> ticket = [
                user f >>ticket dup provider update-user
            ] [ f ] if
        ] [ f ] if
    ] ;

! For configuration

: add-user ( provider user -- provider )
    over new-user [ "User exists" throw ] when ;
