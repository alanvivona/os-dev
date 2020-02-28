BITS 32

GLOBAL _Kernel.Start:function

SECTION .text

; BEGIN - Multiboot Header
Multiboot.Signature dd 464367618
Multiboot.Flags dd 3
Multiboot.Checksum dd -464367621
Multiboot.GraphicsRuntime_VbeModeInfoAddr dd 2147483647
Multiboot.GraphicsRuntime_VbeControlInfoAddr dd 2147483647
Multiboot.GraphicsRuntime_VbeMode dd 2147483647
Multiboot.Info_Memory_High dd 0
Multiboot.Info_Memory_Low dd 0
; END - Multiboot Header

Multiboot.Info_Structure dd 0

%include "dev/src/graphics.asm"

_Kernel.Start:
	
	mov eax, VGA.Text.Whitespace
	call VGA._fillScreen
	mov eax, 0xfffffff
	call _wait

	mov eax, VGA.Text.GreenDot
	call VGA._fillScreen
	mov eax, 0xfffffff
	call _wait

	mov eax, VGA.Text.RedHashtag
	call VGA._fillScreen

	; fill one row - BEGIN
	_Kernel.Start.loop.set:
		lea ecx, [VGA.Cols]
	_Kernel.Start.loop:
		push ecx
		call VGA._scroll.horizontal
		pop ecx

		call _getSequenceChar
		or eax, 0x0200		; char is now on eax, let's add the colors: 0 black bg, 2 green fg
 
		mov [VGA.Buffer], ax

		dec ecx
	jnz _Kernel.Start.loop
	; fill one row - END

	;call VGA._scroll.vertical
	
	jmp _Kernel.Start.loop.set ; infinite loop for an infinite matrix

	hlt

_getSequenceChar:
	; returns the next char of a repetitive pattern
	; receives the pattern index in ecx
	; returns the character in eax

	; calc modulo 3 of ecx
	mov dx, 0     
	mov eax, ecx
	mov ebx, 2
	div bx			; divides ecx by 2. dx = modulo and ax = division result

	; edx = modulo result
	lea eax, [0x30 + edx] 	; 0x30 + edx = could be 0x30 ("0") or 0x31 ("1")
	ret

_wait:
	mov ecx, eax
	_wait.loop:
		nop
		loop _wait.loop
	ret