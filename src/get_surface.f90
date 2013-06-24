!+ <A one line description of this subroutine> 
! 
subroutine get_surface &
! 
(errorstatus,freq, ground_temp, salinity, ground_albedo,ground_index,ground_type)
 
    ! Description:
    !   <Say what this routine does>
    !
    ! Method:
    !   <Say how it does it: include references to external documentation>
    !   <If this routine is divided into sections, be brief here,
    !        and put Method comments at the start of each section>
    !
    ! Current Code Owner: <Name of person responsible for this code>
    !
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    ! <version> <date>   Original code. <Your name>
    !
    ! Code Description:
    !   Language:		Fortran 90.
    !   Software Standards: "European Standards for Writing and  
    !     Documenting Exchangeable Fortran 90 Code". 
    !
    ! Declarations:
    ! Modules used:
    use kinds
    use settings, only: emissivity, data_path
    use constants, only: t_abs
    use vars_atmosphere, only : lfrac,lon,lat,month
    use mod_io_strings, only: nxstr, nystr

    use report_module
    ! Imported Type Definitions:
 
    ! Imported Parameters:
 
    ! Imported Scalar Variables with intent (in):
 
    ! Imported Scalar Variables with intent (out):
 
    ! Imported Array Variables with intent (in):
 
    ! Imported Array Variables with intent (out):
 
    ! Imported Routines:
    ! <Repeat from Use for each module...>
 
    implicit none
 
    ! Include statements:
    ! Declarations must be of the form:
    ! <type>   <VariableName>      ! Description/ purpose of variable
 
    ! Subroutine arguments
    ! Scalar arguments with intent(in):
    real(kind=dbl), intent(in) :: freq,ground_temp, salinity
    ! Array  arguments with intent(in):
 
    ! Scalar arguments with intent(inout):
    real(kind=dbl), intent(out) :: ground_albedo
    complex(kind=dbl), intent(out) :: ground_index
    character(1) :: ground_type
    ! Array  arguments with intent(inout):
 
    ! Scalar arguments with intent(out):
 
    ! Array  arguments with intent(out):
 
    ! Local parameters:
 
    ! Local scalars:
    integer(kind=long) :: ise, imonth ! filehandle for the emissivity data
 
    real(kind=dbl) :: land_emissivity

    complex(kind=dbl) :: eps_water, & ! function to calculate the dielectic properties of (salt)water
    epsi         ! result of function eps_water

    ! Local arrays:
 
    !- End of header ---------------------------------------------------------------


    character(80) :: femis ! filename for the emissivity databases

    ! i/o-length test for the emissivity file
    integer(kind=long) :: iolsgl

    ! Error handling

    integer(kind=long), intent(out) :: errorstatus
    integer(kind=long) :: err = 0
    character(len=80) :: msg
    character(len=14) :: nameOfRoutine = 'get_surface'

    inquire(iolength=iolsgl) 1._sgl

    if (verbose >= 1) call report(info,'Start of ', nameOfRoutine)

    if (lfrac >= 0.5_dbl .and. lfrac <= 1.0_dbl) then
        ground_type = 'S' ! changed to specular after advice of cathrine prigent
        ise=13
        read(month,'(i2)') imonth
        if (imonth .ge. 7 .and. imonth .le. 12) then
            femis = data_path(:len_trim(data_path))//'/emissivity/ssmi_mean_emis_92'//month//'_direct'
        else if (imonth .ge. 1 .and. imonth .lt. 7) then
            femis = data_path(:len_trim(data_path))//'/emissivity/ssmi_mean_emis_93'//month//'_direct'
        else
            msg = "Warning: No emissivity data found for "//nxstr//" and "//nystr
            errorstatus = fatal
            call report(errorstatus,msg,nameOfRoutine)
            return
        end if
        open(ise,file=trim(femis),status='old',form='unformatted',&
        access='direct',recl=iolsgl*7)
        ! land_emis could give polarized reflectivities

        call land_emis(ise,lon,lat,freq,land_emissivity)
        close(ise)
        if (land_emissivity < 0.01_dbl) then
            land_emissivity = 0.94_dbl
        end if
        ground_albedo = 1._dbl - land_emissivity

    else if (lfrac >= 0._dbl .and. lfrac < 0.5_dbl) then
        ! computing the refractive index of the sea (Fresnel) surface
        ground_type = 'O'
        ground_albedo = 1.0_dbl
        epsi = eps_water(salinity, ground_temp - t_abs, freq)
        ground_index = dconjg(sqrt(epsi))
    else
        ! this is for ground_type specified in run_params.nml
        ground_albedo = 1.d0 - emissivity
    end if

    errorstatus = err
    if (verbose >= 1) call report(info,'End of ', nameOfRoutine)

    return
end subroutine get_surface