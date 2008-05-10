USING: cocoa cocoa.messages cocoa.application cocoa.nibs
assocs namespaces kernel words compiler.units sequences
ui ui.cocoa ;

"stop-after-last-window?" get
global [
    stop-after-last-window? set

    [ "MiniFactor.nib" load-nib ] cocoa-init-hook set-global

    ! Only keeps those methods that we actually call
    sent-messages get super-sent-messages get assoc-union
    objc-methods [ assoc-intersect ] change

    sent-messages get
    super-sent-messages get
    [ keys [ objc-methods get at dup ] H{ } map>assoc ] bi@
    super-message-senders [ assoc-intersect ] change
    message-senders [ assoc-intersect ] change

    sent-messages off
    super-sent-messages off

    ! We need this for strip-stack-traces to work fully
    { message-senders super-message-senders }
    [ get values compile ] each
] bind
