! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: models source-files.errors namespaces models.delay init
kernel calendar ;
IN: tools.errors.model

SYMBOLS: (error-list-model) error-list-model ;

SINGLETON: updater

M: updater errors-changed
    drop f (error-list-model) get-global set-model ;

[
    f <model> (error-list-model) set-global
    (error-list-model) get-global 100 milliseconds <delay> error-list-model set-global
    updater add-error-observer
] "ui.tools.error-list" add-startup-hook

