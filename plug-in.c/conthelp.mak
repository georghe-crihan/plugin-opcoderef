# Microsoft Developer Studio Generated NMAKE File, Based on conthelp.dsp
!IF "$(CFG)" == ""
CFG=conthelp - Win32 Debug
!MESSAGE No configuration specified. Defaulting to conthelp - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "conthelp - Win32 Release" && "$(CFG)" != "conthelp - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "conthelp.mak" CFG="conthelp - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "conthelp - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "conthelp - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "conthelp - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release

ALL : "release\conthelp.plw"


CLEAN :
	-@erase "$(INTDIR)\string.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\conthelp.exp"
	-@erase "release\conthelp.plw"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G6 /Zp1 /ML /W3 /GX /O2 /I "..\..\include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "__NT__" /D "__IDP__" /D MAXSTR=1024 /D MAXPATH=1024 /D "IDA55UP" /Fp"$(INTDIR)\conthelp.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\conthelp.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib ida.lib /nologo /dll /incremental:no /pdb:"$(OUTDIR)\conthelp.pdb" /machine:I386 /out:"release/conthelp.plw" /implib:"$(OUTDIR)\conthelp.lib" /libpath:"..\..\libvc.w32" /export:PLUGIN 
LINK32_OBJS= \
	"$(INTDIR)\conthelp.obj"

"release\conthelp.plw" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "conthelp - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "release\conthelp.plw"


CLEAN :
	-@erase "$(INTDIR)\conthelp.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\conthelp.exp"
	-@erase "$(OUTDIR)\conthelp.lib"
	-@erase "$(OUTDIR)\conthelp.pdb"
	-@erase "release\conthelp.ilk"
	-@erase "release\conthelp.plw"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\..\include" /D "_DEBUG" /D "__NT__" /D "__IDP__" /D MAXSTR=1024 /D MAXPATH=1024 /D "IDA55UP" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Fp"$(INTDIR)\conthelp.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\conthelp.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
#gdi32.lib winspool.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
LINK32_FLAGS=ida.lib kernel32.lib user32.lib /nologo /dll /incremental:yes /pdb:"$(OUTDIR)\conthelp.pdb" /debug /machine:I386 /out:"release/conthelp.plw" /implib:"$(OUTDIR)\conthelp.lib" /pdbtype:sept /libpath:"..\..\libvc.w32" /export:PLUGIN 
LINK32_OBJS= \
	"$(INTDIR)\conthelp.obj"

"release\conthelp.plw" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("conthelp.dep")
!INCLUDE "conthelp.dep"
!ELSE 
!MESSAGE Warning: cannot find "conthelp.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "conthelp - Win32 Release" || "$(CFG)" == "conthelp - Win32 Debug"

SOURCE=.\conthelp.cpp

!IF  "$(CFG)" == "conthelp - Win32 Release"

CPP_SWITCHES=/nologo /G6 /Zp1 /ML /W3 /GX /O2 /I "..\..\include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "__NT__" /D "__IDP__" /D MAXSTR=1024 /D MAXPATH=1024 /D "IDA55UP" /Fp"$(INTDIR)\conthelp.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\conthelp.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "conthelp - Win32 Debug"

CPP_SWITCHES=/nologo /Gd /MTd /W3 /Gm /GX /ZI /Od /I "..\..\include" /D "_DEBUG" /D "__NT__" /D "__IDP__" /D MAXSTR=1024 /D MAXPATH=1024 /D "IDA55UP" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Fp"$(INTDIR)\conthelp.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

"$(INTDIR)\conthelp.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ENDIF 


!ENDIF 

