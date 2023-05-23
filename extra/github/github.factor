! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar.parser
cli.git combinators.extras combinators.short-circuit
continuations formatting hashtables http.client io.pathnames
json json.http kernel math math.order namespaces.extras
sequences sorting urls ;
IN: github

! Github API Docs: https://docs.github.com/en/rest
! Setup: https://github.com/settings/tokens add to ~/.factor-boot-rc `USE: tools.scaffold scaffold-factor-boot-rc`
! USING: github namespaces ;
! "erg" github-username set-global
! "the-generated-token" github-token set-global

SYMBOL: github-username
SYMBOL: github-token

: ?github-api ( str -- str' )
    dup "https://api.github.com" head?
    [ "https://api.github.com" prepend ] unless ;

: >github-url ( str -- url )
    ?github-api >url
    github-username required >>username
    github-token required >>password ;

: github-get ( url -- json ) >github-url http-get-json nip ;
: github-post ( post-data url -- json ) [ ?>json ] [ >github-url ] bi* http-post-json nip ;
: github-put ( post-data url -- json ) [ ?>json ] [ >github-url ] bi* http-put-json nip ;
: github-patch ( post-data url -- json ) [ ?>json ] [ >github-url ] bi* http-patch-json nip ;
: github-delete ( url -- json ) >github-url http-delete-json nip ;

! type is one of { "orgs" "users" }
: map-github-pages ( base-url params param-string -- seq )
    [ 0 [ dup ] ] 3dip '[
        1 + _ _ pick suffix _ vsprintf append github-get
        dup empty? [ 2drop f f ] when
    ] produce nip concat ; inline

: map-github-pages-100 ( base-url -- seq )
    { 100 } "?per_page=%d&page=%d" map-github-pages ;

: get-repositories ( type org/user -- seq )
    "/%s/%s/repos" sprintf map-github-pages-100 ;

: list-repository-languages ( owner repo -- seq )
    "/repos/%s/%s/languages" sprintf map-github-pages-100 ;

: list-repository-tags ( owner repo -- seq )
    "/repos/%s/%s/tags" sprintf map-github-pages-100 ;

: list-repository-tags-all ( owner repo -- seq )
    "/repos/%s/%s/git/refs/tags" sprintf github-get ;

: list-repository-branches-matching ( owner repo ref -- seq )
    "/repos/%s/%s/git/matching-refs/heads/%s" sprintf github-get ;

: list-repository-tags-matching ( owner repo ref -- seq )
    "/repos/%s/%s/git/matching-refs/tags/%s" sprintf github-get ;

: list-repository-teams ( owner repo -- seq )
    "/repos/%s/%s/teams" sprintf github-get ;

: list-repository-topics ( owner repo -- seq )
    "/repos/%s/%s/topics" sprintf github-get ;

: github-file-meta-and-contents ( owner repo path -- meta contents )
    "/repos/%s/%s/contents/%s" sprintf github-get
    dup "download_url" of http-get nip ;

: github-file-contents ( owner repo path -- contents )
    github-file-meta-and-contents nip ;

: github-sha-file-meta-and-contents ( owner repo sha path -- meta/f contents/f )
    [
        swap
        "/repos/%s/%s/contents/%s?ref=%s" sprintf github-get
        dup "download_url" of http-get nip
    ] [
        dup { [ download-failed? ] [ response>> code>> 404 = ] } 1&&
        [ 5drop f f ] [ rethrow ] if
    ] recover ;

: github-sha-file-contents ( owner repo sha path -- contents )
    github-sha-file-meta-and-contents nip ;

: github-sha-files-recursive-for-path ( owner repo sha path/f -- files )
    "/repos/%s/%s/git/trees/%s?recursive=1&%s" sprintf github-get ;

: github-sha-files-recursive ( owner repo sha -- files )
    f github-sha-files-recursive-for-path ;

: github-sha-files-for-path ( owner repo sha path -- files )
    swap "/repos/%s/%s/contents/%s?ref=%s" sprintf github-get ;

: github-code-search ( query -- seq )
    "/search/code?q=%s" sprintf github-get ;

: github-factor-code-search ( query -- seq )
    "/search/code?q=%s+language:factor" sprintf github-get ;

: check-enabled-vulnerability-alerts ( owner repo -- json )
    "/repos/%s/%s/vulnerability-alerts" sprintf github-get ;

: enable-vulnerability-alerts ( owner repo -- json )
    [ f ] 2dip
    "/repos/%s/%s/vulnerability-alerts" sprintf github-put ;

: disable-vulnerability-alerts ( owner repo -- json )
    "/repos/%s/%s/vulnerability-alerts" sprintf github-delete ;

: get-codes-of-conduct ( -- seq ) "/codes_of_conduct" github-get ;
! key: contributor_covenant|citizen_code_of_conduct
: get-code-of-conduct ( key -- seq ) "/codes_of_conduct/%s" sprintf github-get ;

! H{ { "names" { "programming-language" "factor" "stack" "concatenative" "language" } }
: set-repository-topics ( assoc owner repo -- json )
    [ >json ] 2dip "/repos/%s/%s/topics" sprintf github-put ;

: get-forks ( owner repo -- seq )
    "/repos/%s/%s/forks" sprintf map-github-pages-100 ;

! H{ { "organization" "rotcaf" } { "name" "pr-fun" } { "default_branch_only" "true" } }
: create-fork ( json owner repo -- res )
    [ >json ] 2dip "/repos/%s/%s/forks" sprintf github-post ;

: get-issues ( owner repo -- seq )
    "/repos/%s/%s/issues" sprintf map-github-pages-100 ;

! Pull Requests
: get-pull-requests ( owner repo -- seq )
    "/repos/%s/%s/pulls" sprintf map-github-pages-100 ;

: get-pull-request ( owner repo n -- seq )
    "/repos/%s/%s/pulls/%d" sprintf github-get ;

: get-open-pull-requests ( owner repo -- seq )
    "/repos/%s/%s/pulls?state=open" sprintf github-get ;

: get-pull-request-files ( owner repo pr-number -- seq )
    "/repos/%s/%s/pulls/%d/files" sprintf github-get ;

: get-files-from-sha ( owner repo sha files -- seq )
    [ "filename" of github-sha-file-meta-and-contents 2array ] with with with zip-with ;

: get-pull-request-files-old-new ( owner repo pr-number -- pr pr-files old new )
    [ drop ] [ get-pull-request ] [ get-pull-request-files ] 3tri
    [ 2nipd ]
    [ [ "base" of "sha" of ] dip get-files-from-sha ]
    [ [ "head" of "sha" of ] dip get-files-from-sha ] 4tri ;

! H{ { "title" "pr2 - updated!" } { "head" "pr2" } { "base" "main" } { "body" "omg pr2 first post" } { "head_repo" "repo-string" } { "issue" 1 } { "draft" "true" } }
: post-pull-request ( assoc owner repo -- res )
    [ >json ] 2dip "/repos/%s/%s/pulls" sprintf github-post ;

: update-pull-request ( assoc owner repo n -- res )
    [ >json ] 3dip "/repos/%s/%s/pulls/%d" sprintf github-patch ;

: list-commits-pull-request ( owner repo n -- res )
    "/repos/%s/%s/pulls/%d/commits" sprintf map-github-pages-100 ;

: list-files-pull-request ( owner repo n -- res )
    "/repos/%s/%s/pulls/%d/files" sprintf map-github-pages-100 ;

: pull-request-merged? ( owner repo n -- res )
    "/repos/%s/%s/pulls/%d/merge" sprintf github-get ;

! H{ { "commit_title" "oh wow" } { "commit_message" "messaged123" } { "merge_method" "merge|squash|rebase" } { "sha" "0c001" } }
: merge-pull-request ( assoc owner repo n -- res )
    [ >json ] 3dip "/repos/%s/%s/pulls/%d/merge" sprintf github-put ;

! H{ { "expected_head_shastring" "0c001" } }
: update-branch-pull-request ( assoc owner repo n -- res )
    [ >json ] 3dip "/repos/%s/%s/pulls/%d/update-branch" sprintf github-put ;

: get-users-page ( page -- seq )
    [ "/users" ] dip
    '{ 100 _ } "?per_page=%d&page=%d" vsprintf append github-get ;

: get-labels ( owner repo -- seq )
    "/repos/%s/%s/labels" sprintf map-github-pages-100 ;

: get-label-names ( owner repo -- seq )
    get-labels [ "name" of ] map ;

: get-issues-by-label ( owner repo -- seq )
    get-issues
    [ "labels" of [ "name" of ] map ] collect-by-multi ;

: get-issues-for-label ( owner repo label -- seq )
    [ get-issues-by-label ] dip of ;

: get-issues-by-all-labels ( owner repo -- seq )
    [ get-label-names [ V{ } clone ] H{ } map>assoc ]
    [ get-issues ] 2bi
    [ "labels" of [ "name" of ] map ] collect-by-multi! ;

: get-empty-labels ( owner repo -- seq ) get-issues-by-all-labels sift-values ;
: get-issues-with-no-labels ( owner repo -- seq ) get-issues [ "labels" of empty? ] filter ;

: get-user ( user -- json ) "/users/%s" sprintf github-get ;
: get-users ( users -- seq ) [ get-user ] map ;

: get-org-repositories ( org -- seq ) [ "orgs" ] dip get-repositories ;
: get-user-repositories ( user -- seq ) [ "users" ] dip get-repositories ;

: get-branches ( owner repo -- json ) "/repos/%s/%s/branches" sprintf github-get ;
: get-branch ( owner repo branch -- json ) "/repos/%s/%s/branches/%s" sprintf github-get ;
: post-rename-branch ( owner repo branch new-name -- json )
    "new-name" associate -roll
    "/repos/%s/%s/branches/%s/rename" sprintf github-post ;

: get-my-issues ( -- json ) "/issues" github-get ;
: get-my-org-issues ( org -- json ) "/orgs/%s/issues" sprintf github-get ;
! H{ { "title" "issue 1" } { "body" "dear, i found a bug" } { "assignees" { "erg" "mrjbq7" } } } >json
: create-issue ( json owner repo -- json )
    "/repos/%s/%s/issues" sprintf github-post ;
: get-issue ( owner repo n -- json )
    "/repos/%s/%s/issues/%d" sprintf github-get ;
! H{ { "title" "issue 1" } { "body" "dear, i found a bug" } { "state" "open|closed" } { "state_reason" "completed|not_planned|reopened|null" } { "assignees" { "erg" "mrjbq7" } } } ! milestone, labels
: update-issue ( json owner repo n -- json )
    "/repos/%s/%s/issues/%d" sprintf github-patch ;

! issue comments
: list-issue-comments ( owner repo -- json )
    "/repos/%s/%s/issues/comments" sprintf github-get ;
: list-issue-comment-by-id ( owner repo comment-id -- json )
    "/repos/%s/%s/issues/comments/%s" sprintf github-get ;
! H{ { "body" "update my stuff" } }
: update-issue-comment-by-id ( json owner repo comment-id -- json )
    "/repos/%s/%s/issues/comments/%s" sprintf github-patch ;
: delete-issue-comment-by-id ( owner repo comment-id -- json )
    "/repos/%s/%s/issues/comments/%s" sprintf github-delete ;
: list-issue-comments-by-id ( owner repo comment-id -- json )
    "/repos/%s/%s/issues/%d/comments" sprintf github-get ;
! H{ { "body" "update my stuff" } }
: create-issue-comment-by-id ( json owner repo issue-number -- json )
    "/repos/%s/%s/issues/%d/comments" sprintf github-post ;

! H{ { "lock_reason" "topic|too heated|resolved|spam" } }
: lock-issue ( json owner repo n -- json )
    "/repos/%s/%s/issues/%d/lock" sprintf github-put ;
: unlock-issue ( owner repo n -- json )
    "/repos/%s/%s/issues/%d/lock" sprintf github-delete ;
: user-issues ( -- json ) "/user/issues" github-get ;

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

: github-http-uri ( org/user project -- uri ) "http://github.com/%s/%s" sprintf ;
: github-https-uri ( org/user project -- uri ) "https://github.com/%s/%s" sprintf ;
