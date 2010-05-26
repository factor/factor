! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings byte-arrays classes.struct
glib.ffi gobject.ffi gtk.ffi io.encodings.utf8 kernel
literals locals make math prettyprint sequences specialized-arrays
gir.samples.lowlevel.hello-world
gir.samples.lowlevel.opengl
gir.samples.lowlevel.gstreamer ;
IN: gir.samples.lowlevel

SPECIALIZED-ARRAY: ulong

CONSTANT: samples {
    { "hello-world" "Simple 'Hello world!' program" [ hello-world-win ] }
    { "opengl" "GtkGLExt sample program" [ opengl-win ] }
    { "gstreamer" "Small GStreamer-based multimedia player " [ gstreamer-win ] }
}

:: list-on-row-activited ( sender path column user_data -- )
    path gtk_tree_path_get_indices *int samples nth last
    call( -- win ) gtk_widget_show_all ;

:: main ( -- )
    f f gtk_init
    
    GTK_WINDOW_TOPLEVEL gtk_window_new :> window

    window
    [ "Low-level Gtk samples" utf8 string>alien gtk_window_set_title ]
    [ 300 400 gtk_window_set_default_size ]
    [ GTK_WIN_POS_CENTER gtk_window_set_position ] tri
  
    gtk_tree_view_new :> list
    list f gtk_tree_view_set_headers_visible

    gtk_cell_renderer_text_new :> renderer
    gtk_tree_view_column_new :> column
    column "Sample" utf8 string>alien gtk_tree_view_column_set_title
    column renderer t gtk_tree_view_column_pack_start
    column renderer "markup" utf8 string>alien 0 gtk_tree_view_column_add_attribute
    list column gtk_tree_view_append_column drop

    ulong-array{ $ G_TYPE_STRING }
    [ length ] keep gtk_list_store_newv :> store

    list store gtk_tree_view_set_model

    store g_object_unref

    GtkTreeIter <struct> :> iter
    GValue <struct> :> value
    value G_TYPE_STRING g_value_init drop
    samples [
        first2 swap [ "<big><b>" % % "</b></big>\n" % % ] "" make
        value swap utf8 string>alien g_value_set_string
        store iter gtk_list_store_append
        store iter 0 value gtk_list_store_set_value
    ] each
  
    list 300 300 gtk_widget_set_size_request

    window list gtk_container_add

    list "row-activated"
    utf8 string>alien
    [ list-on-row-activited ] GtkTreeView:row-activated
    f f 0 g_signal_connect_data drop

    window "destroy" utf8 string>alien
    [ 2drop gtk_main_quit ] GtkObject:destroy
    f f 0 g_signal_connect_data drop
    
    window gtk_widget_show_all

    gtk_main ;

MAIN: main

