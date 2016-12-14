@echo off
if exist conthelp.map del conthelp.map
if exist conthelp.exe del conthelp.plw
if exist conthelp.obj del conthelp.obj
:goto end

ml -nologo -c -Cp -Cx -coff conthelp.asm
ml -nologo -c -Cp -Cx -AT nullstub.asm

if not exist masm.lib\ida.lib lib -out:masm.lib\ida.lib -def:ida.def
if not exist masm.lib\kernel32.lib lib -out:masm.lib\kernel32.lib -def:kernel32.def
if not exist masm.lib\user32.lib lib -out:masm.lib\user32.lib -def:user32.def
link510 /nologo /tiny nullstub.obj, nullstub.bin, , , ,
link -nologo -stub:nullstub.bin -dll -libpath:masm.lib -def:conthelp.def -out:conthelp.plw ida.lib kernel32.lib user32.lib conthelp.obj
if exist nullstub.obj del nullstub.obj
if exist nullstub.map del nullstub.map

:end
