! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax byte-arrays formatting kernel
math windows.types ;
IN: windows.winmm

LIBRARY: winmm

TYPEDEF: int MCIERROR

FUNCTION: MCIERROR mciSendStringW (
  LPCTSTR lpszCommand,
  LPTSTR lpszReturnString,
  UINT cchReturn,
  HANDLE hwndCallback
)

ALIAS: mciSendString mciSendStringW

ERROR: mci-error n ;

: check-mci-error ( n -- )
    [ mci-error ] unless-zero ;

: open-command ( path -- )
    "open \"%s\" type mpegvideo alias MediaFile" sprintf f 0 f
    mciSendString check-mci-error ;

: play-command ( -- )
    "play MediaFile" f 0 f mciSendString check-mci-error ;

: pause-command ( -- )
    "pause MediaFile" f 0 f mciSendString check-mci-error ;

: status-command ( -- bytes )
    "status MediaFile mode" 128 <byte-array> [ 0 f mciSendString check-mci-error ] keep ;


: close-command ( -- )
    "close MediaFile" f 0 f mciSendString check-mci-error ;
