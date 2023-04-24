;###########################################################################
;###########################################################################
; ABOUT DD_Stuff:
;
;	This code module contains all of the functions that relate to
; the Direct Draw component of DirectX. Just compile it and link.
;
;	NOTE: Some routines have support for 24-bit. If you want to support
; 8 or 24 bit games you will need to add code to many routines in this
; code module.
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
	
	;===============================================
	; The Lib's for those included files
	;================================================
	includelib \masm32\lib\comctl32.lib
	includelib \masm32\lib\comdlg32.lib
	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib

	;====================================
	; The Direct Draw include file
	;====================================
	include Includes\DDraw.inc

	;====================================
	; The Direct Draw library file
	;====================================
	includelib directxlib\lib\DDraw.lib

	;=============================================
	; Since we are using DirectX link in the 
	; DXGUID lib so we don't get GUID errors
	;=============================================
	includelib directxlib\lib\DXGuid.lib
	includelib directxlib\lib\uuid.lib

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

	;=========================================
	; Main Direct Draw object
	;=========================================
	PUBLIC	lpdd

	;=========================================
	; Our Global DirectDraw surfaces
	;=========================================
	PUBLIC	lpddsprimary
	PUBLIC	lpddsback

	;===========================================
	; Is mode 555 or 565??
	;===========================================
	PUBLIC	Is_555

	;===========================================
	; Masks and positions for the RGB values
	;===========================================
	PUBLIC mRed
	PUBLIC mGreen
	PUBLIC mBlue
	PUBLIC pRed
	PUBLIC pGreen
	PUBLIC pBlue

	;===========================================
	; App width and height
	;===========================================
	PUBLIC	app_width
	PUBLIC	app_height

;#################################################################################
;#################################################################################
; External variables
;#################################################################################
;#################################################################################
	
	;=================================
	; The main screen window
	;=================================
	EXTERN	hMainWnd	:DWORD

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data

	;=========================================
	; Main Direct Draw object
	;=========================================
	lpdd		LPDIRECTDRAW4		0

	;=========================================
	; Our Global DirectDraw surfaces
	;=========================================
	lpddsprimary	LPDIRECTDRAWSURFACE4	0
	lpddsback	LPDIRECTDRAWSURFACE4	0

	;===========================================
	; Just a DC for text drawing, an lPitch
	; holder and a temp var
	;===========================================
	hDC		dd 0
	Surface_Pitch	dd 0
	temp		dd 0

	;====================================
	; For creating surfaces
	;====================================
	lpdds		dd 0

	;===========================================
	; Misc structures that we will need
	;===========================================
	ddsd		DDSURFACEDESC2		<>
	ddbltfx 	DDBLTFX 		<>
	ddscaps 	DDSCAPS2		<>

	;===========================================
	; For preserving screen info
	;===========================================
	app_width	dd 0
	app_height	dd 0
	app_bpp 	dd 0

	;===========================================
	; This will tell us 555 or 565 16-bit format
	;===========================================
	Is_555			db 0

	;===========================================
	; Masks and extractors for the RGB pixels
	;===========================================
	mRed			dd 0
	mGreen			dd 0
	mBlue			dd 0
	pRed			db 0
	pGreen			db 0
	pBlue			db 0

	;===========================================
	; A bunch of error strings
	;===========================================
	szNoDD		db "Unable to create Direct Draw Object.",0
	szNoDD4 	db "Unable to create Direct Draw 4 Object. Make sure you have DX 6.0+.",0
	szNoCoop	db "Unable to Set the Cooperative Level.",0
	szNoDisplay	db "Unable to Set the Display Mode.",0
	szNoPrimary	db "Unable to create primary surface.",0
	szNoBackBuffer	db "Unable to create back buffer.",0

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
; DD_Init Procedure
;########################################################################
DD_Init proc	screen_width:DWORD, screen_height:DWORD, screen_bpp:DWORD

	;=======================================================
	; This function will setup DD to full screen exclusive
	; mode at the passed in width, height, and bpp
	;=======================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	lpdd_1		:LPDIRECTDRAW

	;=============================
	; Create a default object
	;=============================
	invoke DirectDrawCreate, 0, ADDR lpdd_1, 0

	;=============================
	; Test for an error
	;=============================
	.if eax != DD_OK
		;======================
		; Give err msg
		;======================
		invoke MessageBox, hMainWnd, ADDR szNoDD, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;=========================================
	; Lets try and get a DirectDraw 4 object
	;=========================================
	DDINVOKE QueryInterface, lpdd_1, ADDR IID_IDirectDraw4, ADDR lpdd

	;=========================================
	; Did we get it??
	;=========================================
	.if eax != DD_OK
		;==============================
		; No so give err message
		;==============================
		invoke MessageBox, hMainWnd, ADDR szNoDD4, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;===================================================
	; Set the cooperative level
	;===================================================
	DD4INVOKE SetCooperativeLevel, lpdd, hMainWnd, \
		DDSCL_ALLOWMODEX or DDSCL_FULLSCREEN or \
		DDSCL_EXCLUSIVE or DDSCL_ALLOWREBOOT
	;=========================================
	; Did we get it??
	;=========================================
	.if eax != DD_OK
		;==============================
		; No so give err message
		;==============================
		invoke MessageBox, hMainWnd, ADDR szNoCoop, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;===================================================
	; Set the Display Mode
	;===================================================
	DD4INVOKE SetDisplayMode, lpdd, screen_width, \
		screen_height, screen_bpp, 0, 0

	;=========================================
	; Did we get it??
	;=========================================
	.if eax != DD_OK
		;==============================
		; No so give err message
		;==============================
		invoke MessageBox, hMainWnd, ADDR szNoDisplay, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;================================
	; Save the screen info
	;================================
	m2m	app_width, screen_width
	m2m	app_height, screen_height
	m2m	app_bpp, screen_bpp

	;========================================
	; Setup to create the primary surface
	;========================================
	DDINITSTRUCT offset ddsd, SIZEOF(DDSURFACEDESC2)
	mov	ddsd.dwSize, SIZEOF(DDSURFACEDESC2)
	mov	ddsd.dwFlags, DDSD_CAPS or DDSD_BACKBUFFERCOUNT;
	mov	ddsd.ddsCaps.dwCaps, DDSCAPS_PRIMARYSURFACE or \
			DDSCAPS_FLIP or DDSCAPS_COMPLEX
	mov	ddsd.dwBackBufferCount, 1

	;========================================
	; Now create the primary surface
	;========================================
	DD4INVOKE CreateSurface, lpdd, ADDR ddsd, ADDR lpddsprimary, NULL

	;=========================================
	; Did we get it??
	;=========================================
	.if eax != DD_OK
		;==============================
		; No so give err message
		;==============================
		invoke MessageBox, hMainWnd, ADDR szNoPrimary, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;==========================================
	; Try to get a backbuffer
	;==========================================
	mov	ddscaps.dwCaps, DDSCAPS_BACKBUFFER
	DDS4INVOKE GetAttachedSurface, lpddsprimary, ADDR ddscaps, ADDR lpddsback

	;=========================================
	; Did we get it??
	;=========================================
	.if eax != DD_OK
		;==============================
		; No so give err message
		;==============================
		invoke MessageBox, hMainWnd, ADDR szNoBackBuffer, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;==========================================
	; Get the RGB format of the surface
	;==========================================
	invoke DD_Get_RGB_Format, lpddsprimary

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

DD_Init ENDP
;########################################################################
; END DD_Init
;########################################################################

;########################################################################
; DD_ShutDown Procedure
;########################################################################
DD_ShutDown proc

	;=======================================================
	; This function will close down DirectDraw release
	; everything needed, etcetera
	;=======================================================

	;===========================
	; Restore the Display Mode
	;===========================
	;DD4INVOKE RestoreDisplayMode, lpdd

	;===========================
	; Do we have surfaces?
	;===========================
	.if lpddsprimary != 0
		;======================
		; Yes. So Release it
		;======================
		DDS4INVOKE Release, lpddsprimary
	.endif

	;===========================
	; Do we have an object?
	;===========================
	.if lpdd != 0
		;======================
		; Yes. So Release it
		;======================
		DDINVOKE Release, lpdd
	.endif

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

DD_ShutDown	ENDP
;########################################################################
; END DD_ShutDown
;########################################################################

;########################################################################
; DD_Lock_Surface Procedure
;########################################################################
DD_Lock_Surface proc	surface:DWORD, lPitch:DWORD

	;=======================================================
	; This function will lock the passed surface
	;=======================================================

	;==========================
	; is this surface valid
	;==========================
	.if (!surface)
		;=====================
		; No jump err
		;=====================
		jmp	err

	.endif

	;=========================
	; lock the surface
	;=========================
	DDINITSTRUCT ADDR ddsd, sizeof(DDSURFACEDESC2)
	mov	ddsd.dwSize, sizeof(DDSURFACEDESC2)
	DDS4INVOKE mLock, surface, NULL, ADDR ddsd, DDLOCK_WAIT or \
		DDLOCK_SURFACEMEMORYPTR, NULL

	;=========================
	; Test for an error
	;=========================
	.if eax != DD_OK
		jmp	err
	.endif

	;========================
	; set the memory pitch
	;========================
	.if (lPitch)
		;=====================
		; Set it
		;=====================
		mov	eax, lPitch
		m2m	DWORD PTR [eax], ddsd.lPitch

	.endif
	
	;============================
	; return pointer to surface
	;============================
	return ddsd.lpSurface
err:
	;===================
	; We didn't make it
	;===================
	return FALSE

DD_Lock_Surface ENDP
;########################################################################
; END DD_Lock_Surface
;########################################################################

;########################################################################
; DD_Unlock_Surface Procedure
;########################################################################
DD_Unlock_Surface proc	surface:DWORD

	;=======================================================
	; This function will unlock the passed surface
	;=======================================================

	;==========================
	; is this surface valid
	;==========================
	.if (!surface)
		;====================
		; No -- Jump err
		;====================
		jmp	err

	.endif

	;============================
	; unlock the surface memory
	;============================
	DDS4INVOKE Unlock, surface, NULL

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

DD_Unlock_Surface	ENDP
;########################################################################
; END DD_Unlock_Surface
;########################################################################

;########################################################################
; DD_Create_Surface Procedure
;########################################################################
DD_Create_Surface proc	surface_width:DWORD, surface_height:DWORD,
			mem_flags:DWORD

	;=======================================================
	; This function will create a surface at the passed size
	; using the passed flags
	;=======================================================

	;=================================
	; Setup the DDSD structure
	;=================================
	DDINITSTRUCT ADDR ddsd, SIZEOF(DDSURFACEDESC2)
	mov	ddsd.dwSize,  sizeof(DDSURFACEDESC2)

	;=======================================
	; Reset the needed values
	;=======================================
	mov	ddsd.dwFlags, DDSD_CAPS or DDSD_WIDTH or DDSD_HEIGHT
	m2m	ddsd.dwWidth, surface_width
	m2m	ddsd.dwHeight, surface_height


	;====================================
	; Set surface to offscreen plain
	;====================================
	mov	eax, mem_flags
	or	eax, DDSCAPS_OFFSCREENPLAIN
	mov	ddsd.ddsCaps.dwCaps, eax

	;=================================
	; Create the surface
	;=================================
	DD4INVOKE CreateSurface, lpdd, ADDR ddsd, ADDR lpdds, NULL

	;============================
	; Check for an error
	;============================
	.if eax != DD_OK
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

done:
	;===================
	; Return Surface
	;===================
	mov	eax, lpdds
	ret

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

DD_Create_Surface	ENDP
;########################################################################
; END DD_Create_Surface
;########################################################################

;########################################################################
; DD_Flip Procedure
;########################################################################
DD_Flip proc

	;=======================================================
	; This function will flip the primary and back buffers
	;=======================================================

	;============================
	; Try to flip them
	;============================
	.repeat
		;================================================
		; Flip with the wait flag
		;================================================
		DDS4INVOKE Flip, lpddsprimary, NULL, DDFLIP_WAIT

	.until eax == DD_OK

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

DD_Flip ENDP
;########################################################################
; END DD_Flip
;########################################################################

;########################################################################
; DD_Fill_Surface Procedure
;########################################################################
DD_Fill_Surface proc	surface:DWORD, red:DWORD, green:DWORD, blue:DWORD

	;=======================================================
	; This function will fill the surface with the passed
	; color. It will build special for 565 or 555.
	;=======================================================

	;=================================================
	; clear out the structure and set the size field
	;=================================================
	DDINITSTRUCT offset ddbltfx, sizeof(DDBLTFX)
	mov	ddbltfx.dwSize, sizeof(DDBLTFX)

	;==================================
	; Are we in 16 bit mode
	;==================================
	.if (app_bpp == 16)
		;================================
		; Yes. Is it 555 format
		;================================
		.if (Is_555)
			;===============================
			; Build up the 555 16 bit color
			;===============================
			RGB16BIT_555 red,green,blue
			mov	ddbltfx.dwFillColor, eax
		.else
			;==============================
			; We are 565 so build that one
			;==============================
			RGB16BIT_565 red, green, blue
			mov	ddbltfx.dwFillColor, eax

		.endif
	.elseif app_bpp == 24
		;===============================
		; Make a 24-bit RGB value
		;===============================
		RGB24BIT red,green,blue
		mov	ddbltfx.dwFillColor, eax

	.endif

	;==================================
	; ready to blt to surface
	;==================================
	DDS4INVOKE Blt, surface, NULL, NULL, NULL, DDBLT_COLORFILL or \
		DDBLT_WAIT, ADDR ddbltfx

done:
	;===================
	; We completed
	;===================
	return TRUE

DD_Fill_Surface ENDP
;########################################################################
; END DD_Fill_Surface
;########################################################################

;########################################################################
; DD_GetDC Procedure
;########################################################################
DD_GetDC proc	surface:DWORD

	;=======================================================
	; This function will get the DC for the primary surface
	;=======================================================

	;=============================
	; Get the DC for the surface
	;=============================
	DDS4INVOKE GetDC, surface, ADDR temp
	.if eax != DD_OK
		jmp	err
	.endif
	
done:
	;===================
	; We completed
	;===================
	return temp

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

DD_GetDC	ENDP
;########################################################################
; END DD_GetDC
;########################################################################

;########################################################################
; DD_ReleaseDC Procedure
;########################################################################
DD_ReleaseDC proc	surface:DWORD, handle:DWORD

	;==========================================================
	; This function will release the DC on the primary surface
	;==========================================================

	;================================
	; Release the DC for the surface
	;================================
	DDS4INVOKE ReleaseDC, surface, handle
	.if eax != DD_OK
		jmp	err
	.endif


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

DD_ReleaseDC	ENDP
;########################################################################
; END DD_ReleaseDC
;########################################################################

;########################################################################
; DD_Draw_Text Procedure
;########################################################################
DD_Draw_Text proc	handle:DWORD, text:DWORD, num_chars:DWORD, 
			ptr_rect:DWORD, format:DWORD, color:DWORD

	;=======================================================
	; This function will draw the passed text on the passed
	; surface using the passed color at the passed coords
	; with GDI -- It presumes surface is locked
	;=======================================================

	;===========================================
	; Set the text color and BK mode
	;===========================================
	invoke SetTextColor, handle, color
	invoke SetBkMode, handle, TRANSPARENT

	;===========================================
	; Write out the text at the desired location
	;===========================================
	invoke DrawText, handle, text, num_chars, ptr_rect, format

done:
	;===================
	; We completed
	;===================
	return TRUE

DD_Draw_Text	ENDP
;########################################################################
; END DD_Draw_Text
;########################################################################

;########################################################################
; DD_Load_Bitmap Procedure
;########################################################################
DD_Load_Bitmap proc	surface:DWORD, ptr_BMP:DWORD, bWidth:DWORD, 
			bHeight:DWORD, bmp_bpp:DWORD

	;=======================================================
	; This function will load the bitmap into the direct 
	; draw surface that is passed
	;=======================================================

	;===================================
	; Lock the DirectDraw surface
	;===================================
	invoke DD_Lock_Surface, surface, ADDR Surface_Pitch

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;===================================
	; Draw the bitmap onto the surface
	;===================================
	invoke Draw_Bitmap, eax, ptr_BMP, Surface_Pitch, bWidth, bHeight, bmp_bpp

	;===================================
	; Unlock the surface
	;===================================
	invoke DD_Unlock_Surface, surface

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


done:
	;===================
	; We completed
	;===================
	return TRUE

err:	
	return FALSE

DD_Load_Bitmap	ENDP
;########################################################################
; END DD_Load_Bitmap
;########################################################################

;########################################################################
; DD_Get_RGB_Format Procedure
;########################################################################
DD_Get_RGB_Format	proc	surface:DWORD

	;=========================================================
	; This function will setup some globals to give us info
	; on whether the pixel format of the current diaplay mode
	;=========================================================

	;====================================
	; Local variables
	;====================================
	LOCAL	shiftcount	:BYTE

	;================================
	; get a surface despriction
	;================================
	DDINITSTRUCT ADDR ddsd, sizeof(DDSURFACEDESC2)
	mov	ddsd.dwSize, sizeof(DDSURFACEDESC2)
	mov	ddsd.dwFlags, DDSD_PIXELFORMAT
	DDS4INVOKE GetSurfaceDesc, surface, ADDR ddsd

	;==============================
	; fill in masking values
	;==============================
	m2m	mRed, ddsd.ddpfPixelFormat.dwRBitMask		; Red Mask
	m2m	mGreen, ddsd.ddpfPixelFormat.dwGBitMask 	; Green Mask
	m2m	mBlue, ddsd.ddpfPixelFormat.dwBBitMask		; Blue Mask

	;====================================
	; Determine the pos for the red mask
	;====================================
	mov	shiftcount, 0
	.while (!(ddsd.ddpfPixelFormat.dwRBitMask & 1))
		shr	ddsd.ddpfPixelFormat.dwRBitMask, 1
		inc	shiftcount
	.endw
	mov	al, shiftcount
	mov	pRed, al

	;=======================================
	; Determine the pos for the green mask
	;=======================================
	mov	shiftcount, 0
	.while (!(ddsd.ddpfPixelFormat.dwGBitMask & 1))
		shr	ddsd.ddpfPixelFormat.dwGBitMask, 1
		inc	shiftcount
	.endw
	mov	al, shiftcount
	mov	pGreen, al

	;=======================================
	; Determine the pos for the blue mask
	;=======================================
	mov	shiftcount, 0
	.while (!(ddsd.ddpfPixelFormat.dwBBitMask & 1))
		shr	ddsd.ddpfPixelFormat.dwBBitMask, 1
		inc	shiftcount
	.endw
	mov	al, shiftcount
	mov	pBlue, al

	;===========================================
	; Set a special var if we are in 16 bit mode
	;===========================================
	.if app_bpp == 16
		.if pRed == 10
			mov	Is_555, TRUE
		.else
			mov	Is_555, FALSE
		.endif
	.endif

done:
	;===================
	; We completed
	;===================
	return TRUE

DD_Get_RGB_Format	ENDP
;########################################################################
; END DD_Get_RGB_Format
;########################################################################

;########################################################################
; DD_Select_Font Procedure
;########################################################################
DD_Select_Font proc	handle:DWORD, lfheight:DWORD, lfweight:DWORD,\
			ptr_szName:DWORD, ptr_old_obj:DWORD

	;=======================================================
	; This function will create & select the font after 
	; altering the font structure based on the params
	;=======================================================

	;=================================
	; Create the FONT object
	;=================================
	invoke CreateFont, lfheight, 0, 0, 0, lfweight, 0, 0, \
		0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_STROKE_PRECIS,\
		DEFAULT_QUALITY, DEFAULT_PITCH or FF_DONTCARE, ptr_szName
	mov	temp, eax

	;===================================
	; Select the font and preserve old
	;===================================
	invoke SelectObject, handle, eax
	mov	ebx, ptr_old_obj
	mov	[ebx], eax

done:
	;===================
	; We completed
	;===================
	return temp

err:
	;===================
	; We didn't make it
	;===================
	return FALSE

DD_Select_Font	ENDP
;########################################################################
; END DD_Select_Font
;########################################################################

;########################################################################
; DD_UnSelect_Font Procedure
;########################################################################
DD_UnSelect_Font proc	handle:DWORD, font_object:DWORD, old_object:DWORD

	;=======================================================
	; This function will delete the font object and restore
	; the old object
	;=======================================================

	;==================================
	; Restore old obj and delete font
	;==================================
	invoke SelectObject, handle, old_object
	invoke DeleteObject, font_object

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

DD_UnSelect_Font	ENDP
;########################################################################
; END DD_UnSelect_Font
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end 

