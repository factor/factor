USING: furnace.recaptcha.private tools.test urls ;
IN: furnace.recaptcha.tests

{
    URL" http://www.google.com/recaptcha/api/challenge"
    URL" https://www.google.com/recaptcha/api/challenge"
} [
    f recaptcha-url
    t recaptcha-url
] unit-test
