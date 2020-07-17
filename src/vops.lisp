(in-package :sb-vm)

(define-vop (play-with-blas::saxpy-kernel)
  (:translate play-with-blas::saxpy-kernel)
  (:policy :fast-safe)
  (:args (n1 :scs (unsigned-reg))
         (a  :scs (single-reg))
         (x :scs (sap-reg))
         (y :scs (sap-reg)))
  (:arg-types unsigned-num
              single-float
              system-area-pointer
              system-area-pointer)
  (:temporary (:sc single-avx2-reg) ra)
  (:temporary (:sc single-avx2-reg) rx)
  (:temporary (:sc single-avx2-reg) ry)
  (:temporary (:sc unsigned-reg) index)
  (:generator
   10
   (inst vbroadcastss ra a)
   (inst xor index index)
   LOOP
   (inst vmovups
         rx
         (ea 0 x index 4))
   (inst vmovups
         ry
         (ea 0 y index 4))
   (inst vfmadd231ps ry ra rx)
   (inst vmovups
         (ea 0 y index 4)
         ry)
   (inst add index 8)
   (inst sub n1 8)
   (inst jmp :nz loop)))

(define-vop (play-with-blas::saxpy-kernel/unroll-4)
  (:translate play-with-blas::saxpy-kernel)
  (:policy :fast-safe)
  (:args (n1 :scs (unsigned-reg))
         (a  :scs (single-reg))
         (x :scs (sap-reg))
         (y :scs (sap-reg)))
  (:arg-types unsigned-num
              single-float
              system-area-pointer
              system-area-pointer)
  (:temporary (:sc single-avx2-reg) ra)
  (:temporary (:sc single-avx2-reg) rx0)
  (:temporary (:sc single-avx2-reg) rx1)
  (:temporary (:sc single-avx2-reg) rx2)
  (:temporary (:sc single-avx2-reg) rx3)
  (:temporary (:sc single-avx2-reg) ry0)
  (:temporary (:sc single-avx2-reg) ry1)
  (:temporary (:sc single-avx2-reg) ry2)
  (:temporary (:sc single-avx2-reg) ry3)
  (:temporary (:sc unsigned-reg) index)
  (:generator
   5
   (inst vbroadcastss ra a)
   (inst xor index index)
   LOOP
   (inst vmovups
         rx0
         (ea 0 x index 4))
   (inst vmovups
         rx1
         (ea 32 x index 4))
   (inst vmovups
         rx2
         (ea 64 x index 4))
   (inst vmovups
         rx3
         (ea 96 x index 4))

   (inst vmovups
         ry0
         (ea 0 y index 4))
   (inst vmovups
         ry1
         (ea 32 y index 4))
   (inst vmovups
         ry2
         (ea 64 y index 4))
   (inst vmovups
         ry3
         (ea 96 y index 4))

   (inst vfmadd231ps ry0 ra rx0)
   (inst vfmadd231ps ry1 ra rx1)
   (inst vfmadd231ps ry2 ra rx2)
   (inst vfmadd231ps ry3 ra rx3)

   (inst vmovups
         (ea 0 y index 4)
         ry0)
   (inst vmovups
         (ea 32 y index 4)
         ry1)
   (inst vmovups
         (ea 64 y index 4)
         ry2)
   (inst vmovups
         (ea 96 y index 4)
         ry3)

   (inst add index 32)
   (inst sub n1 32)
   (inst jmp :nz loop)))

(define-vop (play-with-blas::saxpy-kernel/unroll-4-mem)
  (:translate play-with-blas::saxpy-kernel)
  (:policy :fast-safe)
  (:args (n1 :scs (unsigned-reg))
         (a  :scs (single-reg))
         (x :scs (sap-reg))
         (y :scs (sap-reg)))
  (:arg-types unsigned-num
              single-float
              system-area-pointer
              system-area-pointer)
  (:temporary (:sc single-avx2-reg) ra)
  (:temporary (:sc single-avx2-reg) ry0)
  (:temporary (:sc single-avx2-reg) ry1)
  (:temporary (:sc single-avx2-reg) ry2)
  (:temporary (:sc single-avx2-reg) ry3)
  (:temporary (:sc unsigned-reg) index)
  (:generator
   4
   (inst vbroadcastss ra a)
   (inst xor index index)
   LOOP
   (inst vmovups
         ry0
         (ea (* 0 32) y index 4))
   (inst vmovups
         ry1
         (ea (* 1 32) y index 4))
   (inst vmovups
         ry2
         (ea (* 2 32) y index 4))
   (inst vmovups
         ry3
         (ea (* 3 32) y index 4))

   (inst vfmadd231ps ry0 ra (ea (* 0 32) x index 4))
   (inst vfmadd231ps ry1 ra (ea (* 1 32) x index 4))
   (inst vfmadd231ps ry2 ra (ea (* 2 32) x index 4))
   (inst vfmadd231ps ry3 ra (ea (* 3 32) x index 4))

   (inst vmovups
         (ea (* 0 32) y index 4)
         ry0)
   (inst vmovups
         (ea (* 1 32) y index 4)
         ry1)
   (inst vmovups
         (ea (* 2 32) y index 4)
         ry2)
   (inst vmovups
         (ea (* 3 32) y index 4)
         ry3)

   (inst add index (* 4 8))
   (inst sub n1 (* 4 8))
   (inst jmp :nz loop)))
