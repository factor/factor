! Copyright (C) 2014, 2015 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings alien.syntax destructors
file-picker gobject-introspection.standard-types gtk2.ffi
io.encodings.utf8 kernel locals namespaces system ui.gadgets.worlds ;
IN: file-picker.linux

<PRIVATE

LIBRARY: gtk

FUNCTION: GtkWidget* gtk_file_chooser_dialog_new (
    gchar* title,
    GtkWindow* parent,
    GtkFileChooserAction action,
    gchar* first_button_text,
    gint first_button_response,
    gchar* second_button_text,
    gint second_button_response,
    void* sentinel )

:: <gtk-file-chooser-dialog> ( title action -- dialog )
    title utf8 string>alien
    ! Current active window becomes the parent
    world get handle>> window>>
    GTK_FILE_CHOOSER_ACTION_OPEN
    "Cancel" utf8 string>alien
    GTK_RESPONSE_CANCEL
    action utf8 string>alien
    GTK_RESPONSE_ACCEPT
    f
    gtk_file_chooser_dialog_new &gtk_widget_destroy ;


: run-and-get-filename ( dialog -- path/f )
    dup gtk_dialog_run GTK_RESPONSE_ACCEPT = [
        gtk_file_chooser_get_filename utf8 alien>string
    ] [
        drop f
    ] if ;

PRIVATE>

M: linux open-file-dialog
    [
        "Open File" "Open" <gtk-file-chooser-dialog>
        run-and-get-filename
    ] with-destructors ;

M: linux save-file-dialog
    [
        "Save File" "Save" <gtk-file-chooser-dialog>
        dup t gtk_file_chooser_set_do_overwrite_confirmation
        dup rot utf8 string>alien gtk_file_chooser_set_filename drop
        run-and-get-filename
    ] with-destructors ;
