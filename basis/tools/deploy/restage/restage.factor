IN: tools.deploy.restage
USING: bootstrap.stage2 namespaces memory ;

: restage ( -- )
    load-components
    "output-image" get save-image-and-exit ;

MAIN: restage
