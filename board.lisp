(defun make-bb-from-string (b)
  (declare (optimize speed (safety 0)) 
           (type string b))
  (the (unsigned-byte 64) (parse-integer b :radix 2)))

(defun make-bb-string-from-vector (v)
  (declare (type (simple-array (mod 2) (8 8)) v))
  (let ((ret ""))
    (dotimes (x 8)
      (dotimes (y 8)
        (setq ret (concatenate 'string ret 
                               (write-to-string (aref v x y))))))
    ret))

(defun make-bb (contents)
  (make-bb-from-string 
   (make-bb-string-from-vector
    (make-array '(8 8) :element-type '(mod 2) 
		:initial-contents contents))))

(defun transpose (x) (apply #'mapcar (cons #'list x)))
(defun inverse (x) (mapcar (lambda (y) (mapcar (lambda (z) (- 1 z)) y)) x))

(defconstant full-rank (list 1 1 1 1 1 1 1 1))
(defconstant empty-rank (list 0 0 0 0 0 0 0 0))


(defmacro make-precomputed-table (name list)
  `(declaim (type (simple-array (unsigned-byte 64) (8)) ,name))
  `(defconstant ,name
                (make-array 8 :element-type '(unsigned-byte 64)
                            :initial-contents (mapcar #'make-bb ,list))))


(defconstant clear-rank-list
  (let ((rank-list '()))
    (dotimes (rank 8)
      (let ((this-list (make-list 8 :initial-element full-rank)))
	(setf (nth rank this-list) empty-rank)
	(push this-list rank-list)))
    rank-list))

(make-precomputed-table clear-rank clear-rank-list)

(defun 1-at (n)
  (let ((line empty-rank))
    (loop
       for cell on line
       for i from 0
       when (< i n) collect (car cell)
       else collect 1
       and nconc (rest cell)
       and do (loop-finish))))



;(declaim (type (simple-array (unsigned-byte 64) (8)) clear-rank))
;(defconstant clear-rank 
;             (make-array 8 :element-type '(unsigned-byte 64)
;                         :initial-contents (mapcar #'make-bb clear-rank-list)))
(defconstant clear-file-list
            (mapcar #'transpose clear-rank-list))

(make-precomputed-table clear-file clear-file-list)

(defconstant mask-rank-list
             (mapcar #'inverse clear-rank-list))

(make-precomputed-table mask-rank mask-rank-list)

(defconstant mask-file-list
             (mapcar #'transpose mask-rank-list))

(make-precomputed-table mask-file mask-file-list)

(defconstant diagonal-ones-list
  (loop
     for i from 0 below 8
       collect (1-at i)))

(defun padlist (l)
  (if (< (length l) 8)
      (padlist (cons empty-rank l)) l))

(defconstant upper-left-diagonals-list
  (loop
     for i from 0 below 8
       collect (reverse (padlist 
			 (reverse (nthcdr i diagonal-ones-list))))))

(princ upper-left-diagonals-list)

(make-precomputed-table upper-left-diagonals 
			upper-left-diagonals-list)

(defconstant lower-right-diagonals-list
  (reverse (mapcar #'reverse upper-left-diagonals-list)))

(make-precomputed-table lower-right-diagonals
			lower-right-diagonals-list)

(defconstant upper-right-diagonals-list
  (reverse (mapcar #'reverse (mapcar #'reverse upper-left-diagonals-list))))


(make-precomputed-table upper-right-diagonals
			upper-right-diagonals-list)

(defconstant lower-left-diagonals-list
  (reverse (mapcar (lambda (l) (reverse (mapcar #'reverse l))) 
		   upper-left-diagonals-list)))


(make-precomputed-table lower-left-diagonals
			lower-left-diagonals-list)


