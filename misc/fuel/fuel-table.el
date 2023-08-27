;;; fuel-table.el -- table creation -*- lexical-binding: t -*-

;; Copyright (C) 2009 Jose Antonio Ortega Ruiz
;; See https://factorcode.org/license.txt for BSD license.

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
        (mapcar #'(lambda (s) (fuel-table--pad-str s width))
                (split-string (buffer-string) "\n"))))))

(defun fuel-table--pad-cell (lines max-ln)
  (let* ((ln (length lines))
         (blank (make-string (length (car lines)) ?\ ))
         (n-extra (max (- max-ln ln) 0)))
    (append lines (make-list n-extra blank))))

(defun fuel-table--pad-row (row)
  (let* ((max-ln (apply 'max (mapcar 'length row)))
         (result))
    (dolist (lines row)
      (push (fuel-table--pad-cell lines max-ln) result))
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

;; These all need to be ascii to ensure the tables get rendered
;; properly no matter the font.
(defvar fuel-table-corner-lt "+")
(defvar fuel-table-corner-lb "+")
(defvar fuel-table-corner-rt "+")
(defvar fuel-table-corner-rb "+")
(defvar fuel-table-line "-")
(defvar fuel-table-tee-t "+")
(defvar fuel-table-tee-b "+")
(defvar fuel-table-tee-l "|")
(defvar fuel-table-tee-r "|")
(defvar fuel-table-crux "+")
(defvar fuel-table-sep "|")

(defun fuel-table--insert-line (widths first last sep)
  (insert first fuel-table-line)
  (dolist (w widths)
    (while (> w 0)
      (insert fuel-table-line)
      (setq w (1- w)))
    (insert fuel-table-line sep fuel-table-line))
  (delete-char -2)
  (insert fuel-table-line last)
  (newline))

(defun fuel-table--insert-first-line (widths)
  (fuel-table--insert-line widths
                           fuel-table-corner-lt
                           fuel-table-corner-rt
                           fuel-table-tee-t))

(defun fuel-table--insert-middle-line (widths)
  (fuel-table--insert-line widths
                           fuel-table-tee-l
                           fuel-table-tee-r
                           fuel-table-crux))

(defun fuel-table--insert-last-line (widths)
  (fuel-table--insert-line widths
                           fuel-table-corner-lb
                           fuel-table-corner-rb
                           fuel-table-tee-b))

(defun fuel-table--insert-row (r)
  (let ((ln (length (car r)))
        (l 0))
    (while (< l ln)
      (insert (concat fuel-table-sep " "
                      (mapconcat 'identity
                                 (mapcar `(lambda (x) (nth ,l x)) r)
                                 (concat " " fuel-table-sep " "))
                      "  " fuel-table-sep "\n"))
      (setq l (1+ l)))))

(defun fuel-table--insert (rows)
  (let* ((widths (fuel-table--col-widths rows))
         (rows (fuel-table--format-rows rows widths)))
    (fuel-table--insert-first-line widths)
    (dolist (r rows)
      (fuel-table--insert-row r)
      (fuel-table--insert-middle-line widths))
    (kill-line -1)
    (fuel-table--insert-last-line widths)))


(provide 'fuel-table)

;;; fuel-table.el ends here
