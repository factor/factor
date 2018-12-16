! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.application cocoa.classes kernel locals ;
IN: notifications.macos

IMPORT: NSUserNotification
IMPORT: NSUserNotificationCenter

:: make-notification ( title text -- notification )
    NSUserNotification -> alloc -> init -> autorelease
    [ title <NSString> -> setTitle: ] keep
    [ text <NSString> -> setInformativeText: ] keep ;

: send-notification ( title text -- )
    make-notification
    [
        NSUserNotificationCenter -> defaultUserNotificationCenter
    ] dip
    -> deliverNotification: ;
