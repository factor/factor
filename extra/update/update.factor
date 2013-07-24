USING: kernel system sequences io.files io.directories
io.pathnames io.launcher bootstrap.image http.client update.util ;
IN: update

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-command ( cmd -- ) to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-pull-clean ( -- )
    image parent-directory [
        { "git" "pull" "git://factorcode.org/git/factor.git" branch-name }
        run-command
    ] with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remote-clean-image ( -- url )
    { "http://factorcode.org/images/clean/" platform "/" my-boot-image-name }
    to-string ;

: download-clean-image ( -- ) remote-clean-image download ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-clean ( -- ) { gnu-make "clean" } run-command ;
: make       ( -- ) { gnu-make         } run-command ;
: boot       ( -- ) { "./factor" { "-i=" my-boot-image-name } } run-command ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rebuild ( -- )
    image parent-directory [
        download-clean-image
        make-clean
        make
        boot
    ] with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update ( -- )
    image parent-directory [
        git-id
        git-pull-clean
        git-id
        = not
        [ rebuild ]
        when
    ] with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: update
