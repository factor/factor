! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators continuations debugger io
kernel make mason.common mason.config mason.platform math.order
namespaces sequences smtp ;
IN: mason.email

: mason-email ( body content-type subject -- )
    '[
        <email>
            builder-from get >>from
            builder-recipients get >>to
            _ >>body
            _ >>content-type
            _ >>subject
        send-email
    ] [
        "E-MAILING FAILED:" print-timestamp
        error. flush
    ] recover ;

: subject-prefix ( -- string )
    "mason on " platform ": " 3append ;

: report-subject ( status -- string )
    [
        subject-prefix %
        current-git-id get 7 index-or-length head %
        " -- " %
        {
            { status-clean [ "clean" ] }
            { status-dirty [ "dirty" ] }
            { status-error [ "error" ] }
        } case %
    ] "" make ;

: email-report ( report status -- )
    [ "text/html" ] dip report-subject mason-email ;

! Some special logic to throttle the amount of fatal errors
! coming in, if eg git-daemon goes down on factorcode.org and
! it fails pulling every 5 minutes.

SYMBOL: last-email-time

SYMBOL: next-email-time

: send-email-throttled? ( -- ? )
    ! We sent too many errors. See if its time to send a new
    ! one again.
    now next-email-time get-global after?
    [ f next-email-time set-global t ] [ f ] if ;

: throttle-time ( -- dt ) 6 hours ;

: throttle-emails ( -- )
    ! Last e-mail was less than 20 minutes ago. Don't send any
    ! errors for 4 hours.
    throttle-time hence next-email-time set-global
    f last-email-time set-global ;

: maximum-frequency ( -- dt ) 30 minutes ;

: send-email-capped? ( -- ? )
    ! We're about to send an error after sending another one.
    ! See if we should start throttling emails.
    last-email-time get-global
    maximum-frequency ago
    after?
    [ throttle-emails f ] [ t ] if ;

: email-fatal? ( -- ? )
    {
        { [ next-email-time get-global ] [ send-email-throttled? ] }
        { [ last-email-time get-global ] [ send-email-capped? ] }
        [ now last-email-time set-global t ]
    } cond
    dup [ now last-email-time set-global ] when ;

: email-fatal ( string subject -- )
    [ print nl print flush ]
    [
        email-fatal? [
            now last-email-time set-global
            [ "text/plain" subject-prefix ] dip append
            mason-email
        ] [ 2drop ] if
    ] 2bi ;
