program test_time
    
   
    integer :: j,k
    integer, parameter:: npls = 20
    integer, parameter:: time = 5
    
    real, dimension(npls,time) :: cl2 !carbon on leaves after allocation
    real, dimension(npls,time) :: cl1 !carbon on leaves after allocation
    real, dimension(npls,time) :: cl1_aux !carbon on leaves after allocation

    real, dimension(npls) :: cl1_initial !KgC/m2

    cl1_initial = (/.7,1.,0.3,1.6,1.10,1.8,0.3,0.2,0.8,0.84,0.25,1.,0.2,1.7,0.4,.6,.5,.8,0.3,1.8/)

    cl2 = 0
    ! cl1 = cl1_initial
    do k = 1, 4
        print*, '-----------------------------------'
        print*, k
        print*, ''
        
        if(k.eq.1)then
            cl1(:,k) = cl1_initial
            print*,'cl previous yr', cl1(:,k)
        ! else
        !     cl1(:,k) = cl1(:,k)
        !     print*,'cl previous yr', cl1(:,k)
        endif

        
        ! cl1(:,k) = cl1_initial

        cl1(:,k) = cl1_aux(:,k-1)

        print*, 'cl1',  cl1(:,k)

        do j=1, npls
            ! print*, 'pls',j 
            ! print*,''
            ! cl2(j,k) = cl1(j,k)*2.
            
           
            cl2(j,k) = cl1(j,k)*2

           
            print*,'cl2 calculado', cl2(j,k)
            print*,''
            
           

         enddo
        
        cl1_aux(:,k) = cl2(:,k)
        print*, 'cl1 updating', cl1_aux(:,k)

        ! print*, 'cl1 for the nxt yr', cl1(:,k)
        ! print*, ''
        ! print*, '-----------------------'
    enddo
    

end program 