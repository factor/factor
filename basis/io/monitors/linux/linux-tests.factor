USING: accessors calendar destructors io.directories io.files io.monitors
io.pathnames io.timeouts kernel locals namespaces sequences tools.test ;

! Linux removes a watch automatically when the watched directory is deleted.
{ } [
    [
        [
            "gone" make-directory
            "gone" f <monitor> [
                drop "gone" delete-directory
            ] with-disposal
        ] with-monitors
    ] with-test-directory
] unit-test

! Automatic watch removal must wake readers rather than leave them waiting
! on a watch descriptor that no longer exists.
[
    [
        [
            "gone" make-directory
            "gone" f <monitor> [| m |
                3 seconds m set-timeout
                "gone" delete-directory
                m next-change drop
            ] with-disposal
        ] with-monitors
    ] with-test-directory
] [ already-disposed? ] must-fail-with

! Removing one child watch must not terminate the recursive event pump.
{ t } [
    [
        [
            "child" make-directory
            "." t <monitor> [| m |
                3 seconds m set-timeout
                "child" "moved" move-file
                [ m next-change path>> "moved" absolute-path = not ] loop
                "after-move" touch-file
                [ m next-change path>> "after-move" absolute-path = not ] loop
                t
            ] with-disposal
        ] with-monitors
    ] with-test-directory
] unit-test

! Move a whole subtree: descendants must be watched under their new paths,
! while siblings whose names share the old prefix must keep their watches.
{ t } [
    [
        [
            "child/sub" make-directories
            "child-sibling" make-directory
            "." t <monitor> [| m |
                3 seconds m set-timeout
                "child" "moved" move-file
                ! The rename notification follows the scan of the new
                ! subtree; synthetic add notifications can precede it.
                [ m next-change changed>> +rename-file-new+ swap member? not ] loop
                "moved/sub/after-move" touch-file
                [ m next-change path>> "moved/sub/after-move" absolute-path = not ] loop
                "child-sibling/untouched" touch-file
                [ m next-change path>> "child-sibling/untouched" absolute-path = not ] loop
                t
            ] with-disposal
        ] with-monitors
    ] with-test-directory
] unit-test

! On Linux, a notification on the directory itself would report an invalid
! path name
[
    [
        ! Non-recursive
        { } [
            "." f <monitor> "m" set
            3 seconds "m" get set-timeout
            "." touch-file
        ] unit-test

        { t } [
            "m" get next-change path>>
            [ "" = ] [ "." absolute-path = ] bi or
        ] unit-test

        { } [ "m" get dispose ] unit-test

        ! Recursive
        { } [
            "." t <monitor> "m" set
            3 seconds "m" get set-timeout
            "." touch-file
        ] unit-test

        { t } [
            "m" get next-change path>>
            [ "" = ] [ "." absolute-path = ] bi or
        ] unit-test

        { } [ "m" get dispose ] unit-test
    ] with-monitors
] with-test-directory
