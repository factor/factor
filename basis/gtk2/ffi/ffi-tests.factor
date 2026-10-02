USING: accessors alien.c-types alien.libraries alien.syntax
gobject-introspection.standard-types gtk2.ffi kernel sequences
system tools.test vocabs vocabs.loader words ;
IN: gtk2.ffi.tests

! Callers compiled before reload must still refer to the corrected binding.
{ t } [
    \ gtk_im_context_get_preedit_string
    "gtk2.ffi" reload
    dup target-word eq?
] unit-test

! GtkApplication belongs to GTK3; GTK2 must expose its own container API.
{ f t t } [
    "gtk_application_new" "gtk2.ffi" lookup-word >boolean
    "gtk_hbox_new" "gtk2.ffi" lookup-word >boolean
    "gtk_widget_get_allocation" "gtk2.ffi" lookup-word >boolean
] unit-test

{ t } [
    \ gtk_hbox_new def>> 3 swap nth { gboolean gint } =
] unit-test

{ t } [
    \ gtk_widget_get_allocation def>> 3 swap nth
    { pointer: GtkWidget pointer: GtkAllocation } =
] unit-test

{ t } [
    "gtk2" lookup-library path>>
    os windows? [ "libgtk-win32-2.0-0.dll" ]
    [ "libgtk-x11-2.0.so.0" ] if =
] unit-test
