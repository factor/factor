USING: tools.test xml.writer ;
IN: webapps.mason.downloads

{ "<p>No machines.</p>" } [
    { } builder-list xml>string
] unit-test
