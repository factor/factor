! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings fry byte-arrays classes.struct
io.encodings.utf8 kernel locals math prettyprint 
gstreamer.ffi glib.ffi gobject.ffi gtk.ffi ;
IN: gir.samples.lowlevel.gstreamer

! CONSTANT: uri "http://www.xiph.org/vorbis/listen/compilation-ogg-q4.ogg"
CONSTANT: uri "http://tinyvid.tv/file/3gocxnjott7wr.ogg"

:: gstreamer-win ( -- window )
    f f gst_init
    "playbin" "player" [ utf8 string>alien ] bi@ gst_element_factory_make :> pipeline

    GValue <struct> :> value
    value G_TYPE_STRING g_value_init drop
    value uri utf8 string>alien g_value_set_string
    
    pipeline "uri" utf8 string>alien value g_object_set_property
        
    ! pipeline GST_STATE_PLAYING gst_element_set_state drop

    GTK_WINDOW_TOPLEVEL gtk_window_new :> window

    window
    [ "GStreamer" utf8 string>alien gtk_window_set_title ]
    [ 300 200 gtk_window_set_default_size ]
    [ GTK_WIN_POS_CENTER gtk_window_set_position ] tri

    gtk_fixed_new :> frame
    window frame gtk_container_add
    
    "Start" utf8 string>alien gtk_button_new_with_label :> button
    button 140 30 gtk_widget_set_size_request
    frame button 80 60 gtk_fixed_put

    button "clicked" utf8 string>alien
    [ nip GST_STATE_PLAYING gst_element_set_state drop ] GtkButton:clicked
    pipeline f 0 g_signal_connect_data drop

    window "destroy" utf8 string>alien
    [ 
        nip [ GST_STATE_NULL gst_element_set_state drop ]
        [ gst_object_unref ] bi
    ] GtkObject:destroy
    pipeline f 0 g_signal_connect_data drop
    
    window ;

:: gstreamer-main ( -- )
    f f gtk_init
    gstreamer-win :> window

    window "destroy" utf8 string>alien
    [ 2drop gtk_main_quit ] GtkObject:destroy
    f f 0 g_signal_connect_data drop

    window gtk_widget_show_all
    
    gtk_main ;

MAIN: gstreamer-main

