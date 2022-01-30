! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs cli.git formatting http.client io.pathnames
json.reader kernel math namespaces sequences ;
IN: github

SYMBOL: github-username
SYMBOL: github-token

! type is orgs, users
:: get-repositories-with-credentials ( type name username token -- seq )
    0 [ dup ] [
        1 + dup
        [ username token type name ] dip
        "https://%s:%s@api.github.com/%s/%s/repos?per_page=100&page=%d" sprintf http-get nip json>
        dup empty? [ 2drop f f ] [ ] if
    ] produce nip concat ;

: get-repositories ( type name -- seq )
    github-username get
    github-token get
    get-repositories-with-credentials ;

: sync-github-org-or-user ( directory type name -- )
    get-repositories
    [ "ssh_url" of ] map sync-repositories ;

: sync-github-org ( directory name -- ) "orgs" swap sync-github-org-or-user ;
: sync-github-user ( directory name -- ) "users" swap sync-github-org-or-user ;

: github-git-uri ( user/org project -- uri ) [ "git@github.com" ] 2dip "/" glue ":" glue ;
: github-ssh-uri ( user/org project -- uri ) [ "https://github.com" ] 2dip 3append-path ;
: github-git-clone-as ( user/org project name -- process ) [ github-git-uri ] dip git-clone-as ;
: github-ssh-clone-as ( user/org project name -- process ) [ github-ssh-uri ] dip git-clone-as ;
: github-git-clone ( user/org project -- process ) dup github-git-clone-as ;
: github-ssh-clone ( user/org project -- process ) dup github-ssh-clone-as ;

