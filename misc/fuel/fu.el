;;; fu.el --- Startup file for FUEL

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Code:

(add-to-list 'load-path (file-name-directory load-file-name))

(add-to-list 'auto-mode-alist '("\\.factor\\'" . factor-mode))
(autoload 'factor-mode "factor-mode.el"
  "Major mode for editing Factor source." t)

(autoload 'run-factor "fuel-listener.el"
  "Start a Factor listener, or switch to a running one." t)

(autoload 'fuel-autodoc-mode "fuel-help.el"
  "Minor mode showing in the minibuffer a synopsis of Factor word at point."
  t)



;;; fu.el ends here
