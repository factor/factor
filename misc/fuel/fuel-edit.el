;;; fuel-edit.el -- utilities for file editing -*- lexical-binding: t -*-

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Mon Jan 05, 2009 21:16

;;; Comentary:

;; Locating and opening factor source and documentation files.

;;; Code:

(require 'fuel-completion)
(require 'fuel-eval)
(require 'fuel-base)
(require 'factor-mode)
(require 'xref)

(require 'etags)


;;; Customization

(defcustom fuel-edit-word-method nil
  "How the new buffer is opened when invoking `fuel-edit-word-at-point'."
  :group 'fuel
  :type '(choice (const :tag "Other window" window)
                 (const :tag "Other frame" frame)
                 (const :tag "Current window" nil)))


;;; Auxiliar functions:

(defun fuel-edit--visit-file (file method)
  (cond ((eq method 'window) (find-file-other-window file))
        ((eq method 'frame) (find-file-other-frame file))
        (t (find-file file))))

(defun fuel-edit--try-edit (ret)
  (let* ((err (fuel-eval--retort-error ret))
         (loc (fuel-eval--retort-result ret)))
    (when (or err (not loc) (not (listp loc)) (not (stringp (car loc))))
      (error "Couldn't find edit location"))
    (unless (file-readable-p (car loc))
      (error "Couldn't open '%s' for read" (car loc)))
    (fuel-edit--visit-file (car loc) fuel-edit-word-method)
    (goto-char (point-min))
    (forward-line (1- (if (numberp (cadr loc)) (cadr loc) 1)))))

(defun fuel-edit--edit-article (name)
  (let ((cmd `(:fuel* (,name fuel-get-article-location) "fuel" t)))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))


;;; Editing commands:

(defvar fuel-edit--word-history nil)

;;;###autoload
(defun fuel-edit-vocabulary (&optional refresh vocab)
  "Visits vocabulary file in Emacs.
When called interactively, asks for vocabulary with completion.
With prefix argument, refreshes cached vocabulary list."
  (interactive "P")
  (let* ((vocab (or vocab (fuel-completion--read-vocab refresh)))
         (cmd `(:fuel* (,vocab fuel-get-vocab-location) "fuel" t)))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))

;;;###autoload
(defun fuel-edit-word-at-point (&optional arg)
  "Opens a new window visiting the definition of the word at point.
With prefix, asks for the word to edit."
  (interactive "P")
  (let* ((word (or (and (not arg) (factor-symbol-at-point))
                   (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel* ((:quote ,word) fuel-get-word-location)))
         (marker (and (not arg) (point-marker))))
    (if (and (not arg) (factor-on-vocab))
        (fuel-edit-vocabulary nil word)
      (fuel-edit--try-edit (fuel-eval--send/wait cmd)))
    (when marker (xref-push-marker-stack marker))))

(defun fuel-edit-word-doc-at-point (&optional arg word)
  "Opens a new window visiting the documentation file for the word at point.
With prefix, asks for the word to edit."
  (interactive "P")
  (let* ((word (or word
                   (and (not arg) (factor-symbol-at-point))
                   (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel* ((:quote ,word) fuel-get-doc-location)))
         (marker (and (not arg) (point-marker))))
    (condition-case nil
        (fuel-edit--try-edit (fuel-eval--send/wait cmd))
      (error
       (message "Documentation for '%s' not found" word)
       (when (and (eq major-mode 'factor-mode)
                  (y-or-n-p (concat "No documentation found. "
                                    "Do you want to open the vocab's "
                                    "doc file? ")))
         (when marker (xref-push-marker-stack marker))
         (find-file-other-window
          (format "%s-docs.factor"
                  (file-name-sans-extension (buffer-file-name)))))))))

(defun fuel-edit-pop-edit-word-stack ()
  "Pop back to where \\[fuel-edit-word-at-point] or \\[fuel-edit-word-doc-at-point]
was last invoked."
  (interactive)
  (condition-case nil
      (pop-tag-mark)
    (error "No previous location for find word or vocab invocation")))

(defvar fuel-edit--buffer-history nil)

(defun fuel-switch-to-buffer (&optional method)
  "Switch to any of the existing Factor buffers, with completion."
  (interactive)
  (let ((buffer (completing-read "Factor buffer: "
                                 (remove (buffer-name)
                                         (mapcar 'buffer-name (buffer-list)))
                                 #'(lambda (s) (string-match "\\.factor$" s))
                                 t
                                 nil
                                 fuel-edit--buffer-history)))
    (cond ((eq method 'window) (switch-to-buffer-other-window buffer))
          ((eq method 'frame) (switch-to-buffer-other-frame buffer))
          (t (switch-to-buffer buffer)))))

(defun fuel-switch-to-buffer-other-window ()
  "Switch to any of the existing Factor buffers, in other window."
  (interactive)
  (fuel-switch-to-buffer 'window))

(defun fuel-switch-to-buffer-other-frame ()
  "Switch to any of the existing Factor buffers, in other frame."
  (interactive)
  (fuel-switch-to-buffer 'frame))


(provide 'fuel-edit)
;;; fuel-edit.el ends here
