! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cli.git combinators io.directories io.files.info
io.pathnames kernel sequences uuid github ;
IN: zealot

: default-zealot-directory ( chunk -- path ) [ home ".zealot" ] dip 3append-path ;
: default-zealot-source-directory ( -- path ) "source" default-zealot-directory ;
: default-zealot-builds-directory ( -- path ) "builds" default-zealot-directory ;

: zealot-source-directory ( chunk -- path ) [ default-zealot-source-directory ] dip append-path ;
: zealot-builds-directory ( chunk -- path ) [ default-zealot-builds-directory ] dip append-path ;

: with-default-zealot-source-directory ( chunk quot -- )
    [ default-zealot-source-directory ] dip with-ensure-directory ; inline

: with-default-zealot-builds-directory ( chunk quot -- )
    [ default-zealot-builds-directory ] dip with-ensure-directory ; inline

: with-zealot-source-directory ( chunk quot -- )
    [ zealot-source-directory ] dip with-ensure-directory ; inline

: with-zealot-builds-directory ( chunk quot -- )
    [ zealot-builds-directory ] dip with-ensure-directory ; inline


: with-zealot-github-directory ( quot -- )
    [ "github" ] dip with-zealot-source-directory ; inline

: with-zealot-github-project-directory ( user project quot -- )
    [ "github" ] 3dip [ 3append-path ] dip with-zealot-source-directory ; inline

: zealot-github-clone ( user project -- process )
    '[ _ _ 2dup "/" glue github-git-clone-as ] with-zealot-github-directory ; inline

: zealot-github-source-path ( user project -- path )
    [ "github" ] 2dip 3append-path zealot-source-directory ;

: zealot-github-builds-path ( user project -- path )
    [ "github" ] 2dip 3append-path uuid1 append-path zealot-builds-directory ;

: zealot-github-fetch-all ( user project -- process )
    [ git-fetch-all* ] with-zealot-github-project-directory ;

: zealot-github-fetch-tags ( user project -- process )
    [ git-fetch-tags* ] with-zealot-github-project-directory ;

: zealot-github-pull ( user project -- process )
    [ git-pull* ] with-zealot-github-project-directory ;

: zealot-github-exists-locally? ( user project -- ? )
    zealot-github-source-path ?file-info >boolean ;

: zealot-github-ensure ( user project -- process )
    2dup zealot-github-exists-locally? [
        {
            [ zealot-github-fetch-all drop ]
            [ zealot-github-fetch-tags drop ]
            [ zealot-github-pull ]
        } 2cleave
    ] [
        zealot-github-clone
    ] if ;

: zealot-github-set-build-remote ( path user project -- process )
    '[ "origin" _ _ github-ssh-uri git-change-remote* ] with-directory ;

: zealot-github-add-build-remote ( path user project -- process )
    '[ "github" _ _ github-ssh-uri git-remote-add* ] with-directory ;

: zealot-github-clone-paths ( user project -- process builds-path )
    [ zealot-github-source-path ]
    [ zealot-github-builds-path ] 2bi
    [ git-clone-as ] keep ;

: zealot-build-checkout ( path branch/checksum -- process )
    '[ _ git-checkout-existing* ] with-directory ;
