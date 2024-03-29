program self_thinning

    !Variables to use
    integer :: j,k
    integer, parameter:: npls = 20
    real, dimension(npls), allocatable :: LAI (:) !Leaf Area Index (m2/m2)
    real, dimension(npls), allocatable :: LAI_upt (:) !Leaf Area Index (m2/m2)
    real, dimension(npls), allocatable :: diam (:) !Tree diameter in m. (Smith et al., 2001 - Supplementary)
    real, dimension(npls), allocatable :: crown_area (:) !Tree crown area (m2) (Sitch et al., 2003)
    real, dimension(npls), allocatable :: crown_area_upt (:) !Tree crown area (m2) (Sitch et al., 2003)
    real, dimension(npls), allocatable :: perc_ocp_pls (:)
    real, allocatable :: FPC_pls_t1 (:) !Foliage projective cover for each PLS (Sitch et al., 2003)
    real, allocatable :: FPC_pls_t2 (:) !Foliage projective cover for each PLS (Sitch et al., 2003)
    real, allocatable :: FPC_pls_upt (:)
    real, allocatable :: FPC_ind_ocp (:)
    real, allocatable :: FPC_ind_ocp_t2 (:)
    real, allocatable :: FPC_pls_cont_area (:)
    real, allocatable :: exc_nind (:)
    real, allocatable :: FPC_avg_ind (:) !Average idividual occupation for a PLS (Sitch et al., 2003)
    real, allocatable :: FPC_avg_ind_upt (:) !Average idividual occupation for a PLS (Sitch et al., 2003)
    real, allocatable :: FPCgrid_perc (:) !Fractional projective cover in grid cell relative to grid cell area (Sitch et al., 2003)
    real, allocatable :: nind (:) !number of individuals per PLS (Smith, 2001, thesis)
    real, allocatable :: nind_t2 (:)
    real, allocatable :: nind_upt (:)
    real, allocatable :: diam_upt (:)
    real, allocatable :: FPCgrid_updt (:) !Fractional projective cover in grid cell (Sitch et al., 2003) - updated to occupy 95%
    real, allocatable :: FPCgrid_perc_updt (:) !Fractional projective cover in grid cell relative to grid cell area (Sitch et al., 2003)-updated to occupy 95%
    real :: FPC_grid_total_t1 = 0.0 !Fractional projective cover in grid cell (Sitch et al., 2003)
    real :: FPC_grid_total_t2 = 0.0 !Fractional projective cover in grid cell (Sitch et al., 2003)
    real :: FPC_inc_grid = 0.0
    real :: cont_inc_perc_total = 0.0
    real :: sum_total_inc = 0.0
    real :: sum_FPCgrid_perc=0.0
    real :: sum_nind=0.0
    real :: sum_cont_inc = 0.0
    real :: gc_area = 15 !grid cell size - 15 m2 FOR TESTING PURPOSE (the real value will be 1ha or 10000 m2)
    real :: gc_area95
    real :: sum_FPCgrid_updt = 0.0 !!the new number of total PLS average-individuals after % reduction equals maximum to
                                 !! not to exceed 95% occupation.
    real :: sum_FPCgrid_perc_updt = 0.0 !the new percentage of occupation of all PLS after % reduction. 
    real :: exc_area
    real :: exc_area_perc
    real, dimension(npls) :: FPC_inc_pls 
    real, dimension(npls) :: FPC_inc_pls_cont  !contribuição de cada PLS para o incremento da célula de grade
    real, dimension(npls) :: cont_exc
    real, dimension(npls) :: dens_ind_pls = 2  !densidade de indivíduos em cada PLS (0.5 é um número genérico)

    !Parameters and constants
    real :: k_allom1 = 100. !allometric constant (Table 3; Sitch et al., 2003)
    real :: krp = 1.6 !allometric constant (Table 3; Sitch et al., 2003)
    real :: ltor = 0.77302587552347657

    !Variables to allocation prototype
    real, dimension(npls) :: npp1 !KgC/ano
    real, dimension(npls) :: npp_inc = 0.0 !incremento anual de C para cada PLS
    real, dimension(npls) :: annual_npp = 0.0!quantidade de NPP com os incrementos.
    real, dimension(npls) :: cl2,cl_upt
    real, dimension(npls) :: cw2


    !============== ALLOMETRY EQUATIONS ===============!

    ! Variables with generic values for testing the logic code

    real, dimension(npls) :: dwood !wood density (g/cm-3) *Fearnside, 1997 - aleatory choices
    real, dimension(npls) :: cw1 !KgC/m2 (Cheart + Csap)
    real, dimension(npls) :: cl1 !KgC/m2 
    real, dimension(npls) :: cr1 !KgC/m2
    real, dimension(npls) :: spec_leaf !m2/gC
    real, dimension(npls) :: leaf_inc !kgC/ ind
    real, dimension(npls) :: wood_inc !kgC/ ind
    real, dimension(npls) :: root_inc !kgC/ ind
    real, dimension(npls) :: total_inc !kgC/ ind
    real, dimension(npls) :: cont_inc!kgC/ ind
    real, dimension(npls) :: cont_inc_perc!kgC/ ind
    real, dimension(npls) :: nind_exc
    real, dimension(npls) :: diameter, diameter_t2

    dwood=(/0.24,0.53,0.39,0.32,0.31,0.44,0.66,0.42,0.74,0.39,0.82,0.40,0.26,0.79,0.39,0.52,0.41,0.44,0.86,0.42/) !atenção para a unidade
    cl1=(/.7,1.,0.3,1.6,1.1,1.8,0.3,0.2,0.8,.84,0.25,1.,0.2,1.7,0.4,.6,.5,.8,0.3,1.8/)
    spec_leaf=(/0.0153,0.0101,0.0107,0.0112,0.012,0.0141,0.0137,0.0115,0.0122,0.010,0.012,0.011,&
    &0.013,0.014,0.0112,0.012,0.0141,0.0137,0.0115,0.0122/)
    cw1=(/30.,22.,34.,28.3,20.2,19.7,27.5,19.5,20.,28.6,24.3,19.3,26.8,22.,18.3,22.,15.,22.6,10.7,21.4/)
    cr1=(/0.63,0.8,0.9,1.5,1.3,0.9,0.4,1.0,0.56,0.87,0.33,0.97,0.31,0.55,0.2,0.8,0.4,0.66,0.23,1.5/)
    npp1 = (/0.5,0.8,1.5,1.2,1.9,1.3,1.7,0.8,0.6,2.0,0.7,1.1,1.9,1.85,1.96,1.77,1.33,1.54,1.62,0.55/)
    diameter = (/0.16,0.45,0.17,0.25,0.34,0.4,0.23,0.49,0.37,0.5,0.53,0.12,0.75,0.22,0.63,0.31,0.41,0.63,0.52,0.15/)

    diameter_t2 = diameter - 0.02 !diminuição do diametro por conta do self-thining para um tempo 2

    allocate (nind(1:npls))
    allocate (nind_t2(1:npls))
    allocate (FPC_avg_ind(1:npls))
    allocate (FPC_pls_t1(1:npls))
    allocate (FPC_pls_t2(1:npls))
    allocate (FPC_pls_upt(1:npls))
    allocate (FPC_avg_ind_upt(1:npls))
    allocate (FPC_ind_ocp(1:npls))
    allocate (FPC_ind_ocp_t2(1:npls))
    allocate (exc_nind(1:npls))
    allocate (FPC_pls_cont_area(1:npls))
    allocate (nind_upt(1:npls))
    allocate (diam_upt(1:npls))
    allocate (perc_ocp_pls(1:npls))
    

    allocate (FPCgrid_perc(1:npls))
    allocate (FPCgrid_updt(1:npls))
    allocate (FPCgrid_perc_updt(1:npls))

    ! Increment of carbon on tissues per individual 

    ! diam = diam *1000 !transforms from g/cm3 to kg/m3
 
    do k = 1, 2
        ! Allometric Equations =================================================

        ! Grid-Cell Properties =================================================

        if (k .eq. 1) then !usando o time step t1
            !INITIAL ALLOMETRY
            cw1 = (cw1/dens_ind_pls)*1000. !*1000 transforma de kgC para gC
            diam = ((4*(cw1))/((dwood*1000000.)*3.14*36))**(1/(2+0.22)) !nessa equação dwood deve estar em g/m3
            ! print*, 'diam===', diam*100
            
            crown_area = k_allom1*(diam**krp)
            !crown_area = k_allom1*(diameter**krp)
            ! print*, 'crown===', crown_area

            !LAI individual (Sitch et al., 2003) - Cleaf/nind
            cl1 = (cl1/dens_ind_pls)*1000
            LAI = (cl1*spec_leaf)/crown_area 
            print*, 'LAI===', LAI
            
            npp_inc = 0.15 / dens_ind_pls !quantidade de npp pra ser alocado por individuo-médio

            annual_npp = ((npp1/dens_ind_pls) + npp_inc)*1000 !a cada ano NPP aumenta 0.35kgC/ano
            ! print*,'annual_npp====' ,annual_npp
            
            
            !==================================================
            !INCREMENTS TO LEAF AND WOOD TISSUES PER INDIVIDUO

            leaf_inc = 0.35*npp_inc

            root_inc = 0.35*npp_inc

            wood_inc = 0.3*npp_inc

            !==================================================
            !CARBON TISSUES

            cl2 = cl1 + leaf_inc !cl1 e leaf_inc já está dividido peela densidade

            cw2 = cw1 + wood_inc !cw1 e wood_inc já est2á dividido peela densidade

            ! print*, 'CL2', cl2/1000, 'CW2', cw2/1000
            !==================================================
            ! FPC FOR t1
            FPC_avg_ind = (1-exp(-0.5*LAI)) !FPC ind médio m2
            ! print*, 'FPC_avg_ind_t1',FPC_avg_ind_t1

            FPC_pls_t1 = crown_area*dens_ind_pls*FPC_avg_ind
            ! print*, 'FPC_pls_t1', FPC_pls_t1

            FPC_grid_total_t1 = sum(FPC_pls_t1)
            ! print*, 'FPC_grid_total_t1', FPC_grid_total_t1

        else !simulando time step t2 (diametro modificado)
        !     
            diam = ((4*(cw2))/((dwood*1000000)*3.14*36))**(1/(2+0.22))
            ! print*, 'diam', diam*100
            
            crown_area = k_allom1*(diam**krp)
            ! print*, 'crown', crown_area
            
        !     !LAI individual (Sitch et al., 2003) - Cleaf/nind
            LAI = ((cl2)*spec_leaf)/crown_area !transfor CL2 gC to kgC

            annual_npp = annual_npp + 0.35

            ! nind_t2 = diameter_t2**(-1.6) !número de individuos-médios de cada PLS
            ! print*, 'nind_t2', nind_t2

            FPC_avg_ind = (1-exp(-0.5*LAI)) !FPC ind médio m2
            print*, 'FPC_avg_ind_t2', FPC_avg_ind_t2

            FPC_pls_t2 = crown_area*dens_ind_pls*FPC_avg_ind
            ! print*, 'FPC_pls_t2', FPC_pls_t2

            FPC_grid_total_t2 = sum(FPC_pls_t2)
            ! print*,'FPC_grid_total_t2', FPC_grid_total

            ! FPC_ind_ocp_t2 = FPC_pls_t2/nind_t2 !quantos metros2 cada ind ocupa
            ! print*, 'FPC_ind_ocp_t2==========/', FPC_ind_ocp_t2

            npp_inc = 0.15 / dens_ind_pls !quantidade de npp pra ser alocado por individuo-médio

        !    !==================================================
        !    !INCREMENTS TO LEAF AND WOOD TISSUES PER INDIVIDUO

            leaf_inc = 0.35*npp_inc
            root_inc = 0.35*npp_inc
            wood_inc = 0.3*npp_inc
            !==================================================
            !CARBON TISSUES

            cl2 = cl1 + leaf_inc
            ! print*, 'cl2', cl2

            cw2 = cw1 + wood_inc
            ! print*, 'cw2', cw2
        !     !==================================================
        endif

        ! print*, k, 'nind', nind
        ! print*, k, 'npp_inc', npp_inc

        ! total_inc = cleaf_inc + wood_inc + root_inc !somatoria de inc de todos os tecidos p/ um PLS
        ! sum_total_inc = sum(total_inc)              !somatória de inc p/ todos os PLS
        ! cont_inc = total_inc/sum_total_inc          !contribuição relativa de cada PLS p/ inc total
        ! sum_cont_inc = sum(cont_inc)
        ! ! print*, 'TOTAL INC=', total_inc, 'SUM DE INC', sum_total_inc, 'CONT INC', cont_inc, 'SUM CONT', sum_cont_inc


        ! ! cont_inc_perc = (cont_inc*100)/sum_total_inc
        ! ! cont_inc_perc_total = sum(cont_inc_perc)
        ! ! print*, 'cont_inc', cont_inc
        ! ! print*, 'cont_inc_perc', cont_inc_perc,'total', cont_inc_perc_total

        ! FPC_avg_ind = (1-exp(-0.5*LAI)) !FPC ind médio m2

        ! FPC_pls = crown_area*nind*FPC_avg_ind 

        ! FPC_ind_ocp = FPC_pls/nind                  !ocupação de cada ind em cada PLS
        ! print*,'FPC_IND_OCP',FPC_ind_ocp, 'FPC_pls',FPC_pls

        ! ! print*, 'OCP IND', FPC_ind_ocp, 'FPC PLS', FPC_pls , 'NIND', nind, 'DIAMETRO', diam, 'CA', crown_area, 'dwood', dwood
        ! !'FPC', FPC_ind_ocp*nind
        
        ! FPC_grid_total = sum(FPC_pls) !FPC da célula

        ! ! print*, 'FPC ind medio=', FPC_avg_ind, 'FPC_grid_total', FPC_grid_total

        gc_area95 = gc_area*0.95
        ! print*,'gc_area95', gc_area95

        if (FPC_grid_total .gt. gc_area95) then
            exc_area = FPC_grid_total - gc_area95
            ! print*, 'excendendo', exc_area

            ! cont_exc = cont_inc*exc_area !Biomass individual contribution to area excedent
            ! print*, 'teste'!'exc_area', exc_area !, 'CONT EXC',cont_exc, 'SUM CONT EXC', sum(cont_exc)    
            ! nind_exc = cont_exc/FPC_ind_ocp !quanto deve-se reduzir do nº de individuo de cada PLS
            ! print*, 'exc_nind', nind_exc
            ! print*, 'nind', nind
            ! nind_upt = nind - nind_exc
            ! print*, 'nind_upt', nind_upt
            ! print*, 'nind_old', nind
            
        endif

        ! FPCgrid_perc = (FPC_grid_total*100)/gc_area
        ! ! print*, 'FPC-GRID-PERC', FPCgrid_perc(j), gc_area

    enddo
     !!!!!TENTATIVA DE UTILIZAR O INCREMENTO DOS FPCs!!!!!!!!!!1
    exc_area = FPC_grid_total_t2 - gc_area95 ! excedente de ocupação da célula de grade inteira
    ! print*, 'exc_area', exc_area , FPC_grid_total_t2, gc_area95,gc_area

    FPC_pls_t1=(gc_area95/20.) !contribuição de cada PLS p/o excedente !!!ATENÇÃO para a variável que deve ocupar o lugar de 285

    
    ! print*, perc_ocp_pls_t1
   
    FPC_inc_pls = FPC_pls_t2 - FPC_pls_t1 !!incremento de cada PLS ! perde todos os ind???
    ! print*, 'FPC_inc_pls=====', FPC_inc_pls

  
    FPC_inc_pls_cont = FPC_inc_pls/exc_area   !contribuição relativa de cada PLS para o incremento total
    print*, 'FPC_INC_pls cont====', FPC_inc_pls_cont, 'soma', sum(FPC_inc_pls_cont)

    ! exc_nind = FPC_inc_pls_cont*dens_ind_pls
    ! print*, 'exc_nind', exc_nind

    ! do j=1,npls
    !     if (FPC_inc_pls(j).lt.0.0)then
    !         FPC_inc_pls(j)=0.0
    !         FPC_inc_pls_cont(j)=0.0
    !         FPC_pls_cont_area(j)=0.0
    !         ! print*, FPC_inc_pls(j)
    !         ! liteira = 1+0,5+
    !     endif
    ! enddo   
   

    ! FPC_pls_cont_area = FPC_inc_pls_cont*exc_area !contribuição relativa em relação ao excedente em m2
    ! print*, 'FPC_pls_cont_area====', FPC_pls_cont_area

    ! exc_nind = FPC_pls_cont_area/FPC_ind_ocp_t2 !individuos excedentes a serem retirados
    ! print*, 'exc_nind====', exc_nind
    ! print*, 'verificação', sum(exc_nind*FPC_ind_ocp_t2) !verifica se a redução dos indivíduos é igual ao tamanho excedente de area
    
    ! nind_upt = nind_t2 - (exc_nind)
    ! print*, 'nind_upt', nind_upt, 'nind_t2', nind_t2, 'exc ind', exc_nind
   
    ! nind_upt = diam_upt**(-1.6)
    ! nind_upt = 1/diam_upt**(1.6)
    !nind_upt**(1.25) = 1/diam_upt**2 ! elevei os dois lados da equação a 1.25 para conseguir fazer a raiz quadrada
    ! diam_upt = sqrt(1/(nind_upt**1.25))
    ! print*, 'DIAM UPT', diam_upt, 'DIAM T2',diameter_t2

    

!!!!UPDATE DAS VARIÁVEIS!!!!

!!!ATENÇÃO: DIMINUIÇÃO NOS COMPARTIMENTOS DE CARBONO!!!!    
    ! crown_area_upt = k_allom1*(diam_upt**krp)
    ! ! print*, 'CA2', crown_area_upt

    ! cl_upt=cl2/(nind_t2/FPC_pls_t2)
    ! ! print*, 'CLP_UPT', cl_upt, 'CL2', cl2

    ! LAI_upt = ((cl2*1000)*spec_leaf)/crown_area_upt !transfor CL2 gC to kgC

            
    ! FPC_avg_ind_upt = (1-exp(-0.5*LAI_upt)) !FPC ind médio m2
    ! ! print*, 'FPC_avg_ind_upt', FPC_avg_ind_upt

    ! FPC_pls_upt = crown_area_upt*nind_upt*FPC_avg_ind_upt
    ! ! print*, 'FPC_pls_t2', FPC_pls_upt, sum(FPC_pls_upt)

    
   
!!! PROXIMO PASSO: FAZER O UPDATE DOS COMPARTIMENTOS DE CARBONO

end program self_thinning