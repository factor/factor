USING: accessors kernel namespaces present tools.test urls
webapps.mason.backend webapps.mason.utils ;
IN: webapps.mason.utils.tests


{
    "https://builds.factorcode.org/report?os=the-os&cpu=the-cpu"
} [
    URL" /" url set
    builder new "the-os" >>os "the-cpu" >>cpu report-url
    present
] unit-test
