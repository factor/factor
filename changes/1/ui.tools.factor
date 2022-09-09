USING: io.pathnames namespaces ui.backend ui.tools.listener ui.tools.environment ;
IN: ui.tools

: ui-tools-main ( -- )
    f ui-stop-after-last-window? set-global
    environment-window ;
