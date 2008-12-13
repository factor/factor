;;; fuel-eval.el --- evaluating Factor expressions

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages
;; Start date: Tue Dec 02, 2008

;;; Commentary:

;; Protocols for sending evaluations to the Factor listener.

;;; Code:

(require 'fuel-base)
(require 'fuel-syntax)
(require 'fuel-connection)


;;; Retort and retort-error datatypes:

(defsubst fuel-eval--retort-make (err result &optional output)
  (list err result output))

(defsubst fuel-eval--retort-error (ret) (nth 0 ret))
(defsubst fuel-eval--retort-result (ret) (nth 1 ret))
(defsubst fuel-eval--retort-output (ret) (nth 2 ret))

(defsubst fuel-eval--retort-p (ret) (listp ret))

(defsubst fuel-eval--make-parse-error-retort (str)
  (fuel-eval--retort-make (cons 'fuel-parse-retort-error str) nil))

(defun fuel-eval--parse-retort (str)
  (save-current-buffer
    (condition-case nil
        (let ((ret (car (read-from-string str))))
          (if (fuel-eval--retort-p ret) ret (error)))
      (error (fuel-eval--make-parse-error-retort str)))))

(defsubst fuel-eval--error-name (err) (car err))

(defsubst fuel-eval--error-restarts (err)
  (cdr (assoc :restarts (fuel-eval--error-name-p err 'condition))))

(defun fuel-eval--error-name-p (err name)
  (unless (null err)
    (or (and (eq (fuel-eval--error-name err) name) err)
        (assoc name err))))

(defsubst fuel-eval--error-file (err)
  (nth 1 (fuel-eval--error-name-p err 'source-file-error)))

(defsubst fuel-eval--error-lexer-p (err)
  (or (fuel-eval--error-name-p err 'lexer-error)
      (fuel-eval--error-name-p (fuel-eval--error-name-p err 'source-file-error)
                               'lexer-error)))

(defsubst fuel-eval--error-line/column (err)
  (let ((err (fuel-eval--error-lexer-p err)))
    (cons (nth 1 err) (nth 2 err))))

(defsubst fuel-eval--error-line-text (err)
  (nth 3 (fuel-eval--error-lexer-p err)))


;;; String sending::

(defvar fuel-eval-log-max-length 16000)

(defvar fuel-eval--default-proc-function nil)
(defsubst fuel-eval--default-proc ()
  (and fuel-eval--default-proc-function
       (funcall fuel-eval--default-proc-function)))

(defvar fuel-eval--proc nil)

(defvar fuel-eval--log t)

(defvar fuel-eval--sync-retort nil)

(defun fuel-eval--send/wait (str &optional timeout buffer)
  (setq fuel-eval--sync-retort nil)
  (fuel-con--send-string/wait (or fuel-eval--proc (fuel-eval--default-proc))
                              str
                              '(lambda (s)
                                 (setq fuel-eval--sync-retort
                                       (fuel-eval--parse-retort s)))
                              timeout
                              buffer)
  fuel-eval--sync-retort)

(defun fuel-eval--send (str cont &optional buffer)
  (fuel-con--send-string (or fuel-eval--proc (fuel-eval--default-proc))
                         str
                         `(lambda (s) (,cont (fuel-eval--parse-retort s)))
                         buffer))


;;; Evaluation protocol

(defsubst fuel-eval--factor-array (strs)
  (format "V{ %S }" (mapconcat 'identity strs " ")))

(defun fuel-eval--cmd/lines (strs &optional no-rs in usings)
  (unless (and in usings) (fuel-syntax--usings-update))
  (let* ((in (cond ((not in) (or fuel-syntax--current-vocab "f"))
                   ((eq in t) "fuel-scratchpad")
                   (in in)))
         (usings (cond ((not usings) fuel-syntax--usings)
                       ((eq usings t) nil)
                       (usings usings))))
    (format "fuel-eval-%srestartable %s %S %s fuel-eval-in-context"
            (if no-rs "non-" "")
            (fuel-eval--factor-array strs)
            in
            (fuel-eval--factor-array usings))))

(defsubst fuel-eval--cmd/string (str &optional no-rs in usings)
  (fuel-eval--cmd/lines (list str) no-rs in usings))

(defun fuel-eval--cmd/region (begin end &optional no-rs in usings)
  (let ((lines (split-string (buffer-substring-no-properties begin end)
                             "[\f\n\r\v]+" t)))
    (when (> (length lines) 0)
      (fuel-eval--cmd/lines lines no-rs in usings))))



(provide 'fuel-eval)
;;; fuel-eval.el ends here
