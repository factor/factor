;;; fuel-edit.el -- utilities for file editing

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Mon Jan 05, 2009 21:16

;;; Comentary:

;; Locating and opening factor source and documentation files.

;;; Code:

(require 'fuel-completion)
(require 'fuel-eval)
(require 'fuel-base)


;;; Auxiliar functions:

(defun fuel-edit--try-edit (ret)
  (let* ((err (fuel-eval--retort-error ret))
         (loc (fuel-eval--retort-result ret)))
    (when (or err (not loc) (not (listp loc)) (not (stringp (car loc))))
      (error "Couldn't find edit location"))
    (unless (file-readable-p (car loc))
      (error "Couldn't open '%s' for read" (car loc)))
    (find-file-other-window (car loc))
    (goto-line (if (numberp (cadr loc)) (cadr loc) 1))))

(defun fuel-edit--read-vocabulary-name (refresh)
  (let* ((vocabs (fuel-completion--vocabs refresh))
         (prompt "Vocabulary name: "))
    (if vocabs
        (completing-read prompt vocabs nil t nil fuel-edit--vocab-history)
      (read-string prompt nil fuel-edit--vocab-history))))

(defun fuel-edit--edit-article (name)
  (let ((cmd `(:fuel* (,name fuel-get-article-location) "fuel" t)))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))


;;; Editing commands:

(defvar fuel-edit--word-history nil)
(defvar fuel-edit--vocab-history nil)

(defun fuel-edit-vocabulary (&optional refresh vocab)
  "Visits vocabulary file in Emacs.
When called interactively, asks for vocabulary with completion.
With prefix argument, refreshes cached vocabulary list."
  (interactive "P")
  (let* ((vocab (or vocab (fuel-edit--read-vocabulary-name refresh)))
         (cmd `(:fuel* (,vocab fuel-get-vocab-location) "fuel" t)))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))

(defun fuel-edit-word (&optional arg)
  "Asks for a word to edit, with completion.
With prefix, only words visible in the current vocabulary are
offered."
  (interactive "P")
  (let* ((word (fuel-completion--read-word "Edit word: "
                                           nil
                                           fuel-edit--word-history
                                           arg))
         (cmd `(:fuel* ((:quote ,word) fuel-get-edit-location))))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))

(defun fuel-edit-word-at-point (&optional arg)
  "Opens a new window visiting the definition of the word at point.
With prefix, asks for the word to edit."
  (interactive "P")
  (let* ((word (or (and (not arg) (fuel-syntax-symbol-at-point))
                   (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel* ((:quote ,word) fuel-get-edit-location))))
    (condition-case nil
        (fuel-edit--try-edit (fuel-eval--send/wait cmd))
      (error (fuel-edit-vocabulary nil word)))))

(defun fuel-edit-word-doc-at-point (&optional arg word)
  "Opens a new window visiting the documentation file for the word at point.
With prefix, asks for the word to edit."
  (interactive "P")
  (let* ((word (or word
                   (and (not arg) (fuel-syntax-symbol-at-point))
                   (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel* ((:quote ,word) fuel-get-doc-location))))
    (condition-case nil
        (fuel-edit--try-edit (fuel-eval--send/wait cmd))
      (error
       (message "Documentation for '%s' not found" word)
       (when (and (eq major-mode 'factor-mode)
                  (y-or-n-p (concat "No documentation found. "
                                    "Do you want to open the vocab's "
                                    "doc file? ")))
         (find-file-other-window
          (format "%s-docs.factor"
                  (file-name-sans-extension (buffer-file-name)))))))))


(provide 'fuel-edit)
;;; fuel-edit.el ends here
