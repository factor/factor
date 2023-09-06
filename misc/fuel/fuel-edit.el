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

(defun fuel-edit--looking-at-vocab ()
  (save-excursion
    (factor-beginning-of-defun)
    (looking-at "USING:\\|USE:\\|IN:")))

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
(defun fuel-edit-word (&optional arg)
  "Asks for a word to edit, with completion.
With prefix, only words visible in the current vocabulary are
offered."
  (interactive "P")
  (let* ((word (fuel-completion--read-word "Edit word: "
                                           nil
                                           fuel-edit--word-history
                                           arg))
         (cmd `(:fuel* ((:quote ,word) fuel-get-word-location))))
    (fuel-edit--try-edit (fuel-eval--send/wait cmd))))

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

(defun fuel-add-help-word-template (&optional arg word)
  "Adds a help template for word at point."
  (interactive "P")
  (let* ((word (or word
                   (and (not arg) (fuel-syntax-symbol-at-point))
                   (fuel-completion--read-word "Edit word: ")))
         (cmd `(:fuel* ((:quote ,word) fuel-get-doc-location)))
         (marker (and (not arg) (point-marker)))
		 (startPoint   (save-excursion (goto-char (cdr (fuel-syntax-symbol-at-point-with-bounds)))
					   (re-search-forward "(")
					   (- (point) 1)))
		 (endPoint  (save-excursion (fuel-syntax--end-of-effect) (point)))
		 (effect   (let ((newlist ()))
					 (dolist (value (split-string  (fuel--region-to-string startPoint endPoint)) newlist)
					   (if (not (or (equal value "(") (equal value "--") (equal value ")")))
						   (setq newlist (cons value newlist))))
					 (reverse newlist)))
		 )
    (condition-case nil
        (fuel-edit--try-edit (fuel-eval--send/wait cmd))
      (error
       (message "Documentation for '%s' not found" word)
       (when
		 (and (eq major-mode 'factor-mode)
                  (y-or-n-p (concat "No documentation found. "
                                    "Do you want to open the vocab's "
                                    "doc file? ")))
         (when marker (ring-insert find-tag-marker-ring marker))
         (find-file-other-window
          (format "%s-docs.factor"
                  (file-name-sans-extension (buffer-file-name))))
		 (end-of-buffer)
		 (fuel-template--begin word)
		 (fuel-template--values effect)
		 (fuel-template--description)
		 (fuel-template--examples)
		 (fuel-template--notes)
		 (fuel-template--end)
)))))

(defun escape-string-region (start end)
  "Escape special characters in the region as if a CL string.
Inserts backslashes in front of special characters (namely backslash
and double quote) in the region, according to the Common Lisp string
escape requirements.

Note that region should only contain the characters actually
comprising the string, without the surrounding quotes."
  (interactive "*r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char start)
      (while (search-forward "\\" nil t)
 (replace-match "\\\\" nil t))
      (goto-char start)
      (while (search-forward "\"" nil t)
 (replace-match "\\\"" nil t)))))

(defun fuel-help-quote-region (start end)
  "Quotes a region as a string. Created to quote as pasted example from the listener"
  (interactive "r")
  (let ((end (or end (point))))
    (if (< start end)
		(save-excursion
			(escape-string-region start end)
			  (setq end (point))
			(let (
				  ;; (print-escape-newlines t)
				  ;; (print-quoted t)
				  (regionText (split-string (buffer-substring-no-properties start end) "\n"))
				  )
			  (goto-char start)
			  (delete-region start end)
			  (dolist (line regionText)
				(insert (format "\"%s\"\n" line))))))))

(defun fuel-help-quote-indent (start end)
  "Quotes and indents a region, presumably pasted example code."
  (interactive "r")
  (fuel-help-quote-region start end)
  (indent-region))

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
