! Verify the production signature without creating a dialog or requiring a display.
USING: accessors alien.c-types alien.syntax eval io.encodings.utf8 io.files
kernel sequences splitting tools.test words ;
IN: file-picker.linux.varargs.tests

C-TYPE: GtkWidget
C-TYPE: GtkWindow
TYPEDEF: char gchar
TYPEDEF: int gint
TYPEDEF: int GtkFileChooserAction

<<
"resource:extra/file-picker/linux/linux.factor" utf8 file-contents
"FUNCTION: GtkWidget* gtk_file_chooser_dialog_new" split1 nip ")" split1 drop
"FUNCTION: GtkWidget* gtk_file_chooser_dialog_new" prepend ")" append
"USING: alien.syntax alien.c-types file-picker.linux.varargs.tests ; IN: file-picker.linux.varargs.tests LIBRARY: gtk " prepend
( -- ) eval
>>

{ 4 } [ \ gtk_file_chooser_dialog_new def>> 4 swap nth ] unit-test
{ 8 } [ \ gtk_file_chooser_dialog_new "declared-effect" word-prop in>> length ] unit-test
