USING: accessors alien alien.c-types alien.strings alien.syntax
combinators continuations destructors file-picker glib.ffi gobject.ffi gobject-introspection.standard-types
io.encodings.utf8 io.pathnames kernel locals math namespaces
sequences tools.test ui.backend ui.gadgets.worlds vocabs.parser ;
<<
ui-backend get name>> {
    { "gtk2-ui-backend" [ "gtk2.ffi" use-vocab ] }
    { "gtk3-ui-backend" [ "gtk3.ffi" use-vocab ] }
} case
>>
IN: file-picker.linux.tests
TUPLE: picker-parent window ;
SYMBOLS: observed-action observed-name inspection-attempts ;

:: picker-window ( -- dialog )
    gtk_window_list_toplevels :> windows
    [
        windows g_list_length <iota> [ windows swap g_list_nth_data ] map
        [ "GtkFileChooserDialog" utf8 string>alien g_type_from_name g_type_check_instance_is_a ] find nip
        dup [ "No file chooser window" throw ] unless
    ] [ windows g_list_free ] finally ;

:: inspect-picker ( data -- continue? )
    [
        picker-window :> dialog
        dialog gtk_file_chooser_get_action :> action
        action observed-action set-global
        action GTK_FILE_CHOOSER_ACTION_SAVE = [
            dialog gtk_file_chooser_get_filename [
                &g_free utf8 alien>string file-name
            ] [ f ] if* observed-name set-global
        ] when
        inspection-attempts [ 1 + ] change-global
        action GTK_FILE_CHOOSER_ACTION_OPEN = observed-name get or
        inspection-attempts get 100 >= or [
            dialog GTK_RESPONSE_CANCEL gtk_dialog_response f
        ] [ t ] if
    ] with-destructors ;

: cancel-callback ( -- cb )
    gboolean { gpointer } cdecl [ inspect-picker ] alien-callback ;

: with-picker-inspection ( ..a quot: ( ..a -- ..b ) -- ..b )
    f observed-name set-global
    0 inspection-attempts set-global
    [ cancel-callback ] dip '[
        10 swap f g_timeout_add drop
        world new picker-parent new >>handle world _ with-variable
    ] with-callback ; inline

f f gtk_init_check [ "GTK init failed" throw ] unless

{ f t } [
    [ "nonexistent-new-file.txt" save-file-dialog ] with-picker-inspection
    observed-action get GTK_FILE_CHOOSER_ACTION_SAVE =
] unit-test
{ "nonexistent-new-file.txt" } [ observed-name get ] unit-test
{ f t } [
    [ open-file-dialog ] with-picker-inspection
    observed-action get GTK_FILE_CHOOSER_ACTION_OPEN =
] unit-test
