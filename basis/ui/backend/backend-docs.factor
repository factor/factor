USING: help.markup help.syntax ;
IN: ui.backend

HELP: stop-event-loop
{ $description "Called by the UI to tell the backend to stop itself. Only needed by the GTK backend that otherwise gets stuck in 'gtk_main'." } ;
