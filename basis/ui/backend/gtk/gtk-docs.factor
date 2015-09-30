USING: gtk.ffi help.markup help.syntax ;
IN: ui.backend.gtk

HELP: configure-im
{ $values { "win" GtkWindow } { "im" GtkIMContext } }
{ $description "Configures the input methods of the window. Must only be run after the window has been realized." }
{ $see-also gtk_widget_realize } ;
