! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test math assocs channels channels.remote ;
IN: temporary

{ t } [
    remote-channels assoc?
] unit-test

{ t f } [
    <channel> publish [
        get-channel channel?
    ] keep 
    [ unpublish ] keep
    get-channel
] unit-test

