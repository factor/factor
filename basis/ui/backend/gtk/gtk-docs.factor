USING: alien byte-arrays gdk.ffi gtk.ffi help.markup help.syntax
kernel ;
IN: ui.backend.gtk

HELP: configure-im
{ $values { "win" GtkWindow } { "im" GtkIMContext } }
{ $description "Configures the input methods of the window. Must only be run after the window has been realized." }
{ $see-also gtk_widget_realize } ;

HELP: icon-data
{ $var-description "Contains a " { $link byte-array } " or " { $link f } " which is the data for the icon to be used for gtk windows. The variable is updated to contain a vocab-specific icon when deploying. See " { $link "vocabs.icons" } " and 'tools.deploy.shaker.strip-gtk-icon'." } ;

HELP: on-configure
{ $values
  { "win" alien }
  { "event" alien }
  { "user-data" alien }
  { "?" boolean }
}
{ $description "Handles a configure event (" { $link GdkEventConfigure } " sent from the windowing system. If the world has been sent the on-map event from gtk then it is relayouted, otherwise nothing happens." } ;
