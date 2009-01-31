;;; fuel-autodoc.el -- doc snippets in the echo area

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 00:50

;;; Comentary:

;; Utilities for displaying information automatically in the echo
;; area.

;;; Code:

(require 'fuel-eval)
(require 'fuel-font-lock)
(require 'fuel-syntax)
(require 'fuel-base)


;;; Customization:

(defgroup fuel-autodoc nil
  "Options controlling FUEL's autodoc system."
  :group 'fuel)

(defcustom fuel-autodoc-minibuffer-font-lock t
  "Whether to use font lock for info messages in the minibuffer."
  :group 'fuel-autodoc
  :type 'boolean)



;;; Eldoc function:

(defvar fuel-autodoc--timeout 200)

(defun fuel-autodoc--word-synopsis (&optional word)
  (let ((word (or word (fuel-syntax-symbol-at-point)))
        (fuel-log--inhibit-p t))
    (when word
      (let* ((cmd (if (fuel-syntax--in-using)
                      `(:fuel* (,word fuel-vocab-summary) :in t)
                    `(:fuel* (((:quote ,word) synopsis :get)) :in)))
             (ret (fuel-eval--send/wait cmd fuel-autodoc--timeout))
             (res (fuel-eval--retort-result ret)))
        (when (and ret (not (fuel-eval--retort-error ret)) (stringp res))
          (if fuel-autodoc-minibuffer-font-lock
              (fuel-font-lock--factor-str res)
            res))))))

(make-variable-buffer-local
 (defvar fuel-autodoc--fallback-function nil))

(defun fuel-autodoc--eldoc-function ()
  (or (and fuel-autodoc--fallback-function
           (funcall fuel-autodoc--fallback-function))
      (condition-case e
          (fuel-autodoc--word-synopsis)
        (error (format "Autodoc not available (%s)"
                       (error-message-string e))))))


;;; Autodoc mode:

(make-variable-buffer-local
 (defvar fuel-autodoc-mode-string " A"
   "Modeline indicator for fuel-autodoc-mode"))

(define-minor-mode fuel-autodoc-mode
  "Toggle Fuel's Autodoc mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Autodoc mode is enabled, a synopsis of the word at point is
displayed in the minibuffer."
  :init-value nil
  :lighter fuel-autodoc-mode-string
  :group 'fuel-autodoc

  (set (make-local-variable 'eldoc-documentation-function)
       (when fuel-autodoc-mode 'fuel-autodoc--eldoc-function))
  (set (make-local-variable 'eldoc-minor-mode-string) nil)
  (eldoc-mode fuel-autodoc-mode)
  (message "Fuel Autodoc %s" (if fuel-autodoc-mode "enabled" "disabled")))


(provide 'fuel-autodoc)
;;; fuel-autodoc.el ends here
