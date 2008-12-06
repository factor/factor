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
        (when fuel-eval--log (insert "\n>> " (fuel--shorten-str str 75) "\n"))
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

(defsubst fuel-eval--error-name (err) (car err))

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

(defsubst fuel-eval--eval-strings (strs)
  (let ((str (format "%s fuel-eval" (fuel-eval--factor-array strs))))
    (fuel-eval--send/retort str)))

(defsubst fuel-eval--eval-string (str)
  (fuel-eval--eval-strings (list str)))

(defun fuel-eval--eval-strings/context (strs)
  (let ((usings (fuel-syntax--usings-update)))
    (fuel-eval--send/retort
     (format "%s %S %s fuel-eval-in-context"
             (fuel-eval--factor-array strs)
             (or fuel-syntax--current-vocab "f")
             (if usings (fuel-eval--factor-array usings) "f")))))

(defsubst fuel-eval--eval-string/context (str)
  (fuel-eval--eval-strings/context (list str)))

(defun fuel-eval--eval-region/context (begin end)
  (let ((lines (split-string (buffer-substring-no-properties begin end)
                             "[\f\n\r\v]+" t)))
    (when (> (length lines) 0)
      (fuel-eval--eval-strings/context lines))))


(provide 'fuel-eval)
;;; fuel-eval.el ends here
