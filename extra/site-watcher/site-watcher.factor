! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms assocs calendar combinators
continuations fry http.client io.streams.string kernel init
namespaces prettyprint smtp arrays sequences math math.parser
strings sets ;
IN: site-watcher

SYMBOL: sites

SYMBOL: site-watcher-from

sites [ H{ } clone ] initialize

TUPLE: watching emails url last-up up? send-email? error ;

<PRIVATE

: ?1array ( array/object -- array )
    dup array? [ 1array ] unless ; inline

: <watching> ( emails url -- watching )
    watching new
        swap >>url
        swap ?1array >>emails
        now >>last-up
        t >>up? ;

ERROR: not-watching-site url status ;

: set-site-flags ( watching new-up? -- watching )
    [ over up?>> = [ t >>send-email? ] unless ] keep >>up? ;

: site-bad ( watching error -- )
    >>error f set-site-flags drop ;

: site-good ( watching -- )
    f >>error
    t set-site-flags
    now >>last-up drop ;

: check-sites ( assoc -- )
    [
        swap '[ _ http-get 2drop site-good ] [ site-bad ] recover
    ] assoc-each ;

: site-up-email ( email watching -- email )
    last-up>> now swap time- duration>minutes 60 /mod
    [ >integer number>string ] bi@
    [ " hours, " append ] [ " minutes" append ] bi* append
    "Site was down for (at least): " prepend >>body ;

: ?unparse ( string/object -- string )
    dup string? [ unparse ] unless ; inline

: site-down-email ( email watching -- email )
    error>> ?unparse >>body ;

: send-report ( watching -- )
    [ <email> ] dip
    {
        [ emails>> >>to ]
        [ drop site-watcher-from get "factor.site.watcher@gmail.com" or >>from ]
        [ dup up?>> [ site-up-email ] [ site-down-email ] if ]
        [ [ url>> ] [ up?>> "up" "down" ? ] bi " is " glue >>subject ]
        [ f >>send-email? drop ]
    } cleave send-email ;

: report-sites ( assoc -- )
    [ nip send-email?>> ] assoc-filter
    [ nip send-report ] assoc-each ;

PRIVATE>

SYMBOL: site-watcher-frequency
site-watcher-frequency [ 5 minutes ] initialize

: watch-sites ( assoc -- alarm )
    '[
        _ [ check-sites ] [ report-sites ] bi
    ] site-watcher-frequency get every ;

: watch-site ( emails url -- )
    sites get ?at [
        [ [ ?1array ] dip append prune ] change-emails drop
    ] [
        <watching> dup url>> sites get set-at
    ] if ;

: delete-site ( url -- )
    sites get delete-at ;

: unwatch-site ( emails url -- )
    [ ?1array ] dip
    sites get ?at [
        [ diff ] change-emails dup emails>> empty? [
            url>> delete-site
        ] [
            drop
        ] if 
    ] [
        nip delete-site
    ] if ;

SYMBOL: running-site-watcher

: run-site-watcher ( -- )
    running-site-watcher get-global [
        sites get-global watch-sites running-site-watcher set-global
    ] unless ;

[ f running-site-watcher set-global ] "site-watcher" add-init-hook

MAIN: run-site-watcher
