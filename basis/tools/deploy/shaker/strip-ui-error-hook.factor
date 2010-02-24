USING: namespaces tools.deploy.config fry sequences system kernel ui ui.gadgets.worlds ;

deploy-name get "Factor" or '[
    _ " encountered an unhandled error." append
    "The application will now exit."
    system-alert die
] ui-error-hook set-global
