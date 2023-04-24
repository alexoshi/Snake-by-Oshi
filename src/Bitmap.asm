;###########################################################################
;###########################################################################
; ABOUT Bitmap:
;
;	This code module contains all of the functions that relate to 
; the bitmap files that we use. The files are converted to our SFP format. 
; This file format is similar to the BMP but has a couple variations.
;
;	In order to get this format run BMP_2_SFP provided in the utils
; directory of this archive.
;
;	DWORD -- Width
;	DWORD -- Height
;	WORD -- BPP
;	DWORD -- Size BUFFER
;	BUFFER
;
;	NOTE: The Buffer is already pre-flipped. Just read it in and
;	use it. After converting BGR to RGB.
;
;	The file format only supports 24-bit images and the routines scale 
; these down to 16-bit. Either 5-5-5 or 5-6-5 depending on the machine.
;
;
;###########################################################################
;###########################################################################

;###########################################################################
;###########################################################################
; THE COMPILER OPTIONS
;###########################################################################
;###########################################################################

	.586
	.model flat, stdcall
	option casemap :none   ; case sensitive

;###########################################################################
;###########################################################################
; THE INCLUDES SECTION
;###########################################################################
;###########################################################################

	;================================================
	; These are the Inlcude files for Window stuff
	;================================================
	include \masm32\include\windows.inc
	include \masm32\include\comctl32.inc
	include \masm32\include\comdlg32.inc
	include \masm32\include\shell32.inc
	include \masm32\include\user32.inc
	include \masm32\include\kernel32.inc
	include \masm32\include\gdi32.inc
	include \masm32\include\masm32.inc


	;===============================================
	; The Lib's for those included files
	;================================================
	includelib \masm32\lib\comctl32.lib
	includelib \masm32\lib\comdlg32.lib
	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib
	includelib \masm32\lib\masm32.lib
	includelib jpg.lib
	
	;=================================================
	; Include the file that has our protos
	;=================================================
	include Protos.inc

;###########################################################################
;###########################################################################
; LOCAL MACROS
;###########################################################################
;###########################################################################

	m2m MACRO M1, M2
		push		M2
		pop		M1
	ENDM

	return MACRO arg
		mov	eax, arg
		ret
	ENDM

	RGB MACRO red, green, blue
		xor	eax,eax
		mov	ah,blue
		shl	eax,8
		mov	ah,green
		mov	al,red
	ENDM

	RGB24BIT MACRO red, green, blue
		xor	eax, eax
		mov	eax, red
		and	eax, 255
		shl	eax, 16
		mov	ebx, green
		and	ebx, 255
		shl	ebx, 8
		or	eax, ebx
		mov	ebx, blue
		and	ebx, 255
		or	eax, ebx
	ENDM

	RGB16BIT_555 MACRO red, green, blue
		mov	eax, red
		shr	eax, 3
		shl	eax, 10
		mov	ebx, green
		shr	ebx, 3
		shl	ebx, 5
		or	eax, ebx
		mov	ebx, blue
		shr	ebx, 3
		or	eax, ebx
	ENDM

	RGB16BIT_565 MACRO red, green, blue
		mov	eax, red
		shr	eax, 3
		shl	eax, 11
		mov	ebx, green
		shr	ebx, 3
		shl	ebx, 6
		or	eax, ebx
		mov	ebx, blue
		shr	ebx, 3
		or	eax, ebx
	ENDM

;#################################################################################
;#################################################################################
; Variables we want to use in other modules
;#################################################################################
;#################################################################################

	FILESTRUC	STRUCT
	hFile		dd ?
	hMapping	dd ?
	lpMapping	dd ?
	FILESTRUC	ENDS
;#################################################################################
;#################################################################################
; External variables
;#################################################################################
;#################################################################################
	
	;========================
	; 555 or 565 mode?
	;========================
	EXTERN	Is_555		:BYTE

	;========================
	; RGB Masks and Pos
	;========================
	EXTERN mRed		:DWORD
	EXTERN mGreen		:DWORD
	EXTERN mBlue		:DWORD
	EXTERN pRed		:BYTE
	EXTERN pGreen		:BYTE
	EXTERN pBlue		:BYTE

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data

	;=====================================
	; This is for the call to read file
	;=====================================
	Amount_Read	dd 0









;#################################################################################
;#################################################################################
; BEGIN CONSTANTS
;#################################################################################
;#################################################################################


;#################################################################################
;#################################################################################
; BEGIN EQUATES
;#################################################################################
;#################################################################################

	;=================
	;Utility Equates
	;=================
FALSE		equ	0
TRUE		equ	1

;#################################################################################
;#################################################################################
; BEGIN THE CODE SECTION
;#################################################################################
;#################################################################################

  .code


;########################################################################
; Create_From_SFP Procedure
;########################################################################
Create_From_SFP proc	ptr_BMP:DWORD, sfp_file:DWORD, desired_bpp:DWORD

	;=========================================================
	; This function will allocate our bitmap structure and
	; will load the bitmap from an SFP file. Converting if 
	; it is needed based on the passed value.
	;=========================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	hFile		:DWORD
	LOCAL	hSFP		:DWORD
	LOCAL	Img_Left	:DWORD
	LOCAL	Img_Alias	:DWORD
	LOCAL	red		:DWORD
	LOCAL	green		:DWORD
	LOCAL	blue		:DWORD
	LOCAL	Dest_Alias	:DWORD

	;=================================
	; Create the SFP file
	;=================================
	invoke CreateFile, sfp_file, GENERIC_READ,FILE_SHARE_READ, \
		NULL,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,NULL
	mov	hFile, eax

	;===============================
	; Test for an error
	;===============================
	.if eax == INVALID_HANDLE_VALUE
		jmp err
	.endif

	;===============================
	; Get the file size
	;===============================
	invoke GetFileSize, hFile, NULL
	push	eax

	;================================
	; test for an error
	;================================
	.if eax == -1
		jmp	err
	.endif

	;==============================================
	; Allocate enough memeory to hold the file
	;==============================================
	invoke GlobalAlloc, GMEM_FIXED, eax
	mov	hSFP, eax

	;===================================
	; test for an error
	;===================================
	.if eax == 0
		jmp	err
	.endif

	;===================================
	; Put the file into memory
	;===================================
	pop	eax
	invoke ReadFile, hFile, hSFP, eax, offset Amount_Read, NULL

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err
	
	.endif

	;===================================
	; Determine the size without the BPP
	;===================================
	mov	ebx, hSFP
	mov	eax, DWORD PTR [ebx]
	add	ebx, 4
	mov	ecx, DWORD PTR [ebx]
	mul	ecx
	push	eax
	
	;======================================
	; Do we allocate a 16 or 24 bit buffer
	;======================================
	.if desired_bpp == 16
		;============================
		; Just allocate a 16-bit
		;============================
		pop	eax
		shl	eax, 1
		invoke GlobalAlloc, GMEM_FIXED, eax
		mov	ebx, ptr_BMP
		mov	DWORD PTR [ebx], eax
		mov	Dest_Alias, eax

		;====================================
		; Test for an error
		;====================================
		.if eax == FALSE
			;========================
			; We failed so leave
			;========================
			jmp	err
	
		.endif

	.else
		;========================================
		; This is where code for 24 bit would go
		;========================================

		;============================
		; For now just return an err
		;============================
		jmp	err

	.endif

	;====================================
	; Setup for reading in
	;====================================
	mov	ebx, hSFP
	add	ebx, 10
	mov	eax, DWORD PTR[ebx]
	mov	Img_Left, eax
	add	ebx, 4
	mov	Img_Alias, ebx

	;====================================
	; Now lets start converting values
	;====================================
	.while Img_Left > 0
		;==================================
		; Build a color word based on 
		; the desired BPP or transfer
		;==================================
		.if desired_bpp == 16
			;==========================================
			; Read in a byte for blue, green and red
			;==========================================
			xor	ecx, ecx
			mov	ebx, Img_Alias
			mov	cl, BYTE PTR [ebx]
			mov	blue, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	green, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	red, ecx
		
			;=======================
			; Adjust the Img_Alias
			;=======================
			add	Img_Alias, 3

			;================================
			; Do we build a 555 or a 565 val
			;================================
			.if Is_555 == TRUE
				;============================
				; Build the 555 color word
				;============================
				RGB16BIT_555 red, green, blue
			.else
				;============================
				; Build the 565 color word
				;============================
				RGB16BIT_565 red, green, blue

			.endif

			;================================
			; Transer it to the final buffer
			;================================
			mov	ebx, Dest_Alias
			mov	WORD PTR [ebx], ax

			;============================
			; Adjust the dest by 2
			;============================
			add	Dest_Alias, 2

		.else
			;========================================
			; This is where code for 24 bit would go
			;========================================

			;============================
			; For now just return an err
			;============================
			jmp	err
		
		.endif

		;=====================
		; Sub amount left by 3
		;=====================
		sub	Img_Left, 3

	.endw

	;====================================
	; Free the SFP Memory
	;====================================
	invoke GlobalFree, hSFP

done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;====================================
	; Free the SFP Memory
	;====================================
	invoke GlobalFree, hSFP

	;===================
	; We didn't make it
	;===================
	return FALSE

Create_From_SFP ENDP
;########################################################################
; END Create_From_SFP
;########################################################################

;########################################################################
; Create_From_TGA Procedure
;########################################################################
Create_From_TGA proc	ptr_BMP:DWORD, tga_file:DWORD, desired_bpp:DWORD

	;=========================================================
	; This function will allocate our bitmap structure and
	; will load the bitmap from an SFP file. Converting if
	; it is needed based on the passed value.
	;=========================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	hTFile		 :DWORD
	LOCAL	hTGA		:DWORD
	LOCAL	Img_Left	:DWORD
	LOCAL	Img_Alias	:DWORD
	LOCAL	red		:DWORD
	LOCAL	green		:DWORD
	LOCAL	blue		:DWORD
	LOCAL	Dest_Alias	:DWORD
	LOCAL	zize		:DWORD
	LOCAL	zizef		:DWORD
	LOCAL	hmemory 	:DWORD


	LOCAL	hFile		:DWORD


	invoke GlobalAlloc, GMEM_FIXED, 20
	mov hmemory, eax

	.if eax == 0
	    jmp err
	.endif

	mov ebx, hmemory

	;=================================
	; Create the TGA file
	;=================================
	invoke CreateFile, tga_file, GENERIC_READ,FILE_SHARE_READ, \
		NULL,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,NULL
	mov	hTFile, eax

	;===============================
	; Test for an error
	;===============================
	.if eax == INVALID_HANDLE_VALUE
		jmp err
	.endif

	;===============================
	; Get the file size
	;===============================
	invoke GetFileSize, hTFile, NULL
	push	eax
	mov	zizef, eax

	mov	edx, hmemory
	mov	DWORD PTR[edx], eax
	;================================
	; test for an error
	;================================
	.if eax == -1
		jmp	err
	.endif

	;==============================================
	; Allocate enough memeory to hold the file
	;==============================================
	invoke GlobalAlloc, GMEM_FIXED, eax
	mov	hTGA, eax

	;===================================
	; test for an error
	;===================================
	.if eax == 0
		jmp	err
	.endif

	;===================================
	; Put the file into memory
	;===================================
	pop	eax
	invoke ReadFile, hTFile, hTGA, eax, offset Amount_Read, NULL

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif

	;===================================
	; Determine the size without the BPP
	;===================================
	mov	ebx, hTGA
	add	ebx, 12
	xor	eax, eax
	add	ebx, 1
	mov	al, BYTE PTR [ebx]
	sub	ebx, 1
	shl	eax, 8
	mov	al, BYTE PTR [ebx]
	add	ebx, 3
	push	eax

	mov	edx, hmemory
	add	edx, 4
	mov	DWORD PTR[edx], eax

	xor	eax, eax
	mov	al, BYTE PTR [ebx]
	sub	ebx, 1
	shl	eax, 8
	mov	al, BYTE PTR [ebx]

	mov	edx, hmemory
	add	edx, 8
	mov	DWORD PTR[edx], eax

	pop	ecx
	mul	ecx
	mov	ecx, 3
	mov	zize, eax


	push	eax
	mul	ecx
	add	eax, 18
	mov	edx, hmemory
	add	edx, 16
	mov	DWORD PTR[edx], eax

	.if eax != zizef
		jmp	err
	.endif

	;======================================
	; Do we allocate a 16 or 24 bit buffer
	;======================================
	.if desired_bpp == 16
		;============================
		; Just allocate a 16-bit
		;============================
		pop	eax
		shl	eax, 1

		mov	edx, hmemory
		add	edx, 12
		mov	DWORD PTR[edx], eax

		invoke GlobalAlloc, GMEM_FIXED, eax

		;====================================
		; Test for an error
		;====================================
		.if eax == FALSE
			;========================
			; We failed so leave
			;========================
			jmp	err

		.endif

		mov	ebx, ptr_BMP
		mov	DWORD PTR [ebx], eax
		mov	Dest_Alias, eax
	.else
		;========================================
		; This is where code for 24 bit would go
		;========================================

		;============================
		; For now just return an err
		;============================
		jmp	err

	.endif

	;====================================
	; Setup for reading in
	;====================================
	mov	ebx, hTGA
	add	ebx, 18
	mov	eax, zize
	mov	ecx, 3
	mul	ecx
	mov	Img_Left, eax
	mov	Img_Alias, ebx
	add	Img_Alias, eax
	sub	Img_Alias, 3


	;====================================
	; Now lets start converting values
	;====================================
	.while Img_Left > 0
		;==================================
		; Build a color word based on
		; the desired BPP or transfer
		;==================================
		.if desired_bpp == 16
			;==========================================
			; Read in a byte for blue, green and red
			;==========================================
			xor	ecx, ecx
			mov	ebx, Img_Alias
			mov	cl, BYTE PTR [ebx]
			mov	blue, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	green, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	red, ecx

			;=======================
			; Adjust the Img_Alias
			;=======================
			sub	Img_Alias, 3

			;================================
			; Do we build a 555 or a 565 val
			;================================
			.if Is_555 == TRUE
				;============================
				; Build the 555 color word
				;============================
				RGB16BIT_555 red, green, blue
			.else
				;============================
				; Build the 565 color word
				;============================
				RGB16BIT_565 red, green, blue

			.endif

			;================================
			; Transer it to the final buffer
			;================================
			mov	ebx, Dest_Alias
			mov	WORD PTR [ebx], ax

			;============================
			; Adjust the dest by 2
			;============================
			add	Dest_Alias, 2

		.else
			;========================================
			; This is where code for 24 bit would go
			;========================================

			;============================
			; For now just return an err
			;============================
			jmp	err

		.endif

		;=====================
		; Sub amount left by 3
		;=====================
		sub	Img_Left, 3

	.endw

	;====================================
	; Free the TGA Memory
	;====================================



	invoke GlobalFree, hmemory
	invoke GlobalFree, hTGA

done:
	;===================
	; We completed
	;===================
	return TRUE





err:
	invoke GlobalFree, hmemory
	;====================================
	; Free the TGA Memory
	;====================================
	invoke GlobalFree, hTGA
	;===================
	; We didn't make it
	;===================
	return FALSE

Create_From_TGA ENDP
;########################################################################
; END Create_From_TGA
;########################################################################





;########################################################################
; Create_From_JPG Procedure
;########################################################################
Create_From_JPG proc	ptr_BMP:DWORD, jpg_file:DWORD, desired_bpp:DWORD

	;=========================================================
	; This function will allocate our bitmap structure and
	; will load the bitmap from an SFP file. Converting if
	; it is needed based on the passed value.
	;=========================================================


	;=================================
	; Local Variables
	;=================================

	LOCAL	hJPG		:DWORD
	LOCAL	Img_Left	:DWORD
	LOCAL	Img_Alias	:DWORD
	LOCAL	red		:DWORD
	LOCAL	green		:DWORD
	LOCAL	blue		:DWORD
	LOCAL	Dest_Alias	:DWORD
	LOCAL	zize		:DWORD
	LOCAL	zizef		:DWORD
	LOCAL	hmemory 	:DWORD



       invoke GlobalAlloc, GMEM_FIXED, 1440000
	mov hJPG, eax

	.if eax == 0
	    jmp err
	.endif

invoke read_JPEG_file, jpg_file, hJPG
   .if eax == FALSE
    jmp err
   .endif

	;======================================
	; Do we allocate a 16 or 24 bit buffer
	;======================================
	.if desired_bpp == 16
		;============================
		; Just allocate a 16-bit
		;============================


		invoke GlobalAlloc, GMEM_FIXED, 960000

		;====================================
		; Test for an error
		;====================================
		.if eax == FALSE
			;========================
			; We failed so leave
			;========================
			jmp	err

		.endif

		mov	ebx, ptr_BMP
		mov	DWORD PTR [ebx], eax
		mov	Dest_Alias, eax
	.else
		;========================================
		; This is where code for 24 bit would go
		;========================================

		;============================
		; For now just return an err
		;============================
		jmp	err

	.endif

	;====================================
	; Setup for reading in
	;====================================
	mov	ebx, hJPG

	mov	eax, 480000
	mov	ecx, 3
	mul	ecx
	mov	Img_Left, eax
	mov	Img_Alias, ebx
	add	Img_Alias, eax
	sub	Img_Alias, 3


	;====================================
	; Now lets start converting values
	;====================================
	.while Img_Left > 0
		;==================================
		; Build a color word based on
		; the desired BPP or transfer
		;==================================
		.if desired_bpp == 16
			;==========================================
			; Read in a byte for blue, green and red
			;==========================================
			xor	ecx, ecx
			mov	ebx, Img_Alias
			mov	cl, BYTE PTR [ebx]
			mov	red, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	green, ecx
			inc	ebx
			mov	cl, BYTE PTR [ebx]
			mov	blue, ecx

			;=======================
			; Adjust the Img_Alias
			;=======================
			sub	Img_Alias, 3

			;================================
			; Do we build a 555 or a 565 val
			;================================
			.if Is_555 == TRUE
				;============================
				; Build the 555 color word
				;============================
				RGB16BIT_555 red, green, blue
			.else
				;============================
				; Build the 565 color word
				;============================
				RGB16BIT_565 red, green, blue

			.endif

			;================================
			; Transer it to the final buffer
			;================================
			mov	ebx, Dest_Alias
			mov	WORD PTR [ebx], ax

			;============================
			; Adjust the dest by 2
			;============================
			add	Dest_Alias, 2

		.else
			;========================================
			; This is where code for 24 bit would go
			;========================================

			;============================
			; For now just return an err
			;============================
			jmp	err

		.endif

		;=====================
		; Sub amount left by 3
		;=====================
		sub	Img_Left, 3

	.endw





	invoke GlobalFree, hJPG



done:
     return TRUE

err:

    return FALSE

Create_From_JPG ENDP
;########################################################################
; Draw_Bitmap Procedure
;########################################################################
Draw_Bitmap proc	surface:DWORD, bmp_buffer:DWORD, lPitch:DWORD, 
			bWidth:DWORD, bHeight:DWORD, bpp:DWORD

	;=========================================================
	; This function will draw the BMP on the surface. 
	; the surface must be locked before the call.
	;
	; It uses the width and height that was passed in
	; to do so.
	;
	; This routine does not do transparency!
	;=========================================================

	;===========================
	; Local Variables
	;===========================
	LOCAL	dest_addr	:DWORD
	LOCAL	source_addr	:DWORD

	;=============================
	; Setup num of bytes in width
	; Width*2/4.
	;=============================
	mov	ecx, bWidth
	shl	ecx, 1
	shr	ecx, 2

	;===========================
	; Init counter with height
	;===========================
	mov	edx, bHeight

	;===========================
	; Init the addresses
	;===========================
	mov	eax, surface
	mov	ebx, bmp_buffer
	mov	dest_addr, eax
	mov	source_addr, ebx
	

	;=================================
	; We are in 16 bit mode
	;=================================

	copy_loop1:	
	;=============================
	; Set source and dest
	;=============================
	mov	edi, dest_addr
	mov	esi, source_addr

	;======================================
	; Move by DWORDS
	;======================================
	push	ecx
	rep	movsd
	pop	ecx
		
	;==============================
	; Adjust the variables
	;==============================
	mov	eax, lPitch
	mov	ebx, bWidth
	shl	ebx, 1
	add	dest_addr, eax
	add	source_addr, ebx

	;========================
	; Dec the line counter
	;========================
	dec	edx	  

	;========================
	; Did we hit bottom?
	;========================
	jne copy_loop1


done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

Draw_Bitmap	ENDP
;########################################################################
; END Draw_Bitmap
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end 

