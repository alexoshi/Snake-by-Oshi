;###########################################################################
;###########################################################################
; ABOUT DI_Stuff:
;
;	This code module contains all of the functions that relate to 
;	the Direct Input component of DirectX. Just compile it and link.
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
	; The Direct Input include file
	;====================================
	include Includes\DInput.inc


	;====================================
	; The Direct Input library file
	;====================================
	includelib directxlib\lib\DInput.lib

	;===========================================
	; THE GUIDS ARE LINKED IN THE DD MODULE
	;===========================================
	
	;=================================================
	; Include the file that has our protos
	;=================================================
	include Protos.inc

;###########################################################################
;###########################################################################
; LOCAL MACROS
;###########################################################################
;###########################################################################

	szText MACRO Name, Text:VARARG
		LOCAL lbl
		jmp lbl
		Name db Text,0
		lbl:
	ENDM

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

	;=========================================
	; Main Direct Input object
	;=========================================
	PUBLIC	lpdi
	
	;=========================================
	; The Input Device state variables
	;=========================================
	PUBLIC keyboard_state

;#################################################################################
;#################################################################################
; External variables
;#################################################################################
;#################################################################################
	
	;=================================
	; The main screen window
	;=================================
	EXTERN	hMainWnd	:DWORD
	EXTERN	hInst		:DWORD

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data

	;=========================================
	; Main Direct Input object
	;=========================================
	lpdi		LPDIRECTINPUT		0


	;=========================================
	; Our Global DirectInput Devices
	;=========================================
	lpdikey 	LPDIRECTINPUTDEVICE	?	; dinput keyboard
	lpdimouse	LPDIRECTINPUTDEVICE	?	; dinput mouse

	;=========================================
	; Our Variables to hold device states
	;=========================================
	keyboard_state	db 256 dup	(0)	; contains keyboard state table
	mouse_state	DIMOUSESTATE	<>	; contains state of mouse

	;===========================================
	; A bunch of error strings
	;===========================================
	szNoDI		db "Unable to create Initialize Direct Input.",0

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
; DI_Init Procedure
;########################################################################
DI_Init proc

	;=======================================================
	; This function will setup Direct Input
	;=======================================================

	;=============================
	; Create our direct Input obj
	;=============================
	invoke DirectInputCreate, hInst, DIRECTINPUT_VERSION, ADDR lpdi,0

	;=============================
	; Test for an error creating
	;=============================
	.if eax != DI_OK
		jmp	err
	.endif

	;=============================
	; Intiialize the keyboard
	;=============================
	invoke DI_Init_Keyboard

	;=============================
	; Test for an error in init
	;=============================
	.if eax == FALSE
		jmp	err
	.endif

	;=============================
	; Intiialize the mouse
	;=============================
	invoke DI_Init_Mouse

	;=============================
	; Test for an error in init
	;=============================
	.if eax == FALSE
		jmp	err
	.endif

done:
	;===================
	; We completed
	;===================
	return TRUE

err:
	;===================
	; Give the error msg
	;===================
	invoke MessageBox, hMainWnd, ADDR szNoDI, NULL, MB_OK

	;===================
	; We didn't make it
	;===================
	return FALSE

DI_Init ENDP
;########################################################################
; END DI_Init
;########################################################################

;########################################################################
; DI_ShutDown Procedure
;########################################################################
DI_ShutDown proc

	;=======================================================
	; This function will close down Direct Input
	;=======================================================

	;=============================
	; Shutdown the Mouse
	;=============================
	DIDEVINVOKE Unacquire, lpdimouse
	DIDEVINVOKE Release, lpdimouse

	;=============================
	; Shutdown the Keyboard
	;=============================
	DIDEVINVOKE Unacquire, lpdikey
	DIDEVINVOKE Release, lpdikey

	;==================================
	; Shutdown the Direct Input object
	;==================================
	DIINVOKE Release, lpdi

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

DI_ShutDown	ENDP
;########################################################################
; END DI_ShutDown
;########################################################################

;########################################################################
; DI_Init_Mouse  Procedure
;########################################################################
DI_Init_Mouse	 proc 

	;=======================================================
	; This function will initialize the mouse
	;=======================================================

	;===========================
	; Now try and create it
	;===========================
	DIINVOKE CreateDevice, lpdi, ADDR GUID_SysMouse, ADDR lpdimouse, 0

	;============================
	; Test for an error creating
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;==========================
	; Set the coop level
	;==========================
	DIDEVINVOKE SetCooperativeLevel, lpdimouse, hMainWnd, \
		  DISCL_NONEXCLUSIVE or DISCL_BACKGROUND

	;============================
	; Test for an error querying
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;==========================
	; Set the data format
	;==========================
	DIDEVINVOKE SetDataFormat, lpdimouse, ADDR c_dfDIMouse

	;============================
	; Test for an error querying
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;===================================
	; Now try and acquire the mouse
	;===================================
	DIDEVINVOKE Acquire, lpdimouse

	;============================
	; Test for an error acquiring
	;============================
	.if eax != DI_OK
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

DI_Init_Mouse	ENDP
;########################################################################
; END DI_Init_Mouse	
;########################################################################

;########################################################################
; DI_Init_Keyboard	 Procedure
;########################################################################
DI_Init_Keyboard	 proc 

	;=======================================================
	; This function will initialize the keyboard
	;=======================================================

	;===========================
	; Now try and create it
	;===========================
	DIINVOKE CreateDevice, lpdi, ADDR GUID_SysKeyboard, ADDR lpdikey, 0

	;============================
	; Test for an error creating
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;==========================
	; Set the coop level
	;==========================
	DIDEVINVOKE SetCooperativeLevel, lpdikey, hMainWnd, \
		  DISCL_NONEXCLUSIVE or DISCL_BACKGROUND

	;============================
	; Test for an error querying
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;==========================
	; Set the data format
	;==========================
	DIDEVINVOKE SetDataFormat, lpdikey, ADDR c_dfDIKeyboard

	;============================
	; Test for an error querying
	;============================
	.if eax != DI_OK
		jmp	err
	.endif

	;===================================
	; Now try and acquire the keyboard
	;===================================
	DIDEVINVOKE Acquire, lpdikey

	;============================
	; Test for an error acquiring
	;============================
	.if eax != DI_OK
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

DI_Init_Keyboard	ENDP
;########################################################################
; END DI_Init_Keyboard	
;########################################################################

;########################################################################
; DI_Read_Mouse  Procedure
;########################################################################
DI_Read_Mouse	 proc 

	;================================================================
	; This function will read the mouse and set the input state
	;================================================================

	;============================
	; Read if it exists
	;============================
	.if lpdimouse != NULL 
		;========================
		; Now read the state
		;========================
		DIDEVINVOKE GetDeviceState, lpdimouse, sizeof(DIMOUSESTATE), ADDR mouse_state
		.if eax != DI_OK
			jmp	err
		.endif
	.else
		;==============================================
		; mouse isn't plugged in, zero out state
		;==============================================
		DIINITSTRUCT ADDR mouse_state, sizeof(DIMOUSESTATE)
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

DI_Read_Mouse	ENDP
;########################################################################
; END DI_Read_Mouse
;########################################################################

;########################################################################
; DI_Read_Keyboard	 Procedure
;########################################################################
DI_Read_Keyboard	 proc 

	;================================================================
	; This function will read the keyboard and set the input state
	;================================================================

	;============================
	; Read if it exists
	;============================
	.if lpdikey != NULL 
		;========================
		; Now read the state
		;========================
		DIDEVINVOKE GetDeviceState, lpdikey, 256, ADDR keyboard_state
		.if eax != DI_OK
			jmp	err
		.endif
	.else
		;==============================================
		; keyboard isn't plugged in, zero out state
		;==============================================
		DIINITSTRUCT ADDR keyboard_state, 256
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

DI_Read_Keyboard	ENDP
;########################################################################
; END DI_Read_Keyboard
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end 

