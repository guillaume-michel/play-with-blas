(in-package :play-with-blas)

(defun saxpy (a x y)
  (declare (optimize (speed 3) (debug 0) (safety 0))
           (type single-float a)
           (type (simple-array single-float (*)) x y))
  (let ((n (array-dimension x 0)))
    ;;(declare (type fixnum n))
    (unless (= n 0)
      (let ((n1 (logand n -32)))
        ;;(declare (type fixnum n1))
        (unless (= n1 0)
          (let ((data-x (simple-array-vector x))
                (data-y (simple-array-vector y)))
            ;;(declare (type (simple-array single-float (*)) data-x data-y))
            (sb-sys:with-pinned-objects (a data-x data-y)
              (let* ((reg-a (avx2:replicate-float a))
                     (sap-x (sb-sys:vector-sap data-x))
                     (sap-y (sb-sys:vector-sap data-y)))
                ;; (declare (type (sb-ext:simd-pack-256 single-float) reg-a)
                ;;          (type sb-sys:system-area-pointer sap-x sap-y))
                (loop :for i ;; :of-type fixnum
                   :below n1 :by 8 :do
                     (avx2:f8-store i
                                    sap-y
                                    (avx2:f8-fma (avx2:f8-load i sap-y)
                                                 reg-a
                                                 (avx2:f8-load i sap-x))))))))
        (loop :for i ;; :of-type fixnum
           :from n1 :below n :by 1 :do
             (incf (aref y i) (* (aref x i) a)))))))

(defun saxpy2 (a x y)
  (declare (optimize (speed 3) (debug 0) (safety 0))
           (type single-float a)
           (type (simple-array single-float (*)) x y))
  (let ((n (array-dimension x 0)))
    ;;(declare (type fixnum n))
    (unless (= n 0)
      (let ((n1 (logand n (- (* 4 8)))))
        ;;(declare (type fixnum n1))
        (unless (= n1 0)
          (let ((data-x (simple-array-vector x))
                (data-y (simple-array-vector y)))
            ;;(declare (type (simple-array single-float (*)) data-x data-y))
            (sb-sys:with-pinned-objects (a data-x data-y)
              (let* ((sap-x (sb-sys:vector-sap data-x))
                     (sap-y (sb-sys:vector-sap data-y)))
                ;; (declare (type sb-sys:system-area-pointer sap-x sap-y))
                (saxpy-kernel n1 a sap-x sap-y)))))
        (loop :for i ;; :of-type fixnum
           :from n1 :below n :by 1 :do
             (incf (aref y i) (* (aref x i) a)))))))

(defun ref-saxpy (a x y)
  (declare (optimize (speed 3) (debug 0) (safety 0))
           (type single-float a)
           (type (simple-array single-float (*)) x y))
  (let ((n (array-dimension x 0))
        (incx 1)
        (incy 1))
    (openblas:saxpy n a x incx y incy)))

(defun test-saxpy (n saxpy &key (repeat 100) (file t))
  (let ((alpha 2.0)
        (x (make-array n :element-type 'single-float :initial-element 3.0))
        (y (make-array n :element-type 'single-float :initial-element 4.0)))
    (multiple-value-bind (res real run)
        (timings
          (dotimes (i repeat)
            (funcall saxpy alpha x y)))
      (declare (ignore res run))
      (format file "~A,~A~%" n (/ (* 2 n repeat) (* real 1000000000))))))
