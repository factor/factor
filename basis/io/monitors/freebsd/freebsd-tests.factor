USING: accessors assocs calendar combinators continuations destructors io.directories
io.encodings.utf8 io.files io.files.links io.monitors io.monitors.freebsd
io.pathnames io.timeouts kernel locals namespaces sequences sets
tools.test unix unix.ffi ;
IN: io.monitors.freebsd.tests

:: expect-change ( name change monitor -- )
    5 seconds monitor set-timeout
    [
        monitor next-change
        [ path>> name = ] [ changed>> change swap member? ] bi and not
    ] loop ;

! Changes must carry child names, including writes to an existing file.
{ } [
    [
        [
          [let
            "." f <monitor> :> monitor
            "file" touch-file
            "file" +add-file+ monitor expect-change
            "contents" "file" utf8 set-file-contents
            "file" +modify-file+ monitor expect-change
            "file" "renamed" move-file
            "file" +remove-file+ monitor expect-change
            "renamed" +add-file+ monitor expect-change
            "renamed" delete-file
            "renamed" +remove-file+ monitor expect-change
          ]
        ] with-monitors
    ] with-test-directory
] unit-test

:: expect-root-removal ( monitor -- ? )
    5 seconds monitor set-timeout
    [ monitor next-change drop f ] [ already-disposed? ] recover
    monitor disposed>> and ;

! Removing or moving the watched directory closes its queue and wakes readers.
{ t } [
    [
        "watched" make-directory
        [
          [let
            "watched" f <monitor> :> monitor
            "watched" delete-directory
            monitor expect-root-removal
          ]
        ] with-monitors
    ] with-test-directory
] unit-test

{ t } [
    [
        "watched" make-directory
        [
          [let
            "watched" f <monitor> :> monitor
            "watched" "moved" move-file
            monitor expect-root-removal
          ]
        ] with-monitors
    ] with-test-directory
] unit-test

! Editors commonly save by replacing a file, so reattach its vnode watch.
{ } [
    [
        [
          [let
            "original" "file" utf8 set-file-contents
            "." f <monitor> :> monitor
            "replacement" "temporary" utf8 set-file-contents
            "temporary" "file" move-file
            "file" +remove-file+ monitor expect-change
            "file" +add-file+ monitor expect-change
            "changed again" "file" utf8 set-file-contents
            "file" +modify-file+ monitor expect-change
          ]
        ] with-monitors
    ] with-test-directory
] unit-test

! Scope cleanup owns every queue and vnode descriptor; disposal is idempotent.
{ t t t t } [
    [
        "file" touch-file
        [ "." f <monitor> ] with-monitors
        {
            [ disposed>> ]
            [ handle>> disposed>> ]
            [ root>> handle>> disposed>> ]
            [ dup dispose watches>> values [ handle>> disposed>> ] all? ]
        } cleave
    ] with-test-directory
] unit-test

! Follow an explicitly selected directory link, but never open child FIFOs.
{ } [
    [
        "directory" make-directory
        "directory" "link" make-link
        "directory/pipe" normalize-path 0o600 make-fifo
        [
          [let
            "link" f <monitor> :> monitor
            "directory/file" touch-file
            "file" +add-file+ monitor expect-change
          ]
        ] with-monitors
    ] with-test-directory
] unit-test

! A failed constructor must release its queue and partially installed watches.
{ t } [
    [
        "file" touch-file
        [
            disposables get cardinality
            [ "file" f <monitor> ] [ errno>> ENOTDIR = ] must-fail-with
            disposables get cardinality =
        ] with-monitors
    ] with-test-directory
] unit-test
