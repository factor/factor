USING: calendar destructors glib.backend glib.ffi kernel locals
math system threads tools.test ;
IN: glib.backend.tests

:: timer-progress-during-events ( -- ? )
    f :> woke?!
    nano-count 1,000,000,000 + :> deadline
    [
        g_idle_source_new &g_source_unref :> source
        source G_PRIORITY_HIGH_IDLE g_source_set_priority
        source [ drop t ] GSourceFunc f f g_source_set_callback
        source f g_source_attach drop
        [ 10 milliseconds sleep t woke?! ] "Timer test" spawn drop
        [
            [ nano-count deadline < woke? not and ]
            [ f f g_main_context_iteration drop ] while
        ] with-timer
        source g_source_destroy
    ] with-destructors
    woke? ;

{ t } [ timer-progress-during-events ] unit-test
