USING: glib.ffi help.markup help.syntax ;
IN: glib.backend

HELP: with-timer
{ $values { "quot" "a quotation" } }
{ $description "Calls the quotation with a GLib source that services Factor's runnable and sleeping threads. The source uses " { $link G_PRIORITY_DEFAULT } " so a continuous stream of native resize or redraw events cannot starve Factor's scheduler. The source is removed when the quotation returns." } ;
