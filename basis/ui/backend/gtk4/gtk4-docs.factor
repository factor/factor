USING: help.markup help.syntax ;
IN: ui.backend.gtk4

ARTICLE: "ui.backend.gtk4" "GTK4 UI backend"
"The default Unix UI backend uses GTK4's GL area, event controllers, input methods, and asynchronous text clipboards. It works with X11 and Wayland."
$nl
"Select a backend when bootstrapping with " { $snippet "-ui-backend=gtk4" } " or " { $snippet "-ui-backend=gtk3" } ". Use " { $snippet "-output-image=" } " to keep separate images. GTK3 and GTK4 cannot coexist in one process, so this option does not switch a running or already-built image."
$nl
"GTK4 delegates absolute window positioning and individual title-bar button policy to the window manager. Captured-input mode hides the cursor and focuses the drawable; GTK4 has no portable API for pointer confinement."
$nl
"See the " { $url "https://docs.gtk.org/gtk4/migrating-3to4.html" "GTK migration guide" } " for platform API changes." ;

ABOUT: "ui.backend.gtk4"
