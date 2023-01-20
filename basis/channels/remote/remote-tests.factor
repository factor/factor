! Copyright (C) 2005 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs channels channels.remote channels.remote.private
kernel tools.test ;

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
