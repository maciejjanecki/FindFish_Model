module kinds
#ifdef CAM
      use shr_kind_mod, only : SHR_KIND_I4, SHR_KIND_R8, SHR_KIND_I8, SHR_KIND_CL
      use cam_logfile, only : iulog
#endif
implicit none
private
!
!  most floating point variables should be of type real_kind = real*8
!  For higher precision, we also have quad_kind = real*16, but this
!  is only supported on IBM systems
! 
#if defined(CAM)  
  integer (kind=4), public, parameter::  &
  int_kind     = SHR_KIND_I4,            &
  log_kind     = kind(.true.),           &
  long_kind    = SHR_KIND_I8,            &
  real_kind    = SHR_KIND_R8,            &
  longdouble_kind    = 8
  public :: shr_kind_cl, iulog

#elif defined(_Linux) || defined (_Darwin)
  integer (kind=4), public, parameter::  &
  int_kind     = 4,                      &
  long_kind    = 8,                      &
  log_kind     = 4,                      &
  real_kind    = 8,                      &
  longdouble_kind    = 8,                      &
  iulog        = 6                          ! stderr file handle
#else
  integer (kind=4), public, parameter ::  &
  int_kind     = 4,                       &
  long_kind    = 8,                       &
  log_kind     = 4,                       &
  real_kind    = 8,                       &
  longdouble_kind    = 16,                      &
  iulog        = 6                          ! stderr file handle
#endif

end module kinds

