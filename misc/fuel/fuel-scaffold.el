;;; fuel-scaffold.el -- interaction with tools.scaffold

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Sun Jan 11, 2009 18:40

;;; Comentary:

;; Utilities for creating new vocabulary files and other boilerplate.
;; Mainly, an interface to Factor's tools.scaffold.

;;; Code:

(require 'fuel-eval)
(require 'fuel-edit)
(require 'fuel-syntax)
(require 'fuel-base)


;;; Customisation:

(defgroup fuel-scaffold nil
  "Options for FUEL's scaffolding."
  :group 'fuel)

(defcustom fuel-scaffold-developer-name user-full-name
  "The name to be inserted as yours in scaffold templates."
  :type 'string
  :group 'fuel-scaffold)


;;; Auxiliary functions:

(defun fuel-scaffold--vocab-roots ()
  (let ((cmd '(:fuel* (vocab-roots get :get) "fuel")))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))


;;; User interface:

(defun fuel-scaffold-vocab (&optional other-window name-hint root-hint)
  "Creates a directory in the given root for a new vocabulary and
adds source, tests and authors.txt files.

You can configure `fuel-scaffold-developer-name' (set by default to
`user-full-name') for the name to be inserted in the generated files."
  (interactive)
  (let* ((name (read-string "Vocab name: " name-hint))
         (root (completing-read "Vocab root: "
                                (fuel-scaffold--vocab-roots)
                                nil t (or root-hint "resource:")))
         (cmd `(:fuel* ((,root ,name ,fuel-scaffold-developer-name)
                        (fuel-scaffold-vocab)) "fuel"))
         (ret (fuel-eval--send/wait cmd))
         (file (fuel-eval--retort-result ret)))
    (unless file
      (error "Error creating vocab (%s)" (car (fuel-eval--retort-error ret))))
    (if other-window (find-file-other-window file) (find-file file))
    (goto-char (point-max))
    name))

(defun fuel-scaffold-help (&optional arg)
  "Creates, if it does not already exist, a help file with
scaffolded help for each word in the current vocabulary.

With prefix argument, ask for the vocabulary name.
You can configure `fuel-scaffold-developer-name' (set by default to
`user-full-name') for the name to be inserted in the generated file."
  (interactive "P")
  (let* ((vocab (or (and (not arg) (fuel-syntax--current-vocab))
                    (fuel-completion--read-vocab nil)))
         (cmd `(:fuel* (,vocab ,fuel-scaffold-developer-name fuel-scaffold-help)
                       "fuel"))
         (ret (fuel-eval--send/wait cmd))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating help file" (car (fuel-eval--retort-error ret))))
        (find-file file)))


(provide 'fuel-scaffold)
;;; fuel-scaffold.el ends here
