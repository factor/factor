! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: models source-files.errors namespaces models.delay init
kernel calendar ;
IN: tools.errors.model

SYMBOLS: (error-list-model) error-list-model ;

(error-list-model) [ f <model> ] initialize

error-list-model [ (error-list-model) get-global 100 milliseconds <delay> ] initialize

SINGLETON: updater

M: updater errors-changed drop f (error-list-model) get-global set-model ;

[ updater add-error-observer ] "ui.tools.error-list" add-init-hook

