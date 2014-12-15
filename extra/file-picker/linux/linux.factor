USING: alien.c-types alien.data alien.strings alien.syntax
destructors file-picker gobject-introspection.standard-types
gtk.ffi io.encodings.string io.encodings.utf8 kernel system ;
IN: file-picker.linux

<PRIVATE

LIBRARY: gtk

FUNCTION: GtkWidget* gtk_file_chooser_dialog_new (
    gchar* title,
    GtkWindow* parent,
    GtkFileChooserAction action,
    gchar* first_button_text,
    gint* first_button_response,
    gchar* second_button_text,
    gint* second_button_response,
    void* sentinel ) ;

: <gtk-file-chooser-dialog> ( title action -- dialog )
    [
        utf8 encode
        f
        GTK_FILE_CHOOSER_ACTION_OPEN
        "Cancel" utf8 encode
        GTK_RESPONSE_CANCEL int <ref>
    ] [
        utf8 encode
        GTK_RESPONSE_ACCEPT int <ref>
        f
        gtk_file_chooser_dialog_new
        &gtk_widget_destroy
    ] bi* ;

: run-and-get-filename ( dialog -- path/f )
    dup gtk_dialog_run GTK_RESPONSE_ACCEPT = [
        gtk_file_chooser_get_filename alien>native-string
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
        dup rot gtk_file_chooser_set_filename drop
        run-and-get-filename
    ] with-destructors ;
