;;; fuel-mode.el -- Minor mode enabling FUEL niceties

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sat Dec 06, 2008 00:52

;;; Comentary:

;; Enhancements to vanilla factor-mode (notably, listener interaction)
;; enabled by means of a minor mode.

;;; Code:

(require 'fuel-listener)
(require 'fuel-completion)
(require 'fuel-debug)
(require 'fuel-debug-uses)
(require 'fuel-eval)
(require 'fuel-help)
(require 'fuel-xref)
(require 'fuel-refactor)
(require 'fuel-stack)
(require 'fuel-autodoc)
(require 'fuel-font-lock)
(require 'fuel-edit)
(require 'fuel-syntax)
(require 'fuel-base)


;;; Customization:

(defgroup fuel-mode nil
  "Mode enabling FUEL's ultimate abilities."
  :group 'fuel)

(defcustom fuel-mode-autodoc-p t
  "Whether `fuel-autodoc-mode' gets enabled by default in factor buffers."
  :group 'fuel-mode
  :group 'fuel-autodoc
  :type 'boolean)

(defcustom fuel-mode-stack-p nil
  "Whether `fuel-stack-mode' gets enabled by default in factor buffers."
  :group 'fuel-mode
  :group 'fuel-stack
  :type 'boolean)


;;; User commands

(defun fuel-mode--read-file (arg)
  (let* ((file (or (and arg (read-file-name "File: " nil (buffer-file-name) t))
                   (buffer-file-name)))
         (file (expand-file-name file))
         (buffer (find-file-noselect file)))
    (when (and  buffer
                (buffer-modified-p buffer)
                (y-or-n-p "Save file? "))
      (save-buffer buffer))
    (cons file buffer)))

(defun fuel-run-file (&optional arg)
  "Sends the current file to Factor for compilation.
With prefix argument, ask for the file to run."
  (interactive "P")
  (let* ((f/b (fuel-mode--read-file arg))
         (file (car f/b))
         (buffer (cdr f/b)))
    (when buffer
      (with-current-buffer buffer
        (let ((msg (format "Compiling %s ..." file)))
          (fuel-debug--prepare-compilation file msg)
          (message msg)
          (fuel-eval--send `(:fuel (,file fuel-run-file))
                           `(lambda (r) (fuel--run-file-cont r ,file))))))))

(defun fuel--run-file-cont (ret file)
  (if (fuel-debug--display-retort ret (format "%s successfully compiled" file))
      (message "Compiling %s ... OK!" file)
    (message "")))

(defun fuel-eval-region (begin end &optional arg)
  "Sends region to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (let* ((rstr (buffer-substring begin end))
         (lines (split-string (substring-no-properties rstr)
                              "[\f\n\r\v]+"
                              t))
         (cmd `(:fuel (,(mapcar (lambda (l) `(:factor ,l)) lines))))
         (cv (fuel-syntax--current-vocab)))
    (fuel-debug--prepare-compilation (buffer-file-name)
                                     (format "Evaluating:\n\n%s" rstr))
    (fuel-debug--display-retort
     (fuel-eval--send/wait cmd 10000)
     (format "%s%s"
             (if cv (format "IN: %s " cv) "")
             (fuel--shorten-region begin end 70))
     arg)))

(defun fuel-eval-extended-region (begin end &optional arg)
  "Sends region, extended outwards to nearest definition,
to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (fuel-eval-region (save-excursion (goto-char begin) (mark-defun) (point))
                    (save-excursion (goto-char end) (mark-defun) (mark))
                    arg))

(defun fuel-eval-definition (&optional arg)
  "Sends definition around point to Fuel's listener for evaluation.
Unless called with a prefix, switches to the compilation results
buffer in case of errors."
  (interactive "P")
  (save-excursion
    (mark-defun)
    (let* ((begin (point))
           (end (mark)))
      (unless (< begin end) (error "No evaluable definition around point"))
      (fuel-eval-region begin end arg))))

(defun fuel-update-usings (&optional arg)
  "Asks factor for the vocabularies needed by this file,
optionally updating the its USING: line.
With prefix argument, ask for the file name."
  (interactive "P")
  (let ((file (car (fuel-mode--read-file arg))))
    (when file (fuel-debug--uses-for-file file))))

(defun fuel-load-usings ()
  "Loads all vocabularies in the current buffer's USING: from.
Useful to activate autodoc help messages in a vocabulary not yet
loaded. See documentation for `fuel-autodoc-eval-using-form-p'
for details."
  (interactive)
  (message "Loading all vocabularies in USING: form ...")
  (let ((err (fuel-eval--retort-error
              (fuel-eval--send/wait '(:fuel* (t .) t :usings) 120000))))
    (message (if err "Warning: some vocabularies failed to load"
               "All vocabularies loaded"))))


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
  (when fuel-mode-autodoc-p (fuel-autodoc-mode fuel-mode))

  (setq fuel-stack-mode-string "/S")
  (when fuel-mode-stack-p (fuel-stack-mode fuel-mode)))


;;; Keys:

(defun fuel-mode--key-1 (k c)
  (define-key fuel-mode-map (vector '(control ?c) k) c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,k))  c))

(defun fuel-mode--key (p k c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,p) k) c)
  (define-key fuel-mode-map (vector '(control ?c) `(control ,p) `(control ,k)) c))

(fuel-mode--key-1 ?k 'fuel-run-file)
(fuel-mode--key-1 ?l 'fuel-run-file)
(fuel-mode--key-1 ?r 'fuel-refresh-all)
(fuel-mode--key-1 ?z 'run-factor)
(fuel-mode--key-1 ?s 'fuel-switch-to-buffer)
(define-key fuel-mode-map "\C-x4s" 'fuel-switch-to-buffer-other-window)
(define-key fuel-mode-map "\C-x5s" 'fuel-switch-to-buffer-other-frame)

(define-key fuel-mode-map "\C-\M-x" 'fuel-eval-definition)
(define-key fuel-mode-map "\C-\M-r" 'fuel-eval-extended-region)
(define-key fuel-mode-map "\M-." 'fuel-edit-word-at-point)
(define-key fuel-mode-map "\M-," 'fuel-edit-pop-edit-word-stack)
(define-key fuel-mode-map "\C-c\M-<" 'fuel-show-callers)
(define-key fuel-mode-map "\C-c\M->" 'fuel-show-callees)
(define-key fuel-mode-map (kbd "M-TAB") 'fuel-completion--complete-symbol)

(fuel-mode--key ?e ?d 'fuel-edit-word-doc-at-point)
(fuel-mode--key ?e ?e 'fuel-eval-extended-region)
(fuel-mode--key ?e ?k 'fuel-run-file)
(fuel-mode--key ?e ?l 'fuel-load-usings)
(fuel-mode--key ?e ?r 'fuel-eval-region)
(fuel-mode--key ?e ?u 'fuel-update-usings)
(fuel-mode--key ?e ?v 'fuel-edit-vocabulary)
(fuel-mode--key ?e ?w 'fuel-edit-word)
(fuel-mode--key ?e ?x 'fuel-eval-definition)

(fuel-mode--key ?x ?a 'fuel-refactor-extract-article)
(fuel-mode--key ?x ?i 'fuel-refactor-inline-word)
(fuel-mode--key ?x ?g 'fuel-refactor-make-generic)
(fuel-mode--key ?x ?r 'fuel-refactor-extract-region)
(fuel-mode--key ?x ?s 'fuel-refactor-extract-sexp)
(fuel-mode--key ?x ?v 'fuel-refactor-extract-vocab)
(fuel-mode--key ?x ?w 'fuel-refactor-rename-word)

(fuel-mode--key ?d ?> 'fuel-show-callees)
(fuel-mode--key ?d ?< 'fuel-show-callers)
(fuel-mode--key ?d ?v 'fuel-show-file-words)
(fuel-mode--key ?d ?a 'fuel-autodoc-mode)
(fuel-mode--key ?d ?p 'fuel-apropos)
(fuel-mode--key ?d ?d 'fuel-help)
(fuel-mode--key ?d ?e 'fuel-stack-effect-sexp)
(fuel-mode--key ?d ?s 'fuel-help-short)


(provide 'fuel-mode)
;;; fuel-mode.el ends here
