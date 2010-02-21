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

(defcustom fuel-scaffold-developer-name nil
  "The name to be inserted as yours in scaffold templates."
  :type '(choice string
                 (const :tag "Factor's value for developer-name" nil))
  :group 'fuel-scaffold)


;;; Auxiliary functions:

(defun fuel-scaffold--vocab-roots ()
  (let ((cmd '(:fuel* (vocab-roots get :get) "fuel")))
    (fuel-eval--retort-result (fuel-eval--send/wait cmd))))

(defun fuel-scaffold--dev-name ()
  (or fuel-scaffold-developer-name
      (let ((cmd '(:fuel* (developer-name get :get) "fuel")))
        (fuel-eval--retort-result (fuel-eval--send/wait cmd)))
      "Your name"))

(defun fuel-scaffold--first-vocab ()
  (goto-char (point-min))
  (re-search-forward fuel-syntax--current-vocab-regex nil t))

(defsubst fuel-scaffold--vocab (file)
  (save-excursion
    (set-buffer (find-file-noselect file))
    (fuel-scaffold--first-vocab)
    (fuel-syntax--current-vocab)))

(defconst fuel-scaffold--tests-header-format
  "! Copyright (C) %s %s
! See http://factorcode.org/license.txt for BSD license.
USING: %s tools.test ;
IN: %s
")

(defsubst fuel-scaffold--check-auto (var)
  (and var (or (eq var 'always) (y-or-n-p "Insert template? "))))

(defun fuel-scaffold--tests (parent)
  (when (and parent (fuel-scaffold--check-auto fuel-scaffold-test-autoinsert-p))
    (let ((year (format-time-string "%Y"))
          (name (fuel-scaffold--dev-name))
          (vocab (fuel-scaffold--vocab parent)))
      (insert (format fuel-scaffold--tests-header-format
                      year name vocab vocab))
      t)))

(defsubst fuel-scaffold--create-docs (vocab)
  (let ((cmd `(:fuel* (,vocab ,fuel-scaffold-developer-name fuel-scaffold-help)
                      "fuel")))
    (fuel-eval--send/wait cmd)))

(defsubst fuel-scaffold--create-tests (vocab)
  (let ((cmd `(:fuel* (,vocab ,fuel-scaffold-developer-name fuel-scaffold-tests)
                      "fuel")))
    (fuel-eval--send/wait cmd)))

(defsubst fuel-scaffold--create-authors (vocab)
  (let ((cmd `(:fuel* (,vocab ,fuel-scaffold-developer-name fuel-scaffold-authors) "fuel")))
    (fuel-eval--send/wait cmd)))

(defsubst fuel-scaffold--create-tags (vocab tags)
  (let ((cmd `(:fuel* (,vocab ,tags fuel-scaffold-tags) "fuel")))
    (fuel-eval--send/wait cmd)))

(defsubst fuel-scaffold--create-summary (vocab summary)
  (let ((cmd `(:fuel* (,vocab ,summary fuel-scaffold-summary) "fuel")))
    (fuel-eval--send/wait cmd)))

(defun fuel-scaffold--help (parent)
  (when (and parent (fuel-scaffold--check-auto fuel-scaffold-help-autoinsert-p))
    (let* ((ret (fuel-scaffold--create-docs (fuel-scaffold--vocab parent)))
           (file (fuel-eval--retort-result ret)))
      (when file
        (revert-buffer t t t)
        (when (and fuel-scaffold-help-header-only-p
                   (fuel-scaffold--first-vocab))
          (delete-region (1+ (point)) (point-max))
          (save-buffer))
        (message "Inserting template ... done."))
      (goto-char (point-min)))))

(defun fuel-scaffold--maybe-insert ()
  (ignore-errors
    (or (fuel-scaffold--tests (factor-mode--in-tests))
        (fuel-scaffold--help (factor-mode--in-docs)))))


;;; User interface:

(defun fuel-scaffold-vocab (&optional other-window name-hint root-hint)
  "Creates a directory in the given root for a new vocabulary and
adds source and authors.txt files. Prompts the user for optional summary,
tags, help, and test file creation.

You can configure `fuel-scaffold-developer-name' (set by default to
`user-full-name') for the name to be inserted in the generated files."
  (interactive)
  (let* ((name (read-string "Vocab name: " name-hint))
         (root (completing-read "Vocab root: "
                                (fuel-scaffold--vocab-roots)
                                nil t (or root-hint "resource:")))
         (summary (read-string "Vocab summary (empty for none): "))
         (tags (read-string "Vocab tags (empty for none): "))
         (help (y-or-n-p "Scaffold help? "))
         (tests (y-or-n-p "Scaffold tests? "))
         (cmd `(:fuel* ((,root ,name ,fuel-scaffold-developer-name)
                        (fuel-scaffold-vocab)) "fuel"))
         (ret (fuel-eval--send/wait cmd))
         (file (fuel-eval--retort-result ret)))
    (unless file
      (error "Error creating vocab (%s)" (car (fuel-eval--retort-error ret))))
    (when (not (equal "" summary))
      (fuel-scaffold--create-summary name summary))
    (when (not (equal "" tags))
      (fuel-scaffold--create-tags name tags))
    (when help
         (fuel-scaffold--create-docs name))
    (when tests
         (fuel-scaffold--create-tests name))
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
         (ret (fuel-scaffold--create-docs vocab))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating help file" (car (fuel-eval--retort-error ret))))
        (find-file file)))

(defun fuel-scaffold-tests (&optional arg)
  "Creates, if it does not already exist, a tests file for the current vocabulary.

With prefix argument, ask for the vocabulary name.
You can configure `fuel-scaffold-developer-name' (set by default to
`user-full-name') for the name to be inserted in the generated file."
  (interactive "P")
  (let* ((vocab (or (and (not arg) (fuel-syntax--current-vocab))
                    (fuel-completion--read-vocab nil)))
         (ret (fuel-scaffold--create-tests vocab))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating tests file" (car (fuel-eval--retort-error ret))))
        (find-file file)))

(defun fuel-scaffold-authors (&optional arg)
  "Creates, if it does not already exist, an authors file for the current vocabulary.

With prefix argument, ask for the vocabulary name.
You can configure `fuel-scaffold-developer-name' (set by default to
`user-full-name') for the name to be inserted in the generated file."
  (interactive "P")
  (let* ((vocab (or (and (not arg) (fuel-syntax--current-vocab))
                    (fuel-completion--read-vocab nil)))
         (ret (fuel-scaffold--create-authors vocab))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating authors file" (car (fuel-eval--retort-error ret))))
        (find-file file)))

(defun fuel-scaffold-tags (&optional arg)
  "Creates, if it does not already exist, a tags file for the current vocabulary."
  (interactive "P")
  (let* ((vocab (or (and (not arg) (fuel-syntax--current-vocab))
                    (fuel-completion--read-vocab nil)))
         (tags (read-string "Tags: "))
         (ret (fuel-scaffold--create-tags vocab tags))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating tags file" (car (fuel-eval--retort-error ret))))
        (find-file file)))

(defun fuel-scaffold-summary (&optional arg)
  "Creates, if it does not already exist, a summary file for the current vocabulary."
  (interactive "P")
  (let* ((vocab (or (and (not arg ) (fuel-syntax--current-vocab))
                    (fuel-completion--read-vocab nil)))
         (summary (read-string "Summary: "))
         (ret (fuel-scaffold--create-summary vocab summary))
         (file (fuel-eval--retort-result ret)))
        (unless file
          (error "Error creating summary file" (car (fuel-eval--retort-error ret))))
        (find-file file)))


(provide 'fuel-scaffold)
;;; fuel-scaffold.el ends here
