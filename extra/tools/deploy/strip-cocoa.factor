USING: cocoa cocoa.messages cocoa.application cocoa.nibs
assocs namespaces kernel words compiler sequences ui.cocoa ;

"stop-after-last-window?" get
global [
    stop-after-last-window? set

    [ "MiniFactor.nib" load-nib ] cocoa-init-hook set-global

    ! Only keeps those methods that we actually call
    sent-messages get super-sent-messages get union
    objc-methods [ intersect ] change

    sent-messages get
    super-sent-messages get
    [ keys [ objc-methods get at dup ] H{ } map>assoc ] 2apply
    super-message-senders [ intersect ] change
    message-senders [ intersect ] change

    sent-messages off
    super-sent-messages off

    ! We need this for strip-stack-traces to work fully
    { message-senders super-message-senders }
    [
        get values [
            dup update-xt compile
        ] each
    ] each
] bind
