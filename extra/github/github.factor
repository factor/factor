! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs assocs.extras calendar.parser cli.git
formatting hashtables http.client io.pathnames json kernel math
math.order namespaces.extras sequences sorting urls ;
IN: github

! Github API Docs: https://docs.github.com/en/rest
! Setup: https://github.com/settings/tokens add to ~/.factor-boot-rc `USE: tools.scaffold scaffold-factor-boot-rc`
! USING: github namespaces ;
! "erg" github-username set-global
! "the-generated-token" github-token set-global

SYMBOL: github-username
SYMBOL: github-token

: >github-url ( str -- url )
    >url
    github-username required >>username
    github-token required >>password ;

: json-get ( endpoint -- json ) http-get nip json> ;
: json-post ( post-data endpoint -- json ) http-post nip json> ;

: github-get ( url -- json ) >github-url json-get ;
: github-post ( post-data url -- json ) >github-url json-post ;

! type is one of { "orgs" "users" }
: map-github-pages ( base-url params param-string -- seq )
    [ 0 [ dup ] ] 3dip '[
        1 + _ _ pick suffix _ vsprintf append github-get
        dup empty? [ 2drop f f ] when
    ] produce nip concat ; inline

: get-repositories ( type org/user -- seq )
    "https://api.github.com/%s/%s/repos" sprintf
    { 100 } "?per_page=%d&page=%d" map-github-pages ;

: get-repository-issues ( owner repo -- seq )
    "https://api.github.com/repos/%s/%s/issues" sprintf
    { 100 } "?per_page=%d&page=%d" map-github-pages ;

: get-repository-pulls ( owner repo -- seq )
    "https://api.github.com/repos/%s/%s/pulls" sprintf
    { 100 } "?per_page=%d&page=%d" map-github-pages ;

: get-users-page ( page -- seq )
    [ "https://api.github.com/users" ] dip
    '{ 100 _ } "?per_page=%d&page=%d" vsprintf append github-get ;

: get-respository-labels ( owner repo -- seq )
    "https://api.github.com/repos/%s/%s/labels" sprintf
    '{ 100 } "?per_page=%d&page=%d" map-github-pages ;

: get-respository-label-names ( owner repo -- seq )
    get-respository-labels [ "name" of ] map ;

: get-issues-by-label ( owner repo -- seq )
    get-repository-issues
    [ "labels" of [ "name" of ] map ] collect-by-multi ;

: get-issues-for-label ( owner repo label -- seq )
    [ get-issues-by-label ] dip of ;

: get-issues-by-all-labels ( owner repo -- seq )
    [ get-respository-label-names [ V{ } clone ] H{ } map>assoc ]
    [ get-repository-issues ] 2bi
    [ "labels" of [ "name" of ] map ] collect-by-multi! ;

: get-empty-labels ( owner repo -- seq ) get-issues-by-all-labels sift-values ;
: get-issues-with-no-labels ( owner repo -- seq ) get-repository-issues [ "labels" of empty? ] filter ;

: get-user ( user -- json ) "https://api.github.com/users/%s" sprintf github-get ;
: get-users ( users -- seq ) [ get-user ] map ;

: get-org-repositories ( org -- seq ) [ "orgs" ] dip get-repositories ;
: get-user-repositories ( user -- seq ) [ "users" ] dip get-repositories ;

: get-branches ( owner repo -- json ) "https://api.github.com/repos/%s/%s/branches" sprintf github-get ;
: get-branch ( owner repo branch -- json ) "https://api.github.com/repos/%s/%s/branches/%s" sprintf github-get ;
: post-rename-branch ( owner repo branch new-name -- json )
    "new-name" associate -roll
    "https://api.github.com/repos/%s/%s/branches/%s/rename" sprintf >github-url json-post ;

: get-my-issues ( -- json ) "https://api.github.com/issues" github-get ;

: find-repos-by-name ( seq quot: ( name -- ? ) -- seq' ) '[ "name" of @ ] filter ; inline
: find-repos-by-visibility ( seq quot: ( name -- ? ) -- seq' ) '[ "visibility" of @ ] filter ; inline
: find-public-repos ( seq -- seq' ) [ "visibility" of "public" = ] filter ; inline
: find-private-repos ( seq -- seq' ) [ "private" of ] filter ; inline

: sort-repos-by-time ( seq name quot: ( obj1 obj2 -- <=> ) -- seq' ) '[ [ _ of rfc3339>timestamp ] bi@ @ ] sort-with ; inline
: sort-repos-by-created-at<=> ( seq -- seq' ) "created_at" [ <=> ] sort-repos-by-time ;
: sort-repos-by-created-at>=< ( seq -- seq' ) "created_at" [ >=< ] sort-repos-by-time ;
: sort-repos-by-pushed-at<=> ( seq -- seq' ) "pushed_at" [ <=> ] sort-repos-by-time ;
: sort-repos-by-pushed-at>=< ( seq -- seq' ) "pushed_at" [ >=< ] sort-repos-by-time ;
: sort-repos-by-updated-at<=> ( seq -- seq' ) "updated_at" [ <=> ] sort-repos-by-time ;
: sort-repos-by-updated-at>=< ( seq -- seq' ) "updated_at" [ >=< ] sort-repos-by-time ;

: sync-github-org-or-user ( directory type name -- )
    get-repositories [ "ssh_url" of ] map sync-repositories ;

: sync-github-org ( directory org -- ) [ "orgs" ] dip sync-github-org-or-user ;
: sync-github-user ( directory user -- ) [ "users" ] dip sync-github-org-or-user ;

: github-git-uri ( org/user project -- uri ) [ "git@github.com" ] 2dip "/" glue ":" glue ;
: github-ssh-uri ( org/user project -- uri ) [ "https://github.com" ] 2dip 3append-path ;
: github-git-clone-as ( org/user project name -- process ) [ github-git-uri ] dip git-clone-as ;
: github-ssh-clone-as ( org/user project name -- process ) [ github-ssh-uri ] dip git-clone-as ;
: github-git-clone ( org/user project -- process ) dup github-git-clone-as ;
: github-ssh-clone ( org/user project -- process ) dup github-ssh-clone-as ;

