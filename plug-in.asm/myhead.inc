
; Windows stuff

HELP_PARTIALKEY equ  0105h
HELP_CONTEXTPOPUP equ 0008h
MAXPATH equ 1024

extrn GetActiveWindow:proc

ifdef DEBUG
extrn MessageBoxA:proc
MessageBox equ MessageBoxA
endif ; DEBUG


extrn SearchPathA:proc
SearchPath equ SearchPathA

extrn WinHelpA:proc
WinHelp equ WinHelpA

extrn wsprintfA:proc
wsprintf equ wsprintfA

; IDA stuff

;ea_t equ unsigned long        ; effective address is 32bit

IDP_INTERFACE_VERSION   equ 61

;plugin_t struc 
;  version    dd ?       ; Should be equal to IDP_INTERFACE_VERSION
;  flags      dd ?       ; Features of the plugin:
PLUGIN_MOD	 equ 0001h      ; Plugin changes the database.
;                                ; IDA won't call the plugin if
;                                ; the processor prohibited any changes
;                                ; by setting PR_NOCHANGES in processor_t.
PLUGIN_DRAW	 equ 0002h      ; IDA should redraw everything after calling
;                                ; plugin
PLUGIN_SEG       equ 0004h      ; Plugin may be applied only if the
;                                ; current address belongs to a segment
PLUGIN_UNL       equ 0008h      ; Unload the plugin immediately after
;                                ; calling 'run'.
;                                ; This flag may be set anytime.
;                                ; The kernel checks it after each call to 'run'
;                                ; The main purpose of this flag is to ease
;                                ; debugging of new plugins.
;  init       dd ? ;(__stdcall* )(void) ; Initialize plugin
PLUGIN_SKIP     equ  0  ; Plugin doesn't want to be loaded
PLUGIN_OK       equ  1  ; Plugin agrees to work with the current database
;                        ; It will be loaded as soon as the user presses the hotkey
PLUGIN_KEEP     equ  2  ; Plugin agrees to work with the current database
;                        ; and wants to stay in the memory
;  term       dd ? ;void (__stdcall* )(void)   ; Terminate plugin. This function will be called
;                        ; when the plugin is unloaded. May be NULL.
;  run        dd ? ;void (__stdcall* )(int arg) ; Invoke plugin
;  comment    dd ?       ; Long comment about the plugin
;                        ; it could appear in the status line
;                        ; or as a hint
;  help       dd ?       ; Multiline help about the plugin
;  wanted_name dd ?      ; The preferred short name of the plugin
;  wanted_hotkey dd ?    ; The preferred hotkey to run the plugin
;plugin_t ends

PLFM_386	equ       0       ; Intel 80x86

processor_t struc
  version   dd ?                ; Expected kernel version,
                                ;   should be IDP_INTERFACE_VERSION
  id        dd ?                ; IDP id
processor_t ends

extrn ph:dword

;extern "C" processor_t __declspec(dllimport) ph   ; Current processor

extrn callui:dword
;extern "C" unsigned long __declspec(dllimport) (__stdcall*callui)(int what,...)

extrn idadir:proc
;extern "C" const char *__stdcall idadir(void)

extrn ua_mnem:proc
;extern "C" const char *__stdcall ua_mnem(unsigned long ea, char *buf, size_t bufsize)

ui_screenea equ 9
ui_msg equ 21

;#define msg(format) (*callui)(ui_msg, format)
;#define get_screen_ea() (*callui)(ui_screenea)
