! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.strings gobject.ffi gtk2.ffi io.encodings.utf8
kernel ;
IN: gtk-samples.hello-world

: on-button-clicked ( button label-user-data -- )
    nip "Hello! :)" utf8 string>alien gtk_label_set_text ;

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
    [ on-button-clicked ] GtkButton:clicked label
    g_signal_connect drop

    window ;

:: hello-world-main ( -- )
    f f gtk_init
    hello-world-win :> window

    window "destroy" utf8 string>alien
    [ 2drop gtk_main_quit ] GtkObject:destroy f
    g_signal_connect drop

    window gtk_widget_show_all

    gtk_main ;

MAIN: hello-world-main
