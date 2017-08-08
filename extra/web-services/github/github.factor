! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs cli.git concurrency.combinators
concurrency.semaphores formatting fry http.client io
io.directories json.reader kernel locals math namespaces
sequences ;
IN: web-services.github

SYMBOL: github-username
SYMBOL: github-token

:: get-organization-repositories-with-credentials ( organization username token -- seq )
    0 [ dup ] [
        1 + dup
        [ username token organization ] dip
        "https://%s:%s@api.github.com/orgs/%s/repos?per_page=100&page=%d" sprintf http-get nip json>
        dup empty? [ 2drop f f ] [ ] if
    ] produce nip concat ;

: get-organization-repositories ( organization -- seq )
    github-username get
    github-token get
    get-organization-repositories-with-credentials ;

: sync-organization-with-credentials ( directory organization username token -- )
    get-organization-repositories-with-credentials
    [ "ssh_url" of ] map sync-repositories ;

: sync-organization ( directory organization -- )
    github-username get
    github-token get
    sync-organization-with-credentials ;

