! Exercise the public picker API with real GTK4 dialogs and Factor's UI loop.
USING: accessors alien alien.strings arrays assocs calendar continuations
debugger destructors environment file-picker file-picker.linux.gtk4.private gio.ffi
glib.ffi gobject.ffi gtk4.ffi io io.encodings.utf8 io.pathnames kernel
locals math namespaces sequences system threads tools.test ui ui.gadgets.labels
ui.gadgets.worlds ;
IN: file-picker.linux.gtk4.tests

! Inspect GTK's in-process dialogs regardless of the desktop portal service.
! Production leaves portal selection to GTK and the desktop.
"no-portals" "GDK_DEBUG" set-os-env

{ t t f } [
    "gtk-dialog-error-quark" GTK_DIALOG_ERROR_DISMISSED "cancelled" \ g-error boa picker-cancelled?
    "g-io-error-quark" G_IO_ERROR_CANCELLED "cancelled" \ g-error boa picker-cancelled?
    "gtk-dialog-error-quark" GTK_DIALOG_ERROR_FAILED "failed" \ g-error boa picker-cancelled?
] unit-test

! Callback failures must reach the caller and release its pending request.
[
    f begin-picker [ [ "picker failure" throw ] complete-picker ] dip await-picker
] [ "picker failure" = ] must-fail-with
{ t } [ picker-requests get-global assoc-empty? ] unit-test

SYMBOLS: observed-action observed-name observed-parent picker-test-parent ;

: picker-error ( error -- ) print-error nl flush 1 exit ;

:: picker-window ( -- dialog/f )
    gtk_window_get_toplevels :> windows
    windows g_list_model_get_n_items <iota> [
        windows swap g_list_model_get_item &g_object_unref
    ] map
    [
        [ "GtkFileChooser" utf8 string>alien g_type_from_name g_type_check_instance_is_a ]
        [ gtk_widget_get_visible ] bi and
    ] find nip ;

:: inspect-picker ( path/f accept? -- )
    ! Waiting in a Factor thread also verifies the async dialog leaves its
    ! caller suspended while the UI loop continues to schedule other work.
    0 :> attempts!
    f :> dialog!
    [ dialog not ] [
        20 milliseconds sleep
        picker-window dialog!
        attempts 1 + attempts!
        attempts 250 > [ "File picker did not appear" throw ] when
    ] while
    dialog gtk_file_chooser_get_action observed-action set-global
    dialog gtk_window_get_transient_for picker-test-parent get handle>> window>> =
    observed-parent set-global
    dialog gtk_file_chooser_get_action GTK_FILE_CHOOSER_ACTION_SAVE = [
        dialog gtk_file_chooser_get_current_name &g_free utf8 alien>string observed-name set-global
    ] when
    path/f [ dialog swap path>file f gtk_file_chooser_set_file drop ] when*
    ! A chooser may defer acceptance until its directory has loaded.
    0 attempts!
    [ dialog gtk_widget_get_visible ] [
        100 milliseconds sleep
        dialog accept? [ GTK_RESPONSE_ACCEPT ] [ GTK_RESPONSE_CANCEL ] if gtk_dialog_response
        attempts 1 + attempts!
        attempts 50 > [ "File picker did not respond" throw ] when
    ] while ;

:: with-inspector ( path/f accept? quot -- result )
    f observed-name set-global
    [ [ [ path/f accept? inspect-picker ] with-destructors ] [ picker-error ] recover ]
    "File picker inspector" spawn drop
    [ quot call ] [ picker-error ] recover ; inline

:: run-picker-tests ( parent -- )
    500 milliseconds sleep
    parent picker-test-parent set-global
    parent world [
        { f t t } [
            f f [ open-file-dialog ] with-inspector
            observed-action get GTK_FILE_CHOOSER_ACTION_OPEN =
            observed-parent get
        ] unit-test
        { f t "file-picker-λ-new.txt" } [
            f f [ "/tmp/file-picker-λ-new.txt" save-file-dialog ] with-inspector
            observed-action get GTK_FILE_CHOOSER_ACTION_SAVE =
            observed-name get
        ] unit-test
        { t } [
            "resource:extra/file-picker/file-picker.factor" absolute-path
            dup t [ open-file-dialog ] with-inspector =
        ] unit-test
        { "/tmp/file-picker-λ-new.txt" } [
            f t [ "/tmp/file-picker-λ-new.txt" save-file-dialog ] with-inspector
        ] unit-test
        ! Exercise the pre-4.10 native chooser on current GTK4 as well.
        { f } [
            f f [ [ f run-native-dialog ] with-destructors ] with-inspector
        ] unit-test
        { "/tmp/file-picker-λ-new.txt" } [
            f t [ [ "/tmp/file-picker-λ-new.txt" run-native-dialog ] with-destructors ] with-inspector
        ] unit-test
        { t } [ picker-requests get-global assoc-empty? ] unit-test
    ] with-variable
    close-all-windows ;

[ picker-error ] ui-error-hook set-global
[
    "Native file picker tests" <label> "File picker tests" open-window*
    '[ _ [ run-picker-tests ] [ picker-error ] recover ] "File picker tests" spawn drop
] with-ui
