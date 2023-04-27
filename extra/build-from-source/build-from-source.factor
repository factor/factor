! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs cli.git combinators
combinators.extras combinators.short-circuit continuations
formatting github http.client io.directories io.files
io.files.info io.files.temp io.launcher io.pathnames json kernel
layouts math namespaces namespaces.extras semver sequences
sequences.extras sorting sorting.human sorting.specification
splitting system unicode ;
IN: build-from-source

INITIALIZED-SYMBOL: use-gitlab-git-uris [ f ]
INITIALIZED-SYMBOL: use-github-git-uris [ t ]

: dll-out-directory ( -- path )
    vm-path parent-directory cell-bits "dlls%s-out" sprintf append-path
    dup make-directories ;

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
    [ dll-out-directory prepend-path ] bi* copy-file ;

: copy-vm-file-as ( name new-name -- )
    [ prepend-current-path ]
    [ vm-path parent-directory prepend-path ] bi* copy-file ;

: copy-output-file ( name -- )
    prepend-current-path dll-out-directory copy-file-into ;

: copy-output-files ( seq -- )
    [ copy-output-file ] each ;

: delete-output-file ( name -- )
    dll-out-directory prepend-path ?delete-file ;

: delete-output-files ( seq -- )
    [ delete-output-file ] each ;

: with-build-directory-as ( name quot -- )
    [ prepend-current-path dup remake-directory ] dip with-directory ; inline

: with-build-directory ( quot -- ) [ "build" ] dip with-build-directory-as ; inline

: temp-directory-cpu ( -- path )
    temp-directory cpu name>> append-path ;

: with-temp-cpu-directory ( quot -- )
    [ temp-directory-cpu dup make-directories ] dip with-directory ; inline

: temp-directory-gitlab ( -- path )
    temp-directory "gitlab" append-path ;

: with-temp-gitlab-org-directory ( base org/user quot -- )
    [ append-path temp-directory-gitlab prepend-path dup make-directories ] dip with-directory ; inline

: gitlab-git-uri ( base org/user project -- uri ) "git://%s/%s/%s" sprintf ;
: gitlab-http-uri ( base org/user project -- uri ) "http://%s/%s/%s" sprintf ;
: gitlab-https-uri ( base org/user project -- uri ) "https://%s/%s/%s" sprintf ;

: gitlab-uri ( base org/user project -- uri )
    use-gitlab-git-uris get [ gitlab-git-uri ] [ gitlab-https-uri ] if ;

! "gitlab.freedesktop.org" "cairo" "cairo"
: sync-gitlab-pristine-repository-as ( base org/user project -- )
    [ drop ] [ gitlab-uri ] 3bi
    '[
        _ sync-repository wait-for-success
    ] with-temp-gitlab-org-directory ;

: sync-gitlab-pristine-and-clone-build-repository-as ( base org/user project build-path -- build-path )
    [ drop sync-gitlab-pristine-repository-as ]
    [ [ append-path append-path temp-directory-gitlab prepend-path ] dip ] 4bi
    '[
        _ _ [ ?delete-tree ] [ git-clone-as wait-for-success ] [ ] tri
    ] with-temp-cpu-directory ;

: with-updated-gitlab-repo-as ( base org/user project build-path-as quot -- )
    [ sync-gitlab-pristine-and-clone-build-repository-as ] dip
    '[
        _ prepend-current-path _ with-directory
    ] with-temp-cpu-directory ; inline

: with-updated-gitlab-repo ( base org/user project quot -- )
    [ dup git-directory-name ] dip with-updated-gitlab-repo-as ; inline

: temp-directory-github ( -- path )
    temp-directory "github" append-path ;

: with-temp-github-directory ( org/user quot -- )
    [ temp-directory-github prepend-path dup make-directories ] dip with-directory ; inline

: github-uri ( org/user project -- uri )
    use-github-git-uris get [ github-git-uri ] [ github-https-uri ] if ;

: sync-github-pristine-repository-as ( org/user project -- )
    [ drop ] [ github-uri ] [ nip ] 2tri
    '[
        _ _ sync-repository-as wait-for-success
    ] with-temp-github-directory ;

! "factor" "vscode-factor" "factor-buildme-here"
: sync-github-pristine-and-clone-build-repository-as ( org/user project build-path -- build-path )
    [ drop sync-github-pristine-repository-as ]
    [ [ append-path temp-directory-github prepend-path ] dip ] 3bi
    '[
        _ _ [ ?delete-tree ] [ git-clone-as wait-for-success ] [ ] tri
    ] with-temp-cpu-directory ;

: with-updated-github-repo-as ( org/user project build-path-as quot -- )
    [ sync-github-pristine-and-clone-build-repository-as ] dip
    '[
        _ prepend-current-path _ with-directory
    ] with-temp-cpu-directory ; inline

: with-updated-github-repo ( org/user project quot -- )
    [ dup git-directory-name ] dip with-updated-github-repo-as ; inline

: ?download ( path -- )
    dup file-name file-exists? [ drop ] [ download ] if ; inline

: with-tar-gz ( path quot -- )
    '[
        _
        [ ?download ]
        [ file-name { "tar" "xvfz" } swap suffix try-process ]
        [ file-name ".tar.gz" ?tail drop ] tri
        prepend-current-path _ with-directory
    ] with-temp-cpu-directory ; inline

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

: python-tags ( -- tags )
    "python" "cpython" "v" list-repository-tags-matching
    [ "ref" of ] map
    [ "refs/tags/" ?head drop ] map ;

: tags>latest-python2 ( tags -- tag ) [ "v2." head? ] filter latest-python ;
: latest-python2 ( -- tag ) python-tags tags>latest-python2 ;
: tags>latest-python3 ( tags -- tag ) [ "v3." head? ] filter latest-python ;
: latest-python3 ( -- tag ) python-tags tags>latest-python3 ;
