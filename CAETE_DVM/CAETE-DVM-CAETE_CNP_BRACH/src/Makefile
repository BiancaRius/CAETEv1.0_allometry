# Build caete_module & debug programs
PYEXEC = python3
F2PY = $(PYEXEC) -m numpy.f2py
MODNAME = caete_module
INTERFACES = $(MODNAME).pyf
DEBUG_PROGRAM = run_debug

# RUN MODE FLAGS
MFLAG = -m
HFLAG = -h
CFLAG = -c
OVRTFLAG = --overwrite-signature

# DEBUG MODE
FC = gfortran
FCFLAGS = -g -lgomp -fopenmp -Wall -Wextra -fcheck=all -ffpe-trap=invalid,zero,overflow,underflow -fbacktrace -fbounds-check -Wconversion -pedantic
FLFLAGS = -c -g -lgomp -fopenmp -Wall -fcheck=all -Wextra -ffpe-trap=invalid,zero,overflow,underflow -fbacktrace -fbounds-check -Wconversion -pedantic
EXT_FLAGS = -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans

# Sources for compilation in run mode (F2PY)
sources = global.f90 funcs.f90 soil_dec.f90 cc.f90 allocation.f90 productivity.f90 budget.f90

# Objects for compilation in debug mode
objects = global.o funcs.o soil_dec.o cc.o allocation.o productivity.o budget.o debug_caete.o

# Build the interface and the shared object (caete_module) from .F90 source
interface: $(sources)
	$(F2PY) $(HFLAG) $(INTERFACES) $(sources) $(MFLAG) $(MODNAME) $(OVRTFLAG) --quiet

so: $(sources) interface
	$(F2PY)  $(INTERFACES) $(CFLAG) $(sources) --f90flags="-Wall $(EXT_FLAGS) -fopenmp " -lgomp
	echo

# Build objects for DEBUG mode
debug: $(objects) so
	$(PYEXEC) create_plsbin.py
	$(FC) -o $(DEBUG_PROGRAM) $(FCFLAGS) $(objects)

global.o: global.f90
	$(FC) $(FLFLAGS) global.f90

types.mod: global.o global.f90
	$(FC) $(FLFLAGS) global.f90

global_par.mod: global.o global.f90
	$(FC) $(FLFLAGS) global.f90

photo_par.mod: global.o global.f90
	$(FC) $(FLFLAGS) global.f90

funcs.o: funcs.f90
	$(FC) $(FLFLAGS) funcs.f90

photo.mod: funcs.o funcs.f90
	$(FC) $(FLFLAGS) funcs.f90

water.mod: funcs.o funcs.f90
	$(FC) $(FLFLAGS) funcs.f90

soil_dec.o: soil_dec.f90
	$(FC) $(FLFLAGS) soil_dec.f90

soil_dec.mod: soil_dec.o soil_dec.f90
	$(FC) $(FLFLAGS) soil_dec.f90

cc.o: cc.f90
	$(FC) $(FLFLAGS) cc.f90

carbon_costs.mod: cc.o cc.f90
	$(FC) $(FLFLAGS) cc.f90

allocation.o: allocation.f90
	$(FC) $(FLFLAGS) allocation.f90

alloc.mod: allocation.o allocation.f90
	$(FC) $(FLFLAGS) allocation.f90

productivity.o: productivity.f90
	$(FC) $(FLFLAGS) productivity.f90

productivity.mod: productivity.o productivity.f90
	$(FC) $(FLFLAGS) productivity.f90

budget.o: budget.f90
	$(FC) $(FLFLAGS) budget.f90

budget.mod: budget.o budget.f90
	$(FC) $(FLFLAGS) budget.f90

debug_caete.o: debug_caete.f90
	$(FC) $(FLFLAGS) debug_caete.f90


# CLEAN DIR
clean:
	rm -rf test *.mod *.s *.o pls_ex.txt __pycache__ run_debug
	clear

clean_plsgen:
	rm -rf wallo.npy
	rm -rf gallo.npy
