;;; fuel-mode.el -- Minor mode enabling FUEL niceties

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 06, 2008 00:52

;;; Comentary:

;; Enhancements to vanilla factor-mode (notably, listener interaction)
;; enabled by means of a minor mode.

;;; Code:

(require 'factor-mode)
(require 'fuel-base)
(require 'fuel-syntax)
(require 'fuel-font-lock)
(require 'fuel-help)
(require 'fuel-eval)
(require 'fuel-listener)


;;; Customization:

(defgroup fuel-mode nil
  "Mode enabling FUEL's ultimate abilities."
  :group 'fuel)

(defcustom fuel-mode-autodoc-p t
  "Whether `fuel-autodoc-mode' gets enable by default in fuel buffers."
  :group 'fuel-mode
  :type 'boolean)


;;; User commands

(defun fuel-eval-definition (&optional arg)
  "Sends definition around point to Fuel's listener for evaluation.
With prefix, switchs the the listener's buffer."
  (interactive "P")
  (save-excursion
    (mark-defun)
    (let* ((begin (point))
           (end (mark)))
      (unless (< begin end) (error "No evaluable definition around point"))
      (let* ((msg (match-string 0))
             (ret (fuel-eval--eval-region/context begin end))
             (err (fuel-eval--retort-error ret)))
        (when err (error "%s" err))
        (message "%s" (fuel--shorten-region begin end 70)))))
  (when arg (pop-to-buffer fuel-listener-buffer)))


;;; Minor mode definition:

(make-variable-buffer-local
 (defvar fuel-mode-string " F"
   "Modeline indicator for fuel-mode"))

(defvar fuel-mode-map (make-sparse-keymap)
  "Key map for fuel-mode")

(define-minor-mode fuel-mode
  "Toggle Fuel's mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Fuel mode is enabled, a host of nice utilities for
interacting with a factor listener is at your disposal.
\\{fuel-mode-map}"
  :init-value nil
  :lighter fuel-mode-string
  :group 'fuel
  :keymap fuel-mode-map

  (setq fuel-autodoc-mode-string "/A")
  (when fuel-mode-autodoc-p (fuel-autodoc-mode fuel-mode)))


;;; Keys:

(defun fuel-mode--key-1 (k c)
  (define-key fuel-mode-map (vector '(control ?c) k) c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,k))  c))

(defun fuel-mode--key (p k c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,p) k) c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,p) `(control ,k)) c))

(fuel-mode--key-1 ?z 'run-factor)

(define-key fuel-mode-map "\C-\M-x" 'fuel-eval-definition)

(fuel-mode--key ?e ?d 'fuel-eval-definition)

(fuel-mode--key ?d ?a 'fuel-autodoc-mode)
(fuel-mode--key ?d ?d 'fuel-help)
(fuel-mode--key ?d ?s 'fuel-help-short)


(provide 'fuel-mode)
;;; fuel-mode.el ends here
