USING: accessors arrays calendar kernel namespaces sequences tools.test
urls webapps.mason.backend xml.writer ;
IN: webapps.mason.downloads

{ "<p>No machines.</p>" } [
    { } builder-list xml>string
] unit-test

: new-builder ( -- builder )
    builder new "test-host" >>host-name "linux" >>os "x86.32" >>cpu ;

! A heartbeat can register a machine before its first build or report.
{ t t } [
    new-builder now >>heartbeat-timestamp 1array
    [ machine-list xml>string "test-host" subseq-of? ]
    [ builder-list xml>string "No report yet" subseq-of? ] bi
] unit-test

{ t } [
    new-builder 1array builder-list xml>string
    "OFFLINE" subseq-of?
] unit-test

{ "—" "No report yet" } [
    new-builder [ builder-duration ] [ builder-report ] bi
] unit-test

! The first build has a start time but no previous report timestamp.
{ t } [
    new-builder now >>start-timestamp builder-duration empty? not
] unit-test

{ "00:01:00" t } [
    URL" /" url set
    new-builder
    2026 9 25 <date> >>start-timestamp
    2026 9 25 <date> 1 minutes time+ >>last-timestamp
    "report" >>last-report
    [ builder-duration ]
    [ builder-report xml>string "<a href=" subseq-of? ] bi
] unit-test
