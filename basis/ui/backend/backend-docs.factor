USING: help.markup help.syntax ui.backend ;
IN: ui.backend+docs

HELP: stop-event-loop
{ $description "Called by the UI to tell the backend to stop itself. Only needed by the GTK backend that otherwise gets stuck in 'gtk_main'." } ;
