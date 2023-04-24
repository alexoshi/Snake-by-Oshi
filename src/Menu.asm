;###########################################################################
;###########################################################################
; ABOUT Menu:
;
;	This code module contains all of the functions that relate to
; the menu that we use.
;
;	There are routines for each menu we will have. One for the main
; menu and one for the load/save menu stuff.
;
;	NOTE: We could have combined these two functions into one generic
; function that used parameters to determine the bahavior. But, by coding
; it explicitly we get a better idea for what is going on in the code.
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
	; The Direct Input include file
	;====================================
	include Includes\DInput.inc

	;====================================
	; The Direct Sound include file
	;====================================
	include Includes\DSound.inc

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

;#################################################################################
;#################################################################################
; Variables we want to use in other modules
;#################################################################################
;#################################################################################


;#################################################################################
;#################################################################################
; External variables
;#################################################################################
;#################################################################################

	;=================================
	; The DirectDraw stuff
	;=================================
	EXTERN	lpddsprimary	:LPDIRECTDRAWSURFACE4
	EXTERN	lpddsback	:LPDIRECTDRAWSURFACE4

	;=========================================
	; The Input Device state variables
	;=========================================
	EXTERN keyboard_state	:BYTE

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data

	;===============================
	; Strings for the bitmaps
	;===============================
	; PTR to the BMP's
	;===============================
	szMainMenu		db "Data\Menu.sfp",0
	ptr_MAIN_MENU	dd 0
	szOptionMenu		  db "Data\FileMenu.sfp",0
	ptr_OPTION_MENU   dd 0
	szredback		  db "Data\blauback.sfp",0
	ptr_EDIT_MENU	  dd 0
	ptr_BMP 	dd 0


	srcbltc 	DDCOLORKEY	<0,0>

	SrcRectROCKET	RECT	<0,0,44,44>

	;================================
	; Our very cool menu sound
	;================================
	;===============================
	; ID for the Menu sound
	;===============================
	szMenuSnd	db "Sound\Background.wav",0
	Menu_ID 	dd 0

	;======================================
	; A value to hold lPitch when locking
	;======================================
	lPitch		dd 0

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

	;=================
	; The Screen BPP
	;=================
screen_bpp	equ	16

;=================
; The Menu Codes
;=================
	; Generic
MENU_ERROR	equ	0h
MENU_NOTHING	equ	1h

	; Main Menu
MENU_NEW	equ	2h
MENU_LOAD	equ	3h
MENU_OPTION	equ	4h
MENU_EXIT	equ	5h
MENU_BACK	equ	6h
MENU_EDIT	equ	7h

MENU_MAIN	equ	8h

	;=================
	; Movement EQU's
	;=================
MOVE_LEFT	equ	1
MOVE_RIGHT	equ	2
MOVE_UP 	equ	3
MOVE_DOWN	equ	4

;#################################################################################
;#################################################################################
; BEGIN THE CODE SECTION
;#################################################################################
;#################################################################################

  .code

;########################################################################
; Init_Menu Procedure
;########################################################################
Init_Menu	proc

	;===========================================================
	; This function will initialize our menu systems
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_SFP, ADDR ptr_MAIN_MENU, ADDR szMainMenu, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif

	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_SFP, ADDR ptr_OPTION_MENU, ADDR szOptionMenu, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif

	;======================================
	; Read in the bitmap and create buffer
	;======================================
	invoke Create_From_SFP, ADDR ptr_EDIT_MENU, ADDR szredback, screen_bpp

	;====================================
	; Test for an error
	;====================================
	.if eax == FALSE
		;========================
		; We failed so leave
		;========================
		jmp	err

	.endif




	;========================
	; Load in the menu sound
	;========================
	invoke Load_WAV, ADDR szMenuSnd, NULL
	mov	Menu_ID, eax


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

Init_Menu	ENDP
;########################################################################
; END Init_Menu
;########################################################################

;########################################################################
; Shutdown_Menu Procedure
;########################################################################
Shutdown_Menu	proc

	;===========================================================
	; This function will shutdown our menu systems
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;==========================
	; Free the bitmap memory
	;==========================
	invoke GlobalFree, ptr_MAIN_MENU
	invoke GlobalFree, ptr_OPTION_MENU
	invoke GlobalFree, ptr_EDIT_MENU


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

Shutdown_Menu	ENDP
;########################################################################
; END Shutdown_Menu
;########################################################################

;########################################################################
; Process_Main_Menu Procedure
;########################################################################
Process_Main_Menu	proc

	;===========================================================
	; This function will process the main menu for the game
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

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
	invoke Draw_Bitmap, eax, ptr_MAIN_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif

	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif

	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard

	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_N]
		;======================
		; Stop the menu music
		;======================
		invoke Stop_Sound, Menu_ID


		;======================
		; The new game key
		;======================
		return	MENU_NEW

	.elseif keyboard_state[DIK_1]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_2]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_3]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_4]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_5]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_6]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_7]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_8]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_9]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_0]
		;======================
		; The game files key
		;======================
		return MENU_LOAD
	.elseif keyboard_state[DIK_O]
		;======================
		; The game files key
		;======================
		return MENU_OPTION


	.elseif keyboard_state[DIK_E]
		;======================
		; Stop the menu music
		;======================
		invoke Stop_Sound, Menu_ID

		;======================
		; The exit game key
		;======================
		return MENU_EXIT

	.endif

done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Main_Menu	ENDP
;########################################################################
; END Process_Main_Menu
;########################################################################

;########################################################################
; Process_File_Menu Procedure
;########################################################################
Process_Option_Menu	  proc

	;===========================================================
	; This function will process the file menu for the gane
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

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
	invoke Draw_Bitmap, eax, ptr_OPTION_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif



	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif

	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard

	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_C]
		;======================
		; The load game key
		;======================
		return	MENU_EDIT


	.elseif keyboard_state[DIK_M]

		;======================
		; Return to main key
		;======================
		return MENU_MAIN
	.elseif keyboard_state[DIK_B]

		;======================
		; Return to main key
		;======================
		return MENU_MAIN

	.endif

done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Option_Menu	  ENDP
;########################################################################
; END Process_Option_Menu
;########################################################################
; Process_File_Menu Procedure
;########################################################################
Process_Edit_Menu	proc

	;===========================================================
	; This function will process the file menu for the gane
	;===========================================================

	;=================================
	; Local Variables
	;=================================

	;===================================
	; Lock the DirectDraw back buffer
	;===================================
	invoke DD_Lock_Surface, lpddsback, ADDR lPitch

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
	invoke Draw_Bitmap, eax, ptr_EDIT_MENU, lPitch, 800, 600, screen_bpp

	;===================================
	; Unlock the back buffer
	;===================================
	invoke DD_Unlock_Surface, lpddsback

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif



	;======================================
	; Make sure the Menu sound is playing
	;======================================
	invoke Status_Sound, Menu_ID
	.if !(eax & DSBSTATUS_PLAYING)
		;===================
		; Play the sound
		;===================
		invoke Play_Sound, Menu_ID, DSBPLAY_LOOPING

	.endif

	;=====================================
	; Everything okay so flip displayed
	; surfaces and make loading visible
	; or call transition if needed
	;======================================
		invoke DD_Flip

	;============================
	; Check for an error
	;============================
	.if eax == FALSE
		;===================
		; Jump to err
		;===================
		jmp	err

	.endif


	;========================================================
	; Now read the keyboard to see if they have presses
	; any keys corresponding to our menu
	;========================================================
	invoke DI_Read_Keyboard

	;=============================
	; Did they press a valid key
	;=============================
	.if keyboard_state[DIK_B]
		;======================
		; The load game key
		;======================
		return	MENU_BACK


	.elseif keyboard_state[DIK_M]

		;======================
		; Return to main key
		;======================
		return MENU_MAIN

	.endif

done:
	;===================
	; We completed w/o
	; doing anything
	;===================
	return MENU_NOTHING

err:
	;===================
	; We didn't make it
	;===================
	return MENU_ERROR

Process_Edit_Menu	ENDP
;########################################################################
; END Process_Option_Menu
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end

