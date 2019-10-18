USING: images images.loader.gdiplus.private tools.test ;
IN: images.loader.gdiplus.tests

{ } [
    BGRA check-pixel-format
    BGRX check-pixel-format
] unit-test

[ RGB check-pixel-format ] [ unsupported-pixel-format? ] must-fail-with
