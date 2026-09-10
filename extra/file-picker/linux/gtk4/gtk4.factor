! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries alien.strings
arrays assocs classes.struct concurrency.promises continuations destructors file-picker
gio.ffi glib.ffi gobject gobject.ffi gtk4.ffi io.encodings.utf8 io.pathnames
kernel locals namespaces sequences system ui.gadgets.worlds ;
IN: file-picker.linux.gtk4

<PRIVATE

SYMBOLS: picker-requests next-picker-request ;
picker-requests [ H{ } clone ] initialize
next-picker-request [ 1 ] initialize

TUPLE: picker-request promise save? ;
ERROR: nonlocal-file-selection ;

: picker-parent ( -- window/f )
    world get [ handle>> [ window>> ] [ f ] if* ] [ f ] if* ;

: file>path ( file/f -- path/f )
    [
        &g_object_unref g_file_get_path
        [ &g_free utf8 alien>string ] [ nonlocal-file-selection ] if*
    ] [ f ] if* ;

: path>file ( path -- file )
    utf8 string>alien g_file_new_for_path &g_object_unref ;

: picker-cancelled? ( error -- ? )
    dup domain>> "gtk-dialog-error-quark" = [
        code>> dup GTK_DIALOG_ERROR_CANCELLED = swap GTK_DIALOG_ERROR_DISMISSED = or
    ] [
        [ domain>> "g-io-error-quark" = ] [ code>> G_IO_ERROR_CANCELLED = ] bi and
    ] if ;

: check-picker-error ( GError/f -- )
    [
        GError memory>struct
        [ GError>g-error ] [ g_error_free ] bi
        dup picker-cancelled? [ drop ] [ throw ] if
    ] when* ;

:: finish-picker ( dialog result save? -- path/f )
    f void* <ref> :> error
    dialog result error save?
    [ gtk_file_dialog_save_finish ] [ gtk_file_dialog_open_finish ] if
    error void* deref check-picker-error file>path ;

! Callbacks return either a path/f or a captured error to the waiting Factor
! thread. Never unwind an exception through GTK's native callback stack.
:: complete-picker ( id quot -- )
    id alien-address picker-requests get-global delete-at* drop :> request
    [ quot call f ] [ f swap ] recover 2array request promise>> fulfill ; inline

:: on-picker-ready ( dialog result id -- )
    id alien-address picker-requests get-global at save?>> :> save?
    id [ [ dialog result save? finish-picker ] with-destructors ] complete-picker ;

:: begin-picker ( save? -- id promise )
    <promise> :> promise
    next-picker-request counter :> id
    promise save? picker-request boa id picker-requests get-global set-at
    id <alien> promise ;

: await-picker ( promise -- path/f )
    ?promise first2 [ throw ] when* ;

:: <file-dialog> ( path/f -- dialog )
    gtk_file_dialog_new &g_object_unref :> dialog
    dialog path/f [ "Save File" ] [ "Open File" ] if utf8 string>alien gtk_file_dialog_set_title
    dialog t gtk_file_dialog_set_modal
    path/f [
        absolute-path [ parent-directory path>file dialog swap gtk_file_dialog_set_initial_folder ]
        [ file-name utf8 string>alien dialog swap gtk_file_dialog_set_initial_name ] bi
    ] when*
    dialog ;

:: run-file-dialog ( path/f -- path/f )
    path/f <file-dialog> :> dialog
    path/f >boolean begin-picker :> ( id promise )
    dialog picker-parent f [ on-picker-ready ] GAsyncReadyCallback id
    path/f [ gtk_file_dialog_save ] [ gtk_file_dialog_open ] if
    promise await-picker ;

! GtkFileDialog arrived in 4.10. The native chooser keeps older GTK4
! installations working, including their desktop portal integration.
:: on-native-response ( dialog response id -- )
    id [ [
        response GTK_RESPONSE_ACCEPT =
        [ dialog gtk_file_chooser_get_file file>path ] [ f ] if
    ] with-destructors ] complete-picker ;

:: <native-dialog> ( path/f -- dialog )
    path/f [ "Save File" ] [ "Open File" ] if utf8 string>alien
    picker-parent
    path/f [ GTK_FILE_CHOOSER_ACTION_SAVE ] [ GTK_FILE_CHOOSER_ACTION_OPEN ] if
    f f gtk_file_chooser_native_new &g_object_unref :> dialog
    dialog t gtk_native_dialog_set_modal
    path/f [
        absolute-path [
            parent-directory path>file :> folder
            f void* <ref> :> error
            dialog folder error gtk_file_chooser_set_current_folder drop
            error void* deref [ GError memory>struct handle-GError ] when*
        ] [ file-name utf8 string>alien dialog swap gtk_file_chooser_set_current_name ] bi
    ] when*
    dialog ;

:: run-native-dialog ( path/f -- path/f )
    path/f <native-dialog> :> dialog
    path/f >boolean begin-picker :> ( id promise )
    dialog "response" [ on-native-response ] GtkNativeDialog:response id connect-signal-with-data
    dialog gtk_native_dialog_show
    [ promise await-picker ] [ dialog gtk_native_dialog_destroy ] finally ;

: run-picker ( path/f -- path/f )
    [
        "gtk_file_dialog_new" "gtk4" dlsym?
        [ run-file-dialog ] [ run-native-dialog ] if
    ] with-destructors ;

PRIVATE>

M: linux open-file-dialog f run-picker ;
M: linux save-file-dialog run-picker ;
