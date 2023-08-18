! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar calendar.format cli.git
combinators combinators.extras combinators.short-circuit
continuations formatting github http.client io io.directories
io.encodings.utf8 io.files io.files.info io.launcher
io.pathnames json kernel layouts math namespaces
namespaces.extras semver sequences sequences.extras sorting
sorting.human sorting.specification splitting system unicode ;
IN: build-from-source

INITIALIZED-SYMBOL: use-gitlab-git-uris [ f ]
INITIALIZED-SYMBOL: use-github-git-uris [ f ]

INITIALIZED-SYMBOL: build-from-source-directory [ "resource:build-from-source/" ]

SYMBOL: out-directory

: dll-out-directory ( -- path )
    vm-path parent-directory cell-bits "dlls%s-out" sprintf append-path
    dup make-directories ;

: get-out-directory ( -- path )
    out-directory get [ dll-out-directory ] unless* ;

: with-out-directory ( path quot -- )
    [ out-directory ] dip with-variable ; inline

: remake-directory ( path -- )
    [ ?delete-tree ] [ make-directories ] bi ;

: prepend-current-path ( path -- path' )
    current-directory get prepend-path ;

: find-dlls ( path -- paths )
    recursive-directory-files
    [ file-name >lower ".dll" tail? ] filter ;

ERROR: no-output-file path ;
: copy-output-file-as ( name new-name -- )
    [ prepend-current-path dup file-exists? [ no-output-file ] unless ]
    [ get-out-directory prepend-path ] bi* copy-file ;

: copy-vm-file-as ( name new-name -- )
    [ prepend-current-path ]
    [ vm-path parent-directory prepend-path ] bi* copy-file ;

: copy-output-file ( name -- )
    prepend-current-path get-out-directory copy-file-into ;

: copy-output-files ( seq -- )
    [ copy-output-file ] each ;

: delete-output-file ( name -- )
    get-out-directory prepend-path ?delete-file ;

: delete-output-files ( seq -- )
    [ delete-output-file ] each ;

: with-build-directory-as ( name quot -- )
    [ prepend-current-path dup remake-directory ] dip with-directory ; inline

: with-build-directory ( quot -- ) [ "build" ] dip with-build-directory-as ; inline

: get-build-from-source-directory ( -- path )
    build-from-source-directory get ;

: build-from-source-directory-directory-cpu ( -- path )
    get-build-from-source-directory cpu name>> append-path ;

: with-build-from-source-cpu-directory ( quot -- )
    [ build-from-source-directory-directory-cpu dup make-directories ] dip with-directory ; inline

: build-from-source-directory-gitlab ( -- path )
    get-build-from-source-directory "gitlab" append-path ;

: gitlab-disk-path ( base org/user project -- path )
    3append-path
    build-from-source-directory-gitlab prepend-path absolute-path ;

: gitlab-tag-disk-checkout-path ( base org/user project tag -- path )
    [ gitlab-disk-path ] dip append-path absolute-path ;

: with-build-from-source-gitlab-bare-directory ( base org/user quot -- )
    [ build-from-source-directory-gitlab prepend-path dup make-directories ] dip with-directory ; inline

: gitlab-git-uri ( base org/user project -- uri ) "git://%s/%s/%s" sprintf ;
: gitlab-http-uri ( base org/user project -- uri ) "http://%s/%s/%s" sprintf ;
: gitlab-https-uri ( base org/user project -- uri ) "https://%s/%s/%s" sprintf ;

: gitlab-uri ( base org/user project -- uri )
    use-gitlab-git-uris get [ gitlab-git-uri ] [ gitlab-https-uri ] if ;

: sync-gitlab-bare-repository ( base org/user project -- )
    [ 2drop ] [ gitlab-uri ] [ nipd append-path ] 3tri
    '[
        _ _ sync-bare-repository-as wait-for-success
    ] with-build-from-source-gitlab-bare-directory ;

: with-bare-gitlab-repo ( base org/user project quot -- )
    [
        [ sync-gitlab-bare-repository ]
        [ gitlab-disk-path ] 3bi
    ] dip with-directory ; inline

: build-from-source-directory-github ( -- path )
    get-build-from-source-directory "github" append-path ;

: github-disk-path ( org/user project -- path )
    append-path
    build-from-source-directory-github prepend-path absolute-path ;

: github-tag-disk-checkout-path ( org/user project tag -- path )
    [ github-disk-path ] dip append-path absolute-path ;

: with-build-from-source-github-bare-directory ( org/user quot -- )
    [ build-from-source-directory-github prepend-path dup make-directories ] dip with-directory ; inline

: github-uri ( org/user project -- uri )
    use-github-git-uris get [ github-git-uri ] [ github-https-uri ] if ;

: sync-github-bare-repository ( org/user project -- )
    [ drop ] [ github-uri ] [ nip git-directory-name ] 2tri
    '[
        _ _ sync-bare-repository-as wait-for-success
    ] with-build-from-source-github-bare-directory ;

: with-github-worktree-tag ( org/user project tag quot -- )
    [
        {
            [ drop sync-github-bare-repository ]
            [ drop github-disk-path ]
            [ github-tag-disk-checkout-path ]
            [ 2nip ]
        } 3cleave
    ] dip
    '[
        _ _
        over "factor-build-completed" append-path dup file-exists? [
            utf8 file-contents
            "%s\n- %s already built at %s" sprintf print
        ] [
            [
                over "%s\n- deleting old build..." sprintf write
                2dup [ ?delete-tree "deleted!" print ]
                [ "- %s building..." sprintf write ] bi*
                [ git-worktree-force-add wait-for-success ] keepd
                _ with-directory
                "done!" print
                now timestamp>rfc3339
            ] dip utf8 set-file-contents
        ] if
    ] with-directory ; inline

: with-gitlab-worktree-tag ( base org/user project tag quot -- )
    [
        {
            [ drop sync-gitlab-bare-repository ]
            [ drop gitlab-disk-path ]
            [ gitlab-tag-disk-checkout-path ]
            [ 3nip ]
        } 4cleave
    ] dip
    '[
        _ _
        over "factor-build-completed" append-path dup file-exists? [
            utf8 file-contents
            "%s\n- %s already built at %s" sprintf print
        ] [
            [
                over "%s\n- deleting old build..." sprintf write
                2dup [ ?delete-tree "deleted!" print ]
                [ "- %s building..." sprintf write ] bi*
                [ git-worktree-force-add wait-for-success ] keepd
                _ with-directory
                "done!" print
                now timestamp>rfc3339
            ] dip utf8 set-file-contents
        ] if
    ] with-directory ; inline

: ?download ( path -- )
    dup file-name file-exists? [ drop ] [ download ] if ; inline

: with-tar-gz ( path quot -- )
    '[
        _
        [ ?download ]
        [ file-name { "tar" "xvfz" } swap suffix try-process ]
        [ file-name ".tar.gz" ?tail drop ] tri
        prepend-current-path _ with-directory
    ] with-build-from-source-cpu-directory ; inline

: split-python-version ( version -- array )
    {
        { [ dup "a" swap subseq? ] [ [ "a" split1 "99" or "alpha" swap ] keep 4array ] }
        { [ dup "b" swap subseq? ] [ [ "b" split1 "99" or "beta" swap ] keep 4array ] }
        { [ dup "rc" swap subseq? ] [ [ "rc" split1 "99" or "rc" swap ] keep 4array ] }
        [ "z" "99" pick 4array ]
    } cond ;

: latest-python ( tags -- tag )
    [ [ CHAR: . = ] count 2 >= ] filter
    [ split-python-version ] map
    [ first ] collect-by
    { human<=> } sort-keys-with-spec
    last second human-sort last fourth ;

: latest-semver-tags-matching ( owner repo tag-head -- ref-json/f semver/f )
    list-repository-tags-matching
    [ "ref" of "/" split1-last nip [ >semver ] [ 2drop f ] recover ] zip-with
    sift-values sort-values ?last ?first2 ;

: latest-solr ( -- tag-json semver ) "apache" "solr" "releases/solr" latest-semver-tags-matching ;
: latest-lucene ( -- tag-json semver ) "apache" "lucene" "releases/lucene" latest-semver-tags-matching ;

: digit-or-dot? ( str -- ? )
    { [ digit? ] [ CHAR: . = ] } 1|| ;

: tag-refs ( tags -- tags' )
    [ "ref" of ] map
    [ "refs/tags/" ?head drop ] map ;

: python-tags ( -- tags )
    "python" "cpython" "v" list-repository-tags-matching tag-refs ;

: tags>latest-python2 ( tags -- tag ) [ "v2." head? ] filter latest-python ;
: latest-python2 ( -- tag ) python-tags tags>latest-python2 ;
: tags>latest-python3 ( tags -- tag )
    [ "v3." head? ] filter
    [ "." split1-last nip [ digit? ] all? ] filter
    latest-python ;
: latest-python3 ( -- tag ) python-tags tags>latest-python3 ;
