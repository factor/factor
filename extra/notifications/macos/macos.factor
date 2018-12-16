! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.application cocoa.classes kernel locals ;
IN: notifications.macos

IMPORT: NSUserNotification
IMPORT: NSUserNotificationCenter

:: make-notification ( title text -- notification )
    NSUserNotification send: alloc send: init send: autorelease
    [ title <NSString> send: \setTitle: ] keep
    [ text <NSString> send: \setInformativeText: ] keep ;

: send-notification ( title text -- )
    make-notification
    [
        NSUserNotificationCenter send: defaultUserNotificationCenter
    ] dip
    send: \deliverNotification: ;
