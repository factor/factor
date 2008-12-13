;;; fuel-base.el --- Basic FUEL support code

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
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
  "Factor's Ultimate Emacs Library"
  :group 'language)


;;; Emacs compatibility:

(eval-after-load "ring"
  '(when (not (fboundp 'ring-member))
     (defun ring-member (ring item)
       (catch 'found
         (dotimes (ind (ring-length ring) nil)
           (when (equal item (ring-ref ring ind))
             (throw 'found ind)))))))


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

(defsubst empty-string-p (str) (equal str ""))

(provide 'fuel-base)
;;; fuel-base.el ends here
