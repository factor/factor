! Copyright (C) 2014, 2015 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.parser alien.strings alien.syntax
combinators destructors
file-picker glib.ffi gobject-introspection.standard-types
io.encodings.utf8 io.pathnames kernel locals namespaces system ui.backend ui.gadgets.worlds vocabs.parser ;
IN: file-picker.linux.gtk

<PRIVATE

<<
ui-backend get name>> {
    { "gtk2-ui-backend" [ "gtk2.ffi" use-vocab "gtk" ] }
    { "gtk3-ui-backend" [ "gtk3.ffi" use-vocab "gtk3" ] }
} case current-library set
>>

FUNCTION: GtkWidget* gtk_file_chooser_dialog_new (
    gchar* title,
    GtkWindow* parent,
    GtkFileChooserAction action,
    gchar* first_button_text,
    ...
    gint first_button_response,
    gchar* second_button_text,
    gint second_button_response,
    void* sentinel )

:: <gtk-file-chooser-dialog> ( title action button -- dialog )
    title utf8 string>alien
    ! Current active window becomes the parent
    world get [ handle>> [ window>> ] [ f ] if* ] [ f ] if*
    action
    "Cancel" utf8 string>alien
    GTK_RESPONSE_CANCEL
    button utf8 string>alien
    GTK_RESPONSE_ACCEPT
    f
    gtk_file_chooser_dialog_new &gtk_widget_destroy ;


: run-and-get-filename ( dialog -- path/f )
    dup gtk_dialog_run GTK_RESPONSE_ACCEPT = [
        gtk_file_chooser_get_filename [ &g_free utf8 alien>string ] [ f ] if*
    ] [
        drop f
    ] if ;

PRIVATE>

M: linux open-file-dialog
    [
        "Open File" GTK_FILE_CHOOSER_ACTION_OPEN "Open" <gtk-file-chooser-dialog>
        run-and-get-filename
    ] with-destructors ;

M: linux save-file-dialog
    [
        "Save File" GTK_FILE_CHOOSER_ACTION_SAVE "Save" <gtk-file-chooser-dialog>
        dup t gtk_file_chooser_set_do_overwrite_confirmation
        swap absolute-path [
            parent-directory utf8 string>alien over swap
            gtk_file_chooser_set_current_folder drop
        ] [ file-name utf8 string>alien over swap gtk_file_chooser_set_current_name ] bi
        run-and-get-filename
    ] with-destructors ;
