USING: namespaces tools.deploy.config fry sequences system kernel ui ui.gadgets.worlds ;

deploy-name get "Factor" or '[
    _ " encountered an error." append
    "The application encountered an error it cannot recover from and will now exit."
    system-alert die
] ui-error-hook set-global
