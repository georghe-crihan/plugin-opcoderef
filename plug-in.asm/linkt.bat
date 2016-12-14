@echo off
if exist conthelp.map del conthelp.map
if exist conthelp.exe del conthelp.plw
if exist conthelp.obj del conthelp.obj
:goto end

tasm32 /ml /q conthelp.asm
tasm32 /ml /q nullstub.asm  

tlink /x /t nullstub.obj, nullstub.bin

if not exist tasm.lib\ida.lib implib masm.lib\ida.lib ida.def
if not exist tasm.lib\kernel32.lib implib masm.lib\kernel32.lib kernel32.def
if not exist tasm.lib\user32.lib implib masm.lib\user32.lib user32.def
tlink32 /o /Tpd /aa /c /m /Ltasm.lib conthelp.obj, conthelp.plw, conthelp.map,, conthelp.def
if exist nullstub.obj del nullstub.obj
if exist nullstub.map del nullstub.map

:end
