(in-package :play-with-blas)

(sb-c:defknown (saxpy-kernel) ((cl:unsigned-byte 64) ;; n1
                               (cl:single-float) ;; alpha
                               sb-sys:system-area-pointer ;; array sap x
                               sb-sys:system-area-pointer) ;; array sap y
    (cl:values)
    (sb-c:movable sb-c:always-translatable)
  :overwrite-fndb-silently cl:t)
