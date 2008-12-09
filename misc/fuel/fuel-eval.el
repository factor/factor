;;; fuel-eval.el --- utilities for communication with fuel-listener

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages
;; Start date: Tue Dec 02, 2008

;;; Commentary:

;; Protocols for handling communications via a comint buffer running a
;; factor listener.

;;; Code:

(require 'fuel-base)
(require 'fuel-syntax)


;;; Syncronous string sending:

(defvar fuel-eval-log-max-length 16000)

(defvar fuel-eval--default-proc-function nil)
(defsubst fuel-eval--default-proc ()
  (and fuel-eval--default-proc-function
       (funcall fuel-eval--default-proc-function)))

(defvar fuel-eval--proc nil)
(defvar fuel-eval--log t)

(defun fuel-eval--send-string (str)
  (let ((proc (or fuel-eval--proc (fuel-eval--default-proc))))
    (when proc
      (with-current-buffer (get-buffer-create "*factor messages*")
        (goto-char (point-max))
        (when (and (> fuel-eval-log-max-length 0)
                   (> (point) fuel-eval-log-max-length))
          (erase-buffer))
        (when fuel-eval--log (insert "\n>> " (fuel--shorten-str str 256)))
        (newline)
        (let ((beg (point)))
          (comint-redirect-send-command-to-process str (current-buffer) proc nil t)
          (with-current-buffer (process-buffer proc)
            (while (not comint-redirect-completed) (sleep-for 0 1)))
          (goto-char beg)
          (current-buffer))))))


;;; Evaluation protocol

(defsubst fuel-eval--retort-make (err result &optional output)
  (list err result output))

(defsubst fuel-eval--retort-error (ret) (nth 0 ret))
(defsubst fuel-eval--retort-result (ret) (nth 1 ret))
(defsubst fuel-eval--retort-output (ret) (nth 2 ret))

(defsubst fuel-eval--retort-p (ret) (listp ret))

(defsubst fuel-eval--make-parse-error-retort (str)
  (fuel-eval--retort-make 'parse-retort-error nil str))

(defun fuel-eval--parse-retort (buffer)
  (save-current-buffer
    (set-buffer buffer)
    (condition-case nil
        (read (current-buffer))
      (error (fuel-eval--make-parse-error-retort
              (buffer-substring-no-properties (point) (point-max)))))))

(defsubst fuel-eval--send/retort (str)
  (fuel-eval--parse-retort (fuel-eval--send-string str)))

(defsubst fuel-eval--eval-begin ()
  (fuel-eval--send/retort "fuel-begin-eval"))

(defsubst fuel-eval--eval-end ()
  (fuel-eval--send/retort "fuel-begin-eval"))

(defsubst fuel-eval--factor-array (strs)
  (format "V{ %S }" (mapconcat 'identity strs " ")))

(defsubst fuel-eval--eval-strings (strs &optional no-restart)
  (let ((str (format "fuel-eval-%s %s fuel-eval"
                     (if no-restart "non-restartable" "restartable")
                     (fuel-eval--factor-array strs))))
    (fuel-eval--send/retort str)))

(defsubst fuel-eval--eval-string (str &optional no-restart)
  (fuel-eval--eval-strings (list str) no-restart))

(defun fuel-eval--eval-strings/context (strs &optional no-restart)
  (let ((usings (fuel-syntax--usings-update)))
    (fuel-eval--send/retort
     (format "fuel-eval-%s %s %S %s fuel-eval-in-context"
             (if no-restart "non-restartable" "restartable")
             (fuel-eval--factor-array strs)
             (or fuel-syntax--current-vocab "f")
             (if usings (fuel-eval--factor-array usings) "f")))))

(defsubst fuel-eval--eval-string/context (str &optional no-restart)
  (fuel-eval--eval-strings/context (list str) no-restart))

(defun fuel-eval--eval-region/context (begin end &optional no-restart)
  (let ((lines (split-string (buffer-substring-no-properties begin end)
                             "[\f\n\r\v]+" t)))
    (when (> (length lines) 0)
      (fuel-eval--eval-strings/context lines no-restart))))


;;; Error parsing

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


(provide 'fuel-eval)
;;; fuel-eval.el ends here
