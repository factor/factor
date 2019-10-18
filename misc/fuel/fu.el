;;; fu.el --- Startup file for FUEL

;; Copyright (C) 2008, 2009  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Code:

(setq fuel-factor-fuel-dir (file-name-directory load-file-name))

(setq fuel-factor-root-dir (expand-file-name "../../" fuel-factor-fuel-dir))

(add-to-list 'load-path fuel-factor-fuel-dir)

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))
(autoload 'factor-mode "factor-mode.el"
  "Major mode for editing Factor source." t)

(autoload 'run-factor "fuel-listener.el"
  "Start a Factor listener, or switch to a running one." t)

(autoload 'switch-to-factor "fuel-listener.el"
  "Start a Factor listener, or switch to a running one." t)

(autoload 'connect-to-factor "fuel-listener.el"
  "Connect to an external Factor listener." t)

(autoload 'fuel-autodoc-mode "fuel-help.el"
  "Minor mode showing in the minibuffer a synopsis of Factor word at point."
  t)

(autoload 'fuel-scaffold-vocab "fuel-scaffold.el"
  "Create a new Factor vocabulary." t)

(autoload 'fuel-scaffold-help "fuel-scaffold.el"
  "Create a Factor vocabulary help file." t)

(mapc (lambda (group)
        (custom-add-load group (symbol-name group))
        (custom-add-load 'fuel (symbol-name group)))
      '(fuel fuel-faces
             factor-mode
             fuel-autodoc
             fuel-stack
             fuel-help
             fuel-xref
             fuel-listener
             fuel-scaffold
             fuel-debug
             fuel-mode))

;;; fu.el ends here
