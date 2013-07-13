;;; fuel-base.el --- Basic FUEL support code

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor

;;; Commentary:

;; Basic definitions likely to be used by all FUEL modules.

;;; Code:

(defconst fuel-version "1.1")

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


;;; Utilities:

(unless (fboundp 'setq-local)
  (defmacro setq-local (var val)
    (list 'set (list 'make-local-variable (list 'quote var)) val)))

(unless (fboundp 'defvar-local)
  (defmacro defvar-local (var val &optional docstring)
    (declare (debug defvar) (doc-string 3))
    (list 'progn (list 'defvar var val docstring)
          (list 'make-variable-buffer-local (list 'quote var)))))

(defun fuel-shorten-str (str len)
  (let ((sl (length str)))
    (if (<= sl len) str
      (let* ((sep " ... ")
             (sepl (length sep))
             (segl (/ (- len sepl) 2)))
        (format "%s%s%s" (substring str 0 segl)
                sep (substring str (- sl segl)))))))

(defun fuel-shorten-region (begin end len)
  (fuel-shorten-str
   (mapconcat 'identity
              (split-string (buffer-substring begin end) nil t) " ") len))

(defsubst fuel-region-to-string (begin &optional end)
  (let ((end (or end (point))))
    (if (< begin end)
        (mapconcat 'identity
                   (split-string (buffer-substring-no-properties begin end)
                                 nil t) " ") "")))

(defun fuel-respecting-message (format &rest format-args)
  "Display TEXT as a message, without hiding any minibuffer contents."
  (let ((text (format " [%s]" (apply #'format format format-args))))
    (if (minibuffer-window-active-p (minibuffer-window))
        (minibuffer-message text)
      (message "%s" text))))

(defun fuel-mode--read-file (arg)
  (let* ((file (or (and arg (read-file-name "File: " nil (buffer-file-name) t))
                   (buffer-file-name)))
         (file (expand-file-name file))
         (buffer (find-file-noselect file)))
    (when (and  buffer
                (buffer-modified-p buffer)
                (y-or-n-p "Save file? "))
      (save-buffer buffer))
    (cons file buffer)))


(provide 'fuel-base)

;;; fuel-base.el ends here
