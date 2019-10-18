;;; fuel-base.el --- Basic FUEL support code

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Basic definitions likely to be used by all FUEL modules.

;;; Code:

(defconst fuel-version "1.0")

;;;###autoload
(defsubst fuel-version ()
  "Echoes FUEL's version."
  (interactive)
  (message "FUEL %s" fuel-version))


;;; Customization:

;;;###autoload
(defgroup fuel nil
  "Factor's Ultimate Emacs Library."
  :group 'languages)


;;; Emacs compatibility:

(eval-after-load "ring"
  '(when (not (fboundp 'ring-member))
     (defun ring-member (ring item)
       (catch 'found
         (dotimes (ind (ring-length ring) nil)
           (when (equal item (ring-ref ring ind))
             (throw 'found ind)))))))

(when (not (fboundp 'completion-table-dynamic))
  (defun completion-table-dynamic (fun)
    (lexical-let ((fun fun))
      (lambda (string pred action)
        (with-current-buffer (let ((win (minibuffer-selected-window)))
                               (if (window-live-p win) (window-buffer win)
                                 (current-buffer)))
          (complete-with-action action (funcall fun string) string pred))))))

(when (not (fboundp 'looking-at-p))
  (defsubst looking-at-p (regexp)
    (let ((inhibit-changing-match-data t))
      (looking-at regexp))))


;;; Utilities

(defun fuel--shorten-str (str len)
  (let ((sl (length str)))
    (if (<= sl len) str
      (let* ((sep " ... ")
             (sepl (length sep))
             (segl (/ (- len sepl) 2)))
        (format "%s%s%s"
                (substring str 0 segl)
                sep
                (substring str (- sl segl)))))))

(defun fuel--shorten-region (begin end len)
  (fuel--shorten-str (mapconcat 'identity
                                (split-string (buffer-substring begin end) nil t)
                                " ")
                     len))

(defsubst fuel--region-to-string (begin &optional end)
  (let ((end (or end (point))))
    (if (< begin end)
        (mapconcat 'identity
                   (split-string (buffer-substring-no-properties begin end)
                                 nil
                                 t)
                   " ")
      "")))

(defsubst empty-string-p (str) (equal str ""))

(defun fuel--string-prefix-p (prefix str)
  (and (>= (length str) (length prefix))
       (string= (substring-no-properties str 0 (length prefix))
                (substring-no-properties prefix))))

(defun fuel--respecting-message (format &rest format-args)
  "Display TEXT as a message, without hiding any minibuffer contents."
  (let ((text (format " [%s]" (apply #'format format format-args))))
    (if (minibuffer-window-active-p (minibuffer-window))
        (minibuffer-message text)
      (message "%s" text))))

(provide 'fuel-base)
;;; fuel-base.el ends here
