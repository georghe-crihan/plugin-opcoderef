@echo off
set include=%include%;%IDA%\include
set lib=%lib%;%IDA%\LIBVC.W32
NMAKE -f conthelp.mak CFG="conthelp - Win32 Release"
