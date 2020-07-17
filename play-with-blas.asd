(defsystem "play-with-blas"
  :description "Play with BLAS in Common Lisp"
  :version "0.0.1"
  :author "Guillaume MICHEL <contact@orilla.fr>"
  :license "MIT license (see COPYING)"
  :depends-on ("cl-fast-arithmetic"
               "cl-openblas")
  :components ((:static-file "COPYING")
               (:static-file "README.md")
               (:module "src"
                        :serial t
                        :components ((:file "package")
                                     (:file "array-utils")
                                     (:file "definitions")
                                     (:file "vops")
                                     (:file "stubs")
                                     (:file "timings")
                                     (:file "axpy")))))
