;;; fuel-table.el -- table creation

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Tue Jan 06, 2009 13:44

;;; Comentary:

;; Utilities to insert ascii tables.

;;; Code:

(defun fuel-table--col-widths (rows)
  (let* ((col-no (length (car rows)))
         (available (- (window-width) 2 (* 2 col-no)))
         (widths)
         (c 0))
    (while (< c col-no)
      (let ((width 0)
            (av-width (- available (* 5 (- col-no c)))))
        (dolist (row rows)
          (setq width
                (min av-width
                     (max width (length (nth c row))))))
        (push width widths)
        (setq available (- available width)))
      (setq c (1+ c)))
    (reverse widths)))

(defun fuel-table--pad-str (str width)
  (let ((len (length str)))
    (cond ((= len width) str)
          ((> len width) (concat (substring str 0 (- width 3)) "..."))
          (t (concat str (make-string (- width (length str)) ?\ ))))))

(defun fuel-table--str-lines (str width)
  (if (<= (length str) width)
      (list (fuel-table--pad-str str width))
    (with-temp-buffer
      (let ((fill-column width))
        (insert str)
        (fill-region (point-min) (point-max))
        (mapcar '(lambda (s) (fuel-table--pad-str s width))
                (split-string (buffer-string) "\n"))))))

(defun fuel-table--pad-row (row)
  (let* ((max-ln (apply 'max (mapcar 'length row)))
         (result))
    (dolist (lines row)
      (let ((ln (length lines)))
        (if (= ln max-ln) (push lines result)
          (let ((lines (reverse lines))
                (l 0)
                (blank (make-string (length (car lines)) ?\ )))
            (while (< l ln)
              (push blank lines)
              (setq l (1+ l)))
            (push (reverse lines) result)))))
    (reverse result)))

(defun fuel-table--format-rows (rows widths)
  (let ((col-no (length (car rows)))
        (frows))
    (dolist (row rows)
      (let ((c 0) (frow))
        (while (< c col-no)
          (push (fuel-table--str-lines (nth c row) (nth c widths)) frow)
          (setq c (1+ c)))
        (push (fuel-table--pad-row (reverse frow)) frows)))
    (reverse frows)))

(defun fuel-table--insert (rows)
  (let* ((widths (fuel-table--col-widths rows))
         (rows (fuel-table--format-rows rows widths))
         (ls (concat "+" (mapconcat (lambda (n) (make-string n ?-)) widths "-+") "-+")))
    (insert ls "\n")
    (dolist (r rows)
      (let ((ln (length (car r)))
            (l 0))
        (while (< l ln)
          (insert (concat "|" (mapconcat 'identity
                                         (mapcar `(lambda (x) (nth ,l x)) r)
                                         " |")
                          " |\n"))
          (setq l (1+ l))))
      (insert ls "\n"))))


(provide 'fuel-table)
;;; fuel-table.el ends here
