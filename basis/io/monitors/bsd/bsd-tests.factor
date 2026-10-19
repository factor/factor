USING: accessors calendar concurrency.mailboxes destructors
io.directories io.encodings.utf8 io.files io.monitors io.monitors.bsd io.timeouts
kernel locals namespaces sequences tools.test ;
IN: io.monitors.bsd.tests

:: change-with ( descriptor monitor -- change )
    monitor next-change :> change
    descriptor change changed>> member?
    [ change ] [ descriptor monitor change-with ] if ;

! Exercise the shared backend directly, independently of the host hooks.
{ t t t t } [
    [
        [let
            init-bsd-monitors
            "." t <mailbox> <bsd-monitor> :> monitor
            5 seconds monitor set-timeout
            "subdir" make-directory
            +add-file+ monitor change-with path>> "subdir" tail?
            "subdir/old" touch-file
            +add-file+ monitor change-with path>> "subdir/old" tail?
            "subdir/old" "subdir/new" move-file
            +rename-file-old+ monitor change-with path>> "subdir/old" tail?
            +rename-file-new+ monitor change-with path>> "subdir/new" tail?
            dispose-bsd-monitors
        ] with-scope
    ] with-test-directory
] unit-test

{ t t } [
    [
        [let
            init-bsd-monitors
            "file" touch-file
            "." f <mailbox> <bsd-monitor> :> monitor
            5 seconds monitor set-timeout
            ! Change the size so this works even with coarse timestamps.
            "modified contents" "file" utf8 set-file-contents
            +modify-file+ monitor change-with path>> "file" tail?
            "file" delete-file
            +remove-file+ monitor change-with path>> "file" tail?
            dispose-bsd-monitors
        ] with-scope
    ] with-test-directory
] unit-test
