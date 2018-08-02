USING: furnace.recaptcha.private tools.test urls ;
IN: furnace.recaptcha.tests

{
    url"http://www.google.com/recaptcha/api/challenge"
    url"https://www.google.com/recaptcha/api/challenge"
} [
    f recaptcha-url
    t recaptcha-url
] unit-test
