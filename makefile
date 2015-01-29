    ROOTFLAGS     = $(shell root-config --cflags)
    ROOTLIBS      = $(shell root-config --glibs)

first: diag.exe

diag.exe: diagrams.cxx
	g++ diagrams.cxx $(ROOTFLAGS) $(ROOTLIBS) -DHOME -o diag.exe