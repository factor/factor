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
(require 'fuel-debug)
(require 'fuel-help)
(require 'fuel-eval)
(require 'fuel-completion)
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

(defun fuel-run-file (&optional arg)
  "Sends the current file to Factor for compilation.
With prefix argument, ask for the file to run."
  (interactive "P")
  (let* ((file (or (and arg (read-file-name "File: " nil (buffer-file-name) t))
                   (buffer-file-name)))
         (file (expand-file-name file))
         (buffer (find-file-noselect file)))
    (when buffer
      (with-current-buffer buffer
        (message "Compiling %s ..." file)
        (fuel-eval--send `(:fuel (,file fuel-run-file))
                         `(lambda (r) (fuel--run-file-cont r ,file)))))))

(defun fuel--run-file-cont (ret file)
  (if (fuel-debug--display-retort ret
                                  (format "%s successfully compiled" file)
                                  nil
                                  file)
      (message "Compiling %s ... OK!" file)
    (message "")))

(defun fuel-eval-region (begin end &optional arg)
  "Sends region to Fuel's listener for evaluation.
Unless called with a prefix, switchs to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (let* ((lines (split-string (buffer-substring-no-properties begin end)
                              "[\f\n\r\v]+" t))
         (cmd `(:fuel (,(mapcar (lambda (l) `(:factor ,l)) lines))))
         (cv (fuel-syntax--current-vocab)))
    (fuel-debug--display-retort
     (fuel-eval--send/wait cmd 10000)
     (format "%s%s"
             (if cv (format "IN: %s " cv) "")
             (fuel--shorten-region begin end 70))
     arg
     (buffer-file-name))))

(defun fuel-eval-extended-region (begin end &optional arg)
  "Sends region extended outwards to nearest definitions,
to Fuel's listener for evaluation.
Unless called with a prefix, switchs to the compilation results
buffer in case of errors."
  (interactive "r\nP")
  (fuel-eval-region (save-excursion (goto-char begin) (mark-defun) (point))
                    (save-excursion (goto-char end) (mark-defun) (mark))
                    arg))

(defun fuel-eval-definition (&optional arg)
  "Sends definition around point to Fuel's listener for evaluation.
Unless called with a prefix, switchs to the compilation results
buffer in case of errors."
  (interactive "P")
  (save-excursion
    (mark-defun)
    (let* ((begin (point))
           (end (mark)))
      (unless (< begin end) (error "No evaluable definition around point"))
      (fuel-eval-region begin end arg))))

(defun fuel--try-edit (ret)
  (let* ((err (fuel-eval--retort-error ret))
         (loc (fuel-eval--retort-result ret)))
    (when (or err (not loc) (not (listp loc)) (not (stringp (car loc))))
      (error "Couldn't find edit location for '%s'" word))
    (unless (file-readable-p (car loc))
      (error "Couldn't open '%s' for read" (car loc)))
    (find-file-other-window (car loc))
    (goto-line (if (numberp (cadr loc)) (cadr loc) 1))))

(defun fuel-edit-word-at-point (&optional arg)
  "Opens a new window visiting the definition of the word at point.
With prefix, asks for the word to edit."
  (interactive "P")
  (let* ((word (or (and (not arg) (fuel-syntax-symbol-at-point))
                  (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel ((:quote ,word) fuel-get-edit-location))))
    (condition-case nil
        (fuel--try-edit (fuel-eval--send/wait cmd))
      (error (fuel-edit-vocabulary nil word)))))

(defvar fuel-mode--word-history nil)

(defun fuel-edit-word (&optional arg)
  "Asks for a word to edit, with completion.
With prefix, only words visible in the current vocabulary are
offered."
  (interactive "P")
  (let* ((word (fuel-completion--read-word "Edit word: "
                                           nil
                                           fuel-mode--word-history
                                           arg))
         (cmd `(:fuel ((:quote ,word) fuel-get-edit-location))))
    (fuel--try-edit (fuel-eval--send/wait cmd))))

(defvar fuel--vocabs-prompt-history nil)

(defun fuel--read-vocabulary-name (refresh)
  (let* ((vocabs (fuel-completion--vocabs refresh))
         (prompt "Vocabulary name: "))
    (if vocabs
        (completing-read prompt vocabs nil t nil fuel--vocabs-prompt-history)
      (read-string prompt nil fuel--vocabs-prompt-history))))

(defun fuel-edit-vocabulary (&optional refresh vocab)
  "Visits vocabulary file in Emacs.
When called interactively, asks for vocabulary with completion.
With prefix argument, refreshes cached vocabulary list."
  (interactive "P")
  (let* ((vocab (or vocab (fuel--read-vocabulary-name refresh)))
         (cmd `(:fuel* (,vocab fuel-get-vocab-location) "fuel" t)))
    (fuel--try-edit (fuel-eval--send/wait cmd))))


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
(fuel-mode--key-1 ?k 'fuel-run-file)
(fuel-mode--key-1 ?r 'fuel-eval-region)

(define-key fuel-mode-map "\C-\M-x" 'fuel-eval-definition)
(define-key fuel-mode-map "\C-\M-r" 'fuel-eval-extended-region)
(define-key fuel-mode-map "\M-." 'fuel-edit-word-at-point)
(define-key fuel-mode-map (kbd "M-TAB") 'fuel-completion--complete-symbol)

(fuel-mode--key ?e ?e 'fuel-eval-extended-region)
(fuel-mode--key ?e ?r 'fuel-eval-region)
(fuel-mode--key ?e ?v 'fuel-edit-vocabulary)
(fuel-mode--key ?e ?w 'fuel-edit-word)
(fuel-mode--key ?e ?x 'fuel-eval-definition)

(fuel-mode--key ?d ?a 'fuel-autodoc-mode)
(fuel-mode--key ?d ?d 'fuel-help)
(fuel-mode--key ?d ?s 'fuel-help-short)


(provide 'fuel-mode)
;;; fuel-mode.el ends here
