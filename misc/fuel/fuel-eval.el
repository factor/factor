;;; fuel-eval.el --- evaluating Factor expressions

;; Copyright (C) 2008, 2009  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages
;; Start date: Tue Dec 02, 2008

;;; Commentary:

;; Protocols for sending evaluations to the Factor listener.

;;; Code:

(require 'fuel-syntax)
(require 'fuel-connection)
(require 'fuel-log)
(require 'fuel-base)

(eval-when-compile (require 'cl))


;;; Simple sexp-based representation of factor code

(defun factor (sexp)
  (cond ((null sexp) "f")
        ((eq sexp t) "t")
        ((or (stringp sexp) (numberp sexp)) (format "%S" sexp))
        ((vectorp sexp) (factor (cons :quotation (append sexp nil))))
        ((listp sexp)
         (case (car sexp)
           (:array (factor--seq 'V{ '} (cdr sexp)))
           (:seq (factor--seq '{ '} (cdr sexp)))
           (:tuple (factor--seq 'T{ '} (cdr sexp)))
           (:quote (format "\\ %s" (factor `(:factor ,(cadr sexp)))))
           (:quotation (factor--seq '\[ '\] (cdr sexp)))
           (:using (factor `(USING: ,@(cdr sexp) :end)))
           (:factor (format "%s" (mapconcat 'identity (cdr sexp) " ")))
           (:fuel (factor--fuel-factor (cons :rs (cdr sexp))))
           (:fuel* (factor--fuel-factor (cons :nrs (cdr sexp))))
           (t (mapconcat 'factor sexp " "))))
        ((keywordp sexp)
         (factor (case sexp
                   (:rs 'fuel-eval-restartable)
                   (:nrs 'fuel-eval-non-restartable)
                   (:in (or (fuel-syntax--current-vocab) "fuel"))
                   (:usings `(:array ,@(fuel-syntax--usings)))
                   (:get 'fuel-eval-set-result)
                   (:end '\;)
                   (t `(:factor ,(symbol-name sexp))))))
        ((symbolp sexp) (symbol-name sexp))))

(defsubst factor--seq (begin end forms)
  (format "%s %s %s" begin (if forms (factor forms) "") end))

(defsubst factor--fuel-factor (sexp)
  (factor `(,(factor--fuel-restart (nth 0 sexp))
            ,(factor--fuel-lines (nth 1 sexp))
            ,(factor--fuel-in (nth 2 sexp))
            ,(factor--fuel-usings (nth 3 sexp))
            fuel-eval-in-context)))

(defsubst factor--fuel-restart (rs)
  (unless (member rs '(:rs :nrs))
    (error "Invalid restart spec (%s)" rs))
  rs)

(defsubst factor--fuel-lines (lst)
  (cons :array (mapcar 'factor lst)))

(defsubst factor--fuel-in (in)
  (cond ((or (eq in :in) (null in)) :in)
        ((eq in 'f) 'f)
        ((eq in 't) "fuel")
        ((stringp in) in)
        (t (error "Invalid 'in' (%s)" in))))

(defsubst factor--fuel-usings (usings)
  (cond ((or (null usings) (eq usings :usings)) :usings)
        ((eq usings t) nil)
        ((listp usings) `(:array ,@usings))
        (t (error "Invalid 'usings' (%s)" usings))))


;;; Code sending:

(defvar fuel-eval--default-proc-function nil)
(defsubst fuel-eval--default-proc ()
  (and fuel-eval--default-proc-function
       (funcall fuel-eval--default-proc-function)))

(defvar fuel-eval--proc nil)

(defvar fuel-eval--sync-retort nil)

(defun fuel-eval--send/wait (code &optional timeout buffer)
  (setq fuel-eval--sync-retort nil)
  (fuel-con--send-string/wait (or fuel-eval--proc (fuel-eval--default-proc))
                              (if (stringp code) code (factor code))
                              '(lambda (s)
                                 (setq fuel-eval--sync-retort
                                       (fuel-eval--parse-retort s)))
                              timeout
                              buffer)
  fuel-eval--sync-retort)

(defun fuel-eval--send (code cont &optional buffer)
  (fuel-con--send-string (or fuel-eval--proc (fuel-eval--default-proc))
                         (if (stringp code) code (factor code))
                         `(lambda (s) (,cont (fuel-eval--parse-retort s)))
                         buffer))


;;; Retort and retort-error datatypes:

(defsubst fuel-eval--retort-make (err result &optional output)
  (list err result output))

(defsubst fuel-eval--retort-error (ret) (nth 0 ret))
(defsubst fuel-eval--retort-result (ret) (nth 1 ret))
(defsubst fuel-eval--retort-output (ret) (nth 2 ret))

(defsubst fuel-eval--retort-p (ret)
  (and (listp ret) (= 3 (length ret))))

(defsubst fuel-eval--make-parse-error-retort (str)
  (fuel-eval--retort-make (cons 'fuel-parse-retort-error str) nil))

(defun fuel-eval--parse-retort (ret)
  (fuel-log--info "RETORT: %S" ret)
  (if (fuel-eval--retort-p ret) ret
    (fuel-eval--make-parse-error-retort ret)))

(defsubst fuel-eval--error-name (err) (car err))

(defun fuel-eval--error-name-p (err name)
  (unless (null err)
    (or (and (eq (fuel-eval--error-name err) name) err)
        (assoc name err))))

(defsubst fuel-eval--error-restarts (err)
  (cdr (assoc :restarts (or (fuel-eval--error-name-p err 'condition)
                            (fuel-eval--error-name-p err 'lexer-error)))))

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


(provide 'fuel-eval)
;;; fuel-eval.el ends here
