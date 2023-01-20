;;; fuel-stack.el -- stack inference help -*- lexical-binding: t -*-

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 20, 2008 01:08

;;; Comentary:

;; Utilities and a minor mode to show inferred stack effects in the
;; echo area.

;;; Code:

(require 'fuel-autodoc)
(require 'fuel-eval)
(require 'fuel-base)
(require 'factor-mode)


;;; Customization

;;;###autoload
(defgroup fuel-stack nil
  "Customization for FUEL's stack inference engine."
  :group 'fuel)

(defface fuel-stack-region-face '((t (:inherit highlight)))
  "Highlights the region being stack inferenced."
  :group 'fuel-stack
  :group 'fuel-faces
  :group 'fuel)

(defcustom fuel-stack-highlight-period 1.0
  "Time, in seconds, the region is highlighted when showing its
stack effect.

Set it to 0 to disable highlighting."
  :group 'fuel-stack
  :type 'float)

(defcustom fuel-stack-mode-show-sexp-p t
  "Whether to show in the echo area the sexp together with its stack effect."
  :group 'fuel-stack
  :type 'boolean)


;;; Querying for stack effects

(defun fuel-stack--infer-effect (str)
  (let ((cmd `(:fuel*
               ((:using stack-checker effects)
                ([ (:factor ,str) ] infer effect>string)))))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd 500))))

(defsubst fuel-stack--infer-effect/prop (str)
  (let ((e (fuel-stack--infer-effect str)))
    (when e
      (put-text-property 0 (length e) 'face 'factor-font-lock-stack-effect e))
    e))

(defvar fuel-stack--overlay
  (let ((overlay (make-overlay 0 0)))
    (overlay-put overlay 'face 'fuel-stack-region-face)
    (delete-overlay overlay)
    overlay))

(defun fuel-stack-effect-region (begin end)
  "Displays the inferred stack effect of the code in current region."
  (interactive "r")
  (when (> fuel-stack-highlight-period 0)
    (move-overlay fuel-stack--overlay begin end))
  (condition-case nil
      (let* ((str (fuel-region-to-string begin end))
             (effect (fuel-stack--infer-effect/prop str)))
        (if effect (message "%s" effect)
          (message "Couldn't infer effect for '%s'"
                   (fuel-shorten-region begin end 60)))
        (sit-for fuel-stack-highlight-period))
    (error))
  (delete-overlay fuel-stack--overlay))

(defun fuel-stack-effect-sexp (&optional arg)
  "Displays the inferred stack effect for the current sexp.
With prefix argument, use current region instead"
  (interactive "P")
  (if arg
      (call-interactively 'fuel-stack-effect-region)
    (fuel-stack-effect-region (1+ (factor-beginning-of-sexp-pos))
                              (if (looking-at-p ";")
                                  (point)
                                (save-excursion
                                  (factor-end-of-symbol) (point))))))


;;; Stack mode:

(defvar-local fuel-stack-mode-string " S"
  "Modeline indicator for fuel-stack-mode")

(defvar-local fuel-stack--region-function
  '(lambda ()
     (fuel-region-to-string (1+ (factor-beginning-of-sexp-pos)))))

(defun fuel-stack--eldoc ()
  (when (looking-at-p " \\|$")
    (let* ((r (funcall fuel-stack--region-function))
           (e (and r
                   (not (string-match "^ *$" r))
                   (fuel-stack--infer-effect/prop r))))
      (when e
        (if fuel-stack-mode-show-sexp-p
            (concat (fuel-shorten-str r 30) " -> " e)
          e)))))

;;;###autoload
(define-minor-mode fuel-stack-mode
  "Toggle Fuel's Stack mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Stack mode is enabled, inferred stack effects for current
sexp are automatically displayed in the echo area."
  :init-value nil
  :lighter fuel-stack-mode-string
  :group 'fuel-stack

  (setq fuel-autodoc--fallback-function
        (when fuel-stack-mode 'fuel-stack--eldoc))
  (setq-local eldoc-minor-mode-string nil)
  (unless fuel-autodoc-mode
    (setq-local eldoc-documentation-function
                (when fuel-stack-mode 'fuel-stack--eldoc))
    (eldoc-mode fuel-stack-mode)
    (message "Fuel Stack Autodoc %s" (if fuel-stack-mode "enabled" "disabled"))))


(provide 'fuel-stack)
;;; fuel-stack.el ends here
