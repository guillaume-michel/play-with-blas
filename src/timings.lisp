(in-package :play-with-blas)

(defmacro timings (&body forms)
  (let ((real1 (gensym))
        (real2 (gensym))
        (run1 (gensym))
        (run2 (gensym))
        (result (gensym)))
    `(let* ((,real1 (get-internal-real-time))
            (,run1 (get-internal-run-time))
            (,result (progn ,@forms))
            (,run2 (get-internal-run-time))
            (,real2 (get-internal-real-time)))
       (values ,result
               (float (/ (- ,real2 ,real1) internal-time-units-per-second))
               (float (/ (- ,run2 ,run1) internal-time-units-per-second))))))
