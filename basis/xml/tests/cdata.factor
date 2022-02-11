USING: xml xml.writer tools.test ;
IN: xml.tests

{
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<rss version=\"2.0\">
  <channel>
    <item>
      <description><![CDATA[Python has a n class property in [&#8230;]]]></description>
    </item>
  </channel>
</rss>"
} [
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<rss version=\"2.0\">
  <channel>
    <item>
      <description><![CDATA[Python has a n class property in [&#8230;]]]></description>
    </item>
  </channel>
</rss>" string>xml xml>string
] unit-test
