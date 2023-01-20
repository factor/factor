! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar calendar.format io io.encodings.utf8
io.sockets io.streams.byte-array literals math math.parser
namespaces sequences ;

IN: syslog

! RFC 3164 (https://www.faqs.org/rfcs/rfc3164.html)

! The first part is called the PRI, the second part is the
! HEADER, and the third part is the MSG.  The total length of
! the packet MUST be 1024 bytes or less.  There is no minimum
! length of the syslog message although sending a syslog packet
! with no contents is worthless and SHOULD NOT be transmitted.

CONSTANT: EMERGENCY  0 ! system is unusable
CONSTANT: ALERT      1 ! action must be taken immediately
CONSTANT: CRITICAL   2 ! critical conditions
CONSTANT: ERROR      3 ! error conditions
CONSTANT: WARNING    4 ! warning conditions
CONSTANT: NOTICE     5 ! normal but significant condition
CONSTANT: INFO       6 ! informational
CONSTANT: DEBUG      7 ! debug-level messages

CONSTANT: LOCAL0    16
CONSTANT: LOCAL1    17
CONSTANT: LOCAL2    18
CONSTANT: LOCAL3    19
CONSTANT: LOCAL4    20
CONSTANT: LOCAL5    21
CONSTANT: LOCAL6    22
CONSTANT: LOCAL7    23

SYMBOL: syslog-facility
LOCAL0 syslog-facility set-global

SYMBOL: syslog-server
"127.0.0.1" 514 <inet4> syslog-server set-global

<PRIVATE

: dd ( timestamp -- )
    day>> number>string 2 CHAR: \s pad-head write ;

: write-priority ( level -- )
    "<" write
    syslog-facility get-global 8 * + number>string write
    ">" write ;

: write-mdhms ( timestamp -- )
    { MONTH " " dd " " hh ":" mm ":" ss } formatted ;

: write-timestamp ( -- )
    now write-mdhms " " write ;

: write-hostname ( -- )
    host-name write " " write ;

: write-syslog ( message level -- )
    write-priority write-timestamp write-hostname write nl ;

PRIVATE>

: syslog ( message level -- )
    utf8 [ write-syslog ] with-byte-writer
    1024 index-or-length head
    syslog-server get-global
    $[ f 0 <inet4> <datagram> ]
    send ;

: log-debug ( message -- ) DEBUG syslog ;

: log-info ( message -- ) INFO syslog ;

: log-warning ( message -- ) WARNING syslog ;

: log-error ( message -- ) ERROR syslog ;

: log-critical ( message -- ) CRITICAL syslog ;

: log-alert ( message -- ) ALERT syslog ;


! Must contain only visible (printing) characters
! "<PRI>TIMESTAMP HOSTNAME"

! Example:
! <34>Oct 11 22:14:15 mymachine su: 'su root' failed for lonvick on /dev/pts/8

! relays should handle cases:
! 1) Valid PRI and TIMESTAMP
! 2) Valid PRI but no TIMESTAMP or invalid TIMESTAMP
! 3) No PRI or unidentifiable PRI
