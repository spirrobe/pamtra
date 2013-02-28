subroutine random(n, pseudo, x_noise)
  ! Description:
  ! returns n random numbers
  ! if pseudo is true, always the same numbers are returned
  !
  !initiation of random nummer generator taken from
  !taken from http://gcc.gnu.org/onlinedocs/gfortran/RANDOM_005fSEED.html#RANDOM_005fSEED
  !
  ! History:
  ! Version   Date     Comment
  ! -------   ----     -------
  !  0.1   1/12/2012    creation of file 


  use nml_params, only: verbose

  use kinds
  implicit none
  integer, intent(in) :: n
  logical, intent(in) :: pseudo
  real(kind=dbl), intent(out), dimension(n) :: x_noise
  integer :: i, m, clock
  integer, dimension(:), allocatable :: seed

  if (verbose > 1) print*, "entering random.f90 "
    !get the required size of the seed
    call random_seed(size = m)

    allocate(seed(m))
    if (pseudo) then
      !if we want always the same random numbers
      clock=0
    else
      !get real random numbers
      call system_clock(count=clock)
    end if
  
    seed = clock + 37 * (/ (i - 1, i = 1, m) /)
    !seed the seed
    call random_seed(put = seed)
    deallocate(seed)
    !get the random numbers
    call RANDOM_NUMBER(x_noise)

  if (verbose > 1) print*, "exiting random.f90 "

end subroutine random

