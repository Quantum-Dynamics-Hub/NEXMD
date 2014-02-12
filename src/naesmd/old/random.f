      real*8 function rranf()
      implicit real*8 (a-h,o-z)
      real*8 rrang
      logical flag

! RR Random Generator.

! rranf() generates uniform in [0..1)
! rrang() generates Gaussian with mean=0, s=1.
! rranset(iseed) sets seed - same for both.
! rranget(iseed) returns current seed.
! NB: Seed = 0 is forbidden.

! Extremely fast.  2^32-1 cycle.
! Source taken from Numerical Recipes;
! Error removed, speed optimized.
! benchmark on sakharov (RS6000, 130 MHz):
!   rranf() returns 2.18 M numbers/sec.
!   rrang() returns 0.63 M numbers/sec.
! [Sep-01-1997]

      parameter (Pi=3.1415926535898d0)
      parameter (Pi2 = 2*Pi)

      data iseed/222222/
      data flag/.false./
      save

      parameter (ia = 16807)
      parameter (im = 2147483647)
      parameter (iq = 127773)
      parameter (ir = 2836)
      parameter (am = 1d0/im)
      parameter (am2 = 2*am)

      k = iseed / iq
      iseed = ia*(iseed-k*iq) - k*ir
      if (iseed.lt.0) iseed = iseed + im
      rranf = am*iseed
      return


      entry rrang()
      if (flag) then
         flag = .false.
         rrang = v2*f
         return
      endif
      flag = .true.

 1    k = iseed / iq
      iseed = ia*(iseed-k*iq) - k*ir
      if (iseed.lt.0) iseed = iseed + im
      v1 = am2*iseed - 1                          ! = 2*rranf() - 1
      k = iseed / iq
      iseed = ia*(iseed-k*iq) - k*ir
      if (iseed.lt.0) iseed = iseed + im
      v2 = am2*iseed - 1                          ! = 2*rranf() - 1
      r = v1**2 + v2**2
      if (r.ge.1) goto 1

      f = sqrt(-2*log(r)/r)   ! chance of r being 0 is 1/(2^32)^2 - never.
      rrang = v1*f
      return


      entry rranset(iseed_)
      iseed = iseed_
      return


      entry rranget(iseed_)
      iseed_ = iseed
      end


      subroutine rrdpsort (dx, n, iperm, kflag)

! RR changes:
! style changed to f77.
! comments changed/removed
! ier eliminated; error return -> stop

!***begin prologue  dpsort
!***purpose  return the permutation vector generated by sorting a given
!            array and, optionally, rearrange the elements of the array.
!            the array may be sorted in increasing or decreasing order.
!            a slightly modified quicksort algorithm is used.
!***library   slatec
!***category  n6a1b, n6a2b
!***type      real*8 (spsort-s, dpsort-d, ipsort-i, hpsort-h)
!***keywords  number sorting, passive sorting, singleton quicksort, sort
!***author  jones, r. e., (snla)
!           rhoads, g. s., (nbs)
!           wisniewski, j. a., (snla)
!***description
!
!   dpsort returns the permutation vector iperm generated by sorting
!   the array dx and, optionally, rearranges the values in dx.  dx may
!   be sorted in increasing or decreasing order.  a slightly modified
!   quicksort algorithm is used.
!
!   iperm is such that dx(iperm(i)) is the ith value in the
!   rearrangement of dx.  iperm may be applied to another array by
!   calling ipperm, spperm, dpperm or hpperm.
!
!   the main difference between dpsort and its active sorting equivalent
!   dsort is that the data are referenced indirectly rather than
!   directly.  therefore, dpsort should require approximately twice as
!   long to execute as dsort.  however, dpsort is more general.
!
!   description of parameters
!      dx - input/output -- double precision array of values to be
!           sorted.  if abs(kflag) = 2, then the values in dx will be
!           rearranged on output; otherwise, they are unchanged.
!      n  - input -- number of values in array dx to be sorted.
!      iperm - output -- permutation array such that iperm(i) is the
!              index of the value in the original order of the
!              dx array that is in the ith location in the sorted
!              order.
!      kflag - input -- control parameter:
!            =  2  means return the permutation vector resulting from
!                  sorting dx in increasing order and sort dx also.
!            =  1  means return the permutation vector resulting from
!                  sorting dx in increasing order and do not sort dx.
!            = -1  means return the permutation vector resulting from
!                  sorting dx in decreasing order and do not sort dx.
!            = -2  means return the permutation vector resulting from
!                  sorting dx in decreasing order and sort dx also.
!***references  r. c. singleton, algorithm 347, an efficient algorithm
!                 for sorting with minimal storage, communications of
!                 the acm, 12, 3 (1969), pp. 185-187.
!***end prologue  dpsort

      integer kflag, n
      real*8 dx(*)
      integer iperm(*)

      real*8 r
      real*8 temp
      integer i, ij, indx, indx0, istrt, j, k, kk, l, lm, lmt, m, nn
      integer il(21), iu(21)

      intrinsic abs, int

!***first executable statement  dpsort

      nn = n
      if (nn .lt. 1) stop 'rripsort: n is not positive'

      kk = abs(kflag)
      if (kk.ne.1 .and. kk.ne.2) stop 'rripsort: wrong kflag'

! initialize permutation vector:
      do i=1,nn
         iperm(i) = i
      enddo
      if (nn .eq. 1) return

! alter array dx to get decreasing order if needed:
      if (kflag .le. -1) then
         do i=1,nn
            dx(i) = -dx(i)
         enddo
      endif

! sort dx only:
      m = 1
      i = 1
      j = nn
      r = .375d0

   30 if (i .eq. j) goto 80
      if (r .le. 0.5898437d0) then
         r = r+3.90625d-2
      else
         r = r-0.21875d0
      endif

   40 k = i
      ij = i + int((j-i)*r)
      lm = iperm(ij)
      if (dx(iperm(i)) .gt. dx(lm)) then
         iperm(ij) = iperm(i)
         iperm(i) = lm
         lm = iperm(ij)
      endif
      l = j

! interchange with lm:
      if (dx(iperm(j)) .lt. dx(lm)) then
         iperm(ij) = iperm(j)
         iperm(j) = lm
         lm = iperm(ij)
         if (dx(iperm(i)) .gt. dx(lm)) then
            iperm(ij) = iperm(i)
            iperm(i) = lm
            lm = iperm(ij)
         endif
      endif
      goto 60

   50 lmt = iperm(l)
      iperm(l) = iperm(k)
      iperm(k) = lmt

   60 l = l-1
      if (dx(iperm(l)) .gt. dx(lm)) goto 60

   70 k = k+1
      if (dx(iperm(k)) .lt. dx(lm)) goto 70

      if (k .le. l) goto 50

      if (l-i .gt. j-k) then
         il(m) = i
         iu(m) = l
         i = k
         m = m+1
      else
         il(m) = k
         iu(m) = j
         j = l
         m = m+1
      endif
      goto 90

! begin again on another portion of the unsorted array:
   80 m = m-1
      if (m .eq. 0) goto 120
      i = il(m)
      j = iu(m)

   90 if (j-i .ge. 1) goto 40
      if (i .eq. 1) goto 30
      i = i-1

  100 i = i+1
      if (i .eq. j) goto 80
      lm = iperm(i+1)
      if (dx(iperm(i)) .le. dx(lm)) goto 100
      k = i

  110 iperm(k+1) = iperm(k)
      k = k-1
      if (dx(lm) .lt. dx(iperm(k))) goto 110
      iperm(k+1) = lm
      goto 100

! clean up:
  120 if (kflag .le. -1) then
         do i=1,nn
            dx(i) = -dx(i)
         enddo
      endif
      if (kk.ne.2) return

! rearrange the values of dx if desired:
      do istrt=1,nn
         if (iperm(istrt) .ge. 0) then
            indx = istrt
            indx0 = indx
            temp = dx(istrt)
 140        if (iperm(indx) .gt. 0) then
               dx(indx) = dx(iperm(indx))
               indx0 = indx
               iperm(indx) = -iperm(indx)
               indx = abs(iperm(indx))
               goto 140
            endif
            dx(indx0) = temp
         endif
      enddo
      do i=1,nn
         iperm(i) = -iperm(i)
      enddo

      return
      end
