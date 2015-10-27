USING: alien gdk.ffi gtk.ffi help.markup help.syntax kernel ;
IN: ui.backend.gtk

HELP: configure-im
{ $values { "win" GtkWindow } { "im" GtkIMContext } }
{ $description "Configures the input methods of the window. Must only be run after the window has been realized." }
{ $see-also gtk_widget_realize } ;

HELP: on-configure
{ $values
  { "win" alien }
  { "event" alien }
  { "user-data" alien }
  { "?" boolean }
}
{ $description "Handles a configure event (" { $link GdkEventConfigure } " sent from the windowing system. The world is activated if it isn't already and a map event has been received. Then it is relayouted." } ;
