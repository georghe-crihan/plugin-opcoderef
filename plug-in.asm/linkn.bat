@echo off
if exist conthelp.map del conthelp.map
if exist conthelp.exe del conthelp.plw
if exist conthelp.obj del conthelp.obj
:goto end

nasm -o conthelp.obj -f win32 conthelp.nsm
nasm -o nullstub.bin -f bin nullstub.nsm  

if not exist masm.lib\ida.lib lib -out:masm.lib\ida.lib -def:ida.def
if not exist masm.lib\kernel32.lib lib -out:masm.lib\kernel32.lib -def:kernel32.def
if not exist masm.lib\user32.lib lib -out:masm.lib\user32.lib -def:user32.def
link -nologo -stub:nullstub.bin -dll -entry:DllMain -libpath:masm.lib -def:conthelp.def -out:conthelp.plw ida.lib kernel32.lib user32.lib conthelp.obj
if exist nullstub.obj del nullstub.obj
if exist nullstub.map del nullstub.map

:end
