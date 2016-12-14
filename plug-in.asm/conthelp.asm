.386
.model flat, stdcall
option casemap:none

;
; (c) Geocrime, 2004. Released under GNU GPL2.
;
; This is a plug-in for IDA, which adds a context instruction reference help
; capability, virtualy for any supported CPU. Help files have a postfixing
; digit in their name (e.g. opcoderef0.hlp) corresponding to the platform
; number processor_t.id. For Intel 80x86 this is PLFM_386 (0).
;

include myhead.inc
includelib user32.lib
includelib kernel32.lib
includelib ida.lib

MAXMNEM equ 20 ; Hope, the instruction will never get bigger!

POLY EQU 0EDB88320h

SILENT EQU 1 ; Suppress extra warnings

.data

;--------------------------------------------------------------------------
plg_comment db 'Context instruction set reference for IDA', 0

help db 'A sample plugin module', 0Ah
     db 0Ah
     db 'This module shows you how to create plugin modules.', 0Ah
     db 0Ah
     db 'It does nothing useful - just prints a message that is was called', 0Ah
     db 'and shows the current address.', 0Ah, 0


;--------------------------------------------------------------------------
; This is the preferred name of the plugin module in the menu system
; The preferred name may be overriden in plugins.cfg file

wanted_name db 'Context instruction set reference plugin', 0


; This is the preferred hotkey for the plugin module
; The preferred hotkey may be overriden in plugins.cfg file
; Note: IDA won't tell you if the hotkey is not correct
;       It will just disable the hotkey.

wanted_hotkey db 'Alt-0', 0


;--------------------------------------------------------------------------
;
;      PLUGIN DESCRIPTION BLOCK
;
;--------------------------------------------------------------------------

public PLUGIN

PLUGIN label dword
;PLUGIN plugin_t <\
  dd IDP_INTERFACE_VERSION
  dd 0                  ; plugin flags
  dd offset init        ; initialize
  dd 0                  ; terminate. this pointer may be NULL.
  dd offset run         ; invoke plugin
  dd offset plg_comment ; long comment about the plugin
                        ; it could appear in the status line
                        ; or as a hint
  dd offset help        ; multiline help about the plugin
  dd offset wanted_name ; the preferred short name of the plugin
  dd offset wanted_hotkey ; the preferred hotkey to run the plugin
;  >

ifndef SILENT
HlpWrn db 'No instruction reference help file found for current CPU!', 0Ah, 0
endif ; SILENT

PlgFrm db '%s\plugins',0
HlpFrm db 'opcoderef%d.hlp', 0
TopFrm db '%s,%s', 0
KeyFrm db '%s%d', 0

Descr  db 'Description', 0
Oper   db 'Operation', 0
Flags  db 'Flags affected', 0
Except db 'Exceptions', 0
Opcode db 'Opcode', 0

SectnTab dd offset MnmBuf
         dd offset Descr
	 dd offset Oper
	 dd offset Flags
	 dd offset Except
	 dd offset Opcode

Dummy	 dd offset TopBuf

.data?

PthBuf db MAXPATH dup (?)
PlgBuf db MAXPATH dup (?)
MnmBuf db MAXMNEM dup (?)
TopBuf db MAXMNEM * 2 dup (?)

.code

;--------------------------------------------------------------------------
; Ethernet CRC32
;

;;crc32:
;;  pushfd
;;  push  edi
;;  push  esi
;;  push	ecx
;;  mov	esi, eax
;;  mov	edi, esi
;;  xor	eax, eax
;;  mov	ecx, eax
;;  not	ecx
;;  repne	scasb
;;  not	eax
;;  not	ecx
;;  dec	ecx
;;  
;;@@NextByte:
;;  mov	edi, eax
;;
;;  xor	eax, eax
;;  lodsb
;;  cmp	al, 'a'
;;  jl	short @@skip
;;  cmp	al, 'z'
;;  jg	short @@skip
;;  sub	al, ' '
;;
;;@@skip:
;;  xchg	eax, edi
;;  xor 	eax, edi
;;
;;  mov	edi, 8
;;
;;@@NextBit:
;;  shr	eax, 1   
;;  jnc	@@SkipXor
;;  xor	eax, POLY
;;
;;@@SkipXor:
;;  dec	edi
;;  jnz	short @@NextBit
;;  loop	short @@NextByte
;;
;;  not	eax  
;;  pop	ecx
;;  pop	esi
;;  pop	edi
;;  popfd
;;  ret
;;endp

 ; edi = crc, esi = source, ecx = len, eax = bit counter, eflags are destroyed!
 ; PS: after optimizing this code I do not see any sense in using table CRC
 ; calculation, not in 32 bit assembly, anyway.

crc32 macro
  xor	eax, eax
  mov	edi, eax
  not	edi

@@NextByte:
  lodsb
  cmp	al, 'a'
  jl	short @@skip
  cmp	al, 'z'
  jg	short @@skip
  sub	al, ' '

@@skip:
  xor 	edi, eax
;  mov	eax, 8
  mov	al, 8 ; I know this is twice as small as above, but is it faster?

@@NextBit:
  shr	edi, 1   
  jnc	short @@SkipXor
  xor	edi, POLY

@@SkipXor:
  dec	eax
  jnz	short @@NextBit
  loop	short @@NextByte

  not	edi  
endm crc32

DllMain:
  mov eax, 1
  ret 12

init:
  mov	eax, [ph+2] ; Stupid fix for TASM, which doesn't let direct IAT access
  mov	eax, [eax]

  push	[eax+processor_t.id]
  push	offset HlpFrm
  push	offset TopBuf
  call	wsprintf  
  add	esp, 3 * 4

  call	idadir
  push	eax
  push	offset PlgFrm
  push	offset PlgBuf
  call	wsprintf
  add	esp, 3 * 4

  push	offset Dummy ; dummy
  push	offset PthBuf
  push	MAXPATH
  push	0
  push	offset TopBuf
  push  offset PlgBuf
  call	SearchPath
  or	eax, eax    ; Does it exist?
  jz	short @@DoesntExist

  mov	eax, PLUGIN_KEEP
  ret

@@DoesntExist:
ifndef SILENT
  push	offset HlpWrn
  push	ui_msg
  mov	eax, [callui+2] ; Stupid fix for TASM, which doesn't let direct IAT access
  mov	eax, [eax]
  call	[eax] ; msg()
  add	esp, 2 * 4
endif ; SILENT	
  mov	eax, PLUGIN_SKIP
  ret
;endp

;--------------------------------------------------------------------------
;
;      The plugin method
;
;      This is the main function of plugin.
;
;      It will be called when the user selects the plugin.
;
;              arg - the input argument, it can be specified in
;                    plugins.cfg file. The default is zero.
;
;

run:

; Get current loc
push ui_screenea
mov  eax, [callui+2]
mov eax, [eax]
call dword ptr [eax]  ; get_screen_ea()
add esp, 1 * 4

; Get the mnemonic
push MAXMNEM
push offset MnmBuf
push eax
call ua_mnem

mov eax, [esp + 4] ; Get arg

cmp eax, 5 ;  case 0 - 5
ja short @@next
  ; get the help topic
  mov	eax, SectnTab[eax*4]
  push	eax
  push	offset MnmBuf
  push	offset TopFrm
  push	offset TopBuf
  call	wsprintf
  add	esp, 4 * 4
  push	offset TopBuf
  push	HELP_PARTIALKEY
  jmp	short @@GetHelp

@@next:
  cmp	eax, 10 ;  case 6 - 10
  ja	short @@return
  sub	eax, 5

    push eax
    push offset MnmBuf
    push offset KeyFrm
    push offset TopBuf
    call wsprintf 
    add esp, 4 * 4
;    push offset KeyBuf
;    call crc32
    mov esi, offset TopBuf
    mov	ecx, eax
    crc32 ; Macro call instead, make it faster, paranoid!
    push edi
    push HELP_CONTEXTPOPUP

@@GetHelp:
    push offset PthBuf
    call GetActiveWindow
    push eax
    call WinHelp

@@return: ; default:
    retn 4
;endp

end DllMain
