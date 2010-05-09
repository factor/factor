! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings gtk gobject.ffi gtk.ffi io.encodings.utf8
kernel locals ;
IN: gir.samples.lowlevel.hello-world

:: hello-world-win ( -- window )  
    GTK_WINDOW_TOPLEVEL gtk_window_new :> window

    window
    [ "Hello world!" utf8 string>alien gtk_window_set_title ]
    [ 300 200 gtk_window_set_default_size ]
    [ GTK_WIN_POS_CENTER gtk_window_set_position ] tri

    gtk_fixed_new :> frame
    window frame gtk_container_add
    
    "Say 'Hello!'" utf8 string>alien gtk_button_new_with_label :> button
    button 140 30 gtk_widget_set_size_request
    frame button 80 60 gtk_fixed_put

    "" utf8 string>alien gtk_label_new :> label
    frame label 120 110 gtk_fixed_put

    button "clicked" utf8 string>alien
    [ nip "Hello! :)" utf8 string>alien gtk_label_set_text 1 ] GtkButton:clicked
    label f 0 g_signal_connect_data drop
    
    window ;

:: hello-world-main ( -- )
    f f gtk_init
    hello-world-win :> window

    window "destroy" utf8 string>alien
    [ 2drop gtk_main_quit ] GtkObject:destroy
    f f 0 g_signal_connect_data drop

    window gtk_widget_show_all
    
    gtk_main ;

MAIN: hello-world-main

