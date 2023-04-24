;###########################################################################
;###########################################################################
; ABOUT DS_Stuff:
;
;	This code module contains all of the functions that relate to 
; the Direct Sound component of DirectX. Just compile it and link.
;
;	It was ported to asm from the WGPFD library.
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
	include \masm32\include\winmm.inc
	
	;===============================================
	; The Lib's for those included files
	;================================================
	includelib \masm32\lib\comctl32.lib
	includelib \masm32\lib\comdlg32.lib
	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib
	includelib \masm32\lib\winmm.lib

	;====================================
	; The Direct Sound include file
	;====================================
	include Includes\DSound.inc

	;====================================
	; The Direct Sound library file
	;====================================
	includelib directxlib\lib\DSound.lib

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

	m2m MACRO M1, M2
		push		M2
		pop		M1
	ENDM

	return MACRO arg
		mov	eax, arg
		ret
	ENDM

	;====================================================
	; The following macro is based on
	; this Win32 header file macro
	;
	; #define MAKEFOURCC(ch0, ch1, ch2, ch3) \
	;  ((DWORD)(BYTE)(ch0) | ((DWORD)(BYTE)(ch1) << 8) |   \
	;  ((DWORD)(BYTE)(ch2) << 16) | ((DWORD)(BYTE)(ch3) << 24 ))
	;
	; This presumes all params passed in are in bytes
	;====================================================
	mmioFOURCC MACRO ch0, ch1, ch2, ch3
		mov	al, ch3
		shl	eax, 8
		mov	al, ch2
		shl	eax, 8
		mov	al, ch1
		shl	eax, 8
		mov	al, ch0
	ENDM

;#################################################################################
;#################################################################################
; Variables we want to use in other modules
;#################################################################################
;#################################################################################

	;=========================================
	; Main Direct Sound object
	;=========================================
	PUBLIC	lpds


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
; STRUCTURES
;#################################################################################
;#################################################################################

	;=============================
	; this holds a single sound
	;=============================
	pcm_sound	STRUCT 
		dsbuffer	dd 0	; the ds buffer for the sound 
		state		dd 0	; state of the sound
		rate		dd 0	; playback rate
		lsize		dd 0	; size of sound
	pcm_sound	ENDS


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

	;============================
	; max number of sounds in 
	; the game at once 
	;============================
MAX_SOUNDS	equ	16

	;===========================
	; State management equates
	;===========================
SOUND_NULL	equ	0
SOUND_LOADED	equ	1

;#################################################################################
;#################################################################################
; BEGIN INITIALIZED DATA
;#################################################################################
;#################################################################################

    .data

	;=========================================
	; Main Direct Sound object
	;=========================================
	lpds		LPDIRECTSOUND		0

	;=========================================
	; Main Direct Sound object
	;=========================================
	dsbd		DSBUFFERDESC		<?>

	;=========================================
	; Misc structs and vars for WAV loading
	;=========================================
	hwav		dd 0		; equiv of HMMIO
	parent		MMCKINFO	<>
	child		MMCKINFO	<>	
	wfmtx		WAVEFORMATEX	<>
	pcmwf		WAVEFORMATEX	<>
	snd_buffer	dd 0
	audio_ptr_1	dd 0
	audio_ptr_2	dd 0
	audio_length_1	dd 0
	audio_length_2	dd 0
	status		dd 0

	;=========================================
	; Our array of sound effects
	;=========================================
	sound_fx	pcm_sound	MAX_SOUNDS dup(<0,0,0,0>)
	
	;===========================================
	; A bunch of error strings
	;===========================================
	szNoDS		db "Unable to create Direct Sound Object.",0
	szNoID		db "Unable to obtain free sound ID.",0
	szNoOp		db "Unable to open .WAV file.",0
	szNoCoop	db "Unable to set cooperative level.",0

;#################################################################################
;#################################################################################
; BEGIN CONSTANTS
;#################################################################################
;#################################################################################

;#################################################################################
;#################################################################################
; BEGIN THE CODE SECTION
;#################################################################################
;#################################################################################

  .code

;########################################################################
; DS_Init Procedure
;########################################################################
DS_Init proc	

	;=======================================================
	; This function will setup Direct Sound
	;=======================================================

	;=================================
	; Local Variables
	;=================================
	LOCAL	index:		DWORD

	;==========================
	; Clear the sound fx out
	;==========================
	invoke RtlFillMemory, ADDR sound_fx, (sizeof(pcm_sound) * MAX_SOUNDS), 0

	;=============================
	; Create a direct sound object
	;=============================
	invoke DirectSoundCreate, 0, ADDR lpds, 0

	;=============================
	; Test for an error
	;=============================
	.if eax != DS_OK
		;======================
		; Give err msg
		;======================
		invoke MessageBox, hMainWnd, ADDR szNoDS, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;==============================
	; Set the priority level
	;==============================
	DSINVOKE SetCooperativeLevel, lpds, hMainWnd, DSSCL_NORMAL

	;=============================
	; Test for an error
	;=============================
	.if eax != DS_OK
		;======================
		; Give err msg
		;======================
		invoke MessageBox, hMainWnd, ADDR szNoCoop, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
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

DS_Init ENDP
;########################################################################
; END DS_Init
;########################################################################

;########################################################################
; DS_ShutDown Procedure
;########################################################################
DS_ShutDown proc

	;=======================================================
	; This function will close down DirectSound
	;=======================================================

	;===============================
	; Delete all the sounds
	;===============================
	invoke Delete_All_Sounds

	;===========================
	; Do we have an object?
	;===========================
	.if lpds != 0
		;======================
		; Yes. So Release it
		;======================
		DSINVOKE Release, lpds
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

DS_ShutDown	ENDP
;########################################################################
; END DS_ShutDown
;########################################################################

;########################################################################
; Play_Sound Procedure
;########################################################################
Play_Sound proc id:DWORD, flags:DWORD

	;=======================================================
	; This function will play the sound contained in the
	; id passed in along with the flags which can be either
	; NULL or DSBPLAY_LOOPING
	;=======================================================

	;==============================
	; Make sure this buffer exists
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	.if sound_fx[ecx].dsbuffer != NULL
		;=================================
		; We exists so reset the position
		; to the start of the sound
		;=================================
		push	ecx
		DSBINVOKE SetCurrentPosition, sound_fx[ecx].dsbuffer, 0
		pop	ecx

		;======================
		; Did the call fail?
		;======================
		.if eax != DS_OK
			;=======================
			; Nope, didn't make it
			;=======================
			jmp	err

		.endif

		;==============================
		; Now, we can play the sound
		;==============================
		DSBINVOKE Play, sound_fx[ecx].dsbuffer, 0, 0, flags

		;======================
		; Did the call fail?
		;======================
		.if eax != DS_OK
			;=======================
			; Nope, didn't make it
			;=======================
			jmp	err

		.endif

	.else
		;======================
		; No buffer for sound
		;======================
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

Play_Sound	ENDP
;########################################################################
; END Play_Sound
;########################################################################

;########################################################################
; Set_Sound_Volume Procedure
;########################################################################
Set_Sound_Volume proc	id:DWORD, vol:DWORD

	;=======================================================
	; This function will set the volume level of the sound
	; that was passed into here with the level specified
	; from 0-100
	;=======================================================

	;==============================
	; convert the volume from the
	; format passed in to the one
	; that DS wants (db)
	;==============================
	mov	eax, 100
	sub	eax, vol
	mov	ecx, -30
	mul	ecx

	;==============================
	; Set the volume
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	DSBINVOKE SetVolume, sound_fx[ecx].dsbuffer, eax

	;======================
	; Did the call fail?
	;======================
	.if eax != DS_OK
		;=======================
		; Nope, didn't make it
		;=======================
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

Set_Sound_Volume	ENDP
;########################################################################
; END Set_Sound_Volume
;########################################################################

;########################################################################
; Set_Sound_Freq Procedure
;########################################################################
Set_Sound_Freq proc	id:DWORD, freq:DWORD

	;=======================================================
	; This function will set the frequency of the sound
	; that was passed into here
	;=======================================================

	;==============================
	; Set the frequency
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	DSBINVOKE SetFrequency, sound_fx[ecx].dsbuffer, freq

	;======================
	; Did the call fail?
	;======================
	.if eax != DS_OK
		;=======================
		; Nope, didn't make it
		;=======================
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

Set_Sound_Freq	ENDP
;########################################################################
; END Set_Sound_Freq
;########################################################################

;########################################################################
; Set_Sound_Pan Procedure
;########################################################################
Set_Sound_Pan proc	id:DWORD, pan:DWORD

	;=======================================================
	; This function will set the pan of the sound
	; that was passed into here ( pan values accepted are
	; from -10,000 to 10,000 )
	;=======================================================

	;==============================
	; Set the pan
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	DSBINVOKE SetPan, sound_fx[ecx].dsbuffer, pan

	;======================
	; Did the call fail?
	;======================
	.if eax != DS_OK
		;=======================
		; Nope, didn't make it
		;=======================
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

Set_Sound_Pan	ENDP
;########################################################################
; END Set_Sound_Pan
;########################################################################

;########################################################################
; Stop_Sound Procedure
;########################################################################
Stop_Sound proc id:DWORD

	;=======================================================
	; This function will stop the passed in sound from
	; playing and will reset it's position
	;=======================================================

	;==============================
	; Make sure the sound exists
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	.if sound_fx[ecx].dsbuffer != NULL
		;==================================
		; We exist so stop the sound
		;==================================
		push	ecx
		DSBINVOKE Stop, sound_fx[ecx].dsbuffer
		pop	ecx

		;=================================
		; Now reset the sound position
		;=================================
		DSBINVOKE SetCurrentPosition, sound_fx[ecx].dsbuffer, 0

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

Stop_Sound	ENDP
;########################################################################
; END Stop_Sound
;########################################################################

;########################################################################
; Stop_All_Sounds Procedure
;########################################################################
Stop_All_Sounds proc

	;=======================================================
	; This function will stop all sounds from playing
	;=======================================================

	;==============================
	; Local Variables
	;==============================
	LOCAL	index	:DWORD

	;==============================
	; Loop through all sounds
	;==============================
	mov	index, 0
	.while index < MAX_SOUNDS
		;==================================
		; Stop this sound from playing
		;==================================
		invoke Stop_Sound, index

		;================
		; Inc the counter
		;================
		inc	index

	.endw

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

Stop_All_Sounds ENDP
;########################################################################
; END Stop_All_Sounds
;########################################################################

;########################################################################
; Delete_Sound Procedure
;########################################################################
Delete_Sound proc	id:DWORD

	;=======================================================
	; This function will delete the passed in sound
	;=======================================================

	;======================================
	; Stop the sound in case it is playing
	;======================================
	invoke Stop_Sound, id
	invoke Sleep, 10

	;==============================
	; Make sure the sound exists
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	.if sound_fx[ecx].dsbuffer != NULL
		;==================================
		; We exist so release the sound
		;==================================
		push	ecx
		DSBINVOKE Release, sound_fx[ecx].dsbuffer
		pop	ecx

		;======================
		; Set object to Null
		;======================
		mov	sound_fx[ecx].dsbuffer, NULL
		mov	sound_fx[ecx].state, SOUND_NULL

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

Delete_Sound	ENDP
;########################################################################
; END Delete_Sound
;########################################################################

;########################################################################
; Delete_All_Sounds Procedure
;########################################################################
Delete_All_Sounds proc

	;=======================================================
	; This function will delete all sounds we currently have
	;=======================================================

	;==============================
	; Local Variables
	;==============================
	LOCAL	index	:DWORD

	;==============================
	; Loop through all sounds
	;==============================
	mov	index, 0
	.while index < MAX_SOUNDS
		;==================================
		; Delete this sound
		;==================================
		invoke Delete_Sound, index

		;================
		; Inc the counter
		;================
		inc	index

	.endw

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

Delete_All_Sounds	ENDP
;########################################################################
; END Delete_All_Sounds
;########################################################################

;########################################################################
; Status_Sound Procedure
;########################################################################
Status_Sound proc	id:DWORD

	;=======================================================
	; This function will return the status of the sound that
	; was passed in , -1 is returned on an error
	;=======================================================

	;==============================
	; Make sure the sound exists
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, id
	mul	ecx
	mov	ecx, eax
	.if sound_fx[ecx].dsbuffer != NULL
		;==================================
		; We exist so get the status
		;==================================
		DSBINVOKE GetStatus, sound_fx[ecx].dsbuffer, ADDR status

		;===================
		; We completed
		;===================
		return status

	.endif

	;===================
	; We didn't make it
	;===================
	return -1

Status_Sound	ENDP
;########################################################################
; END Status_Sound
;########################################################################

;########################################################################
; Load_WAV Procedure
;########################################################################
Load_WAV	proc	fname_ptr:DWORD, flags:DWORD

	;=======================================================
	; This function will load the passed in WAV file
	; it returns the id of the sound, or -1 if failed
	;=======================================================

	;==============================
	; Local Variables
	;==============================
	LOCAL	sound_id	:DWORD
	LOCAL	index		:DWORD

	;=================================
	; Init the sound_id to -1
	;=================================
	mov	sound_id, -1

	;=================================
	; First we need to make sure there
	; is an open id for our new sound
	;=================================
	mov	index, 0
	.while index < MAX_SOUNDS
		;========================
		; Is this sound empty??
		;========================
		mov	eax, sizeof(pcm_sound)
		mov	ecx, index
		mul	ecx
		mov	ecx, eax
		.if sound_fx[ecx].state == SOUND_NULL
			;===========================
			; We have found one, so set 
			; the id and leave our loop
			;===========================
			mov	eax, index
			mov	sound_id, eax
			.break

		.endif

		;================
		; Inc the counter
		;================
		inc	index

	.endw

	;======================================
	; Make sure we have a valid id now
	;======================================
	.if sound_id == -1
		;======================
		; Give err msg
		;======================
		invoke MessageBox, hMainWnd, ADDR szNoID, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err

	.endif

	;=========================
	; Setup the parent "chunk"
	; info structure
	;=========================
	mov	parent.ckid, 0
	mov	parent.ckSize, 0
	mov	parent.fccType, 0
	mov	parent.dwDataOffset, 0
	mov	parent.dwFlags, 0

	;============================
	; Do the same with the child
	;============================
	mov	child.ckid, 0
	mov	child.ckSize, 0
	mov	child.fccType, 0
	mov	child.dwDataOffset, 0
	mov	child.dwFlags, 0

	;======================================
	; Now open the WAV file using the MMIO
	; API function
	;======================================
	invoke mmioOpen, fname_ptr, NULL, (MMIO_READ or MMIO_ALLOCBUF)
	mov	hwav, eax

	;====================================
	; Make sure the call was successful
	;====================================
	.if eax == NULL
		;======================
		; Give err msg
		;======================
		invoke MessageBox, hMainWnd, ADDR szNoOp, NULL, MB_OK

		;======================
		; Jump and return out
		;======================
		jmp	err
		
	.endif

	;===============================
	; Set the type in the parent
	;===============================
	mmioFOURCC 'W', 'A', 'V', 'E' 
	mov	parent.fccType, eax

	;=================================
	; Descend into the RIFF
	;=================================
	invoke mmioDescend, hwav, ADDR parent, NULL, MMIO_FINDRIFF
	.if eax != NULL
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;============================
	; Set the child id to format
	;============================
	mmioFOURCC 'f', 'm', 't', ' ' 
	mov	child.ckid, eax

	;=================================
	; Descend into the WAVE format
	;=================================
	invoke mmioDescend, hwav, ADDR child, ADDR parent, NULL
	.if eax != NULL
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;=================================
	; Now read the wave format info in
	;=================================
	invoke mmioRead, hwav, ADDR wfmtx, sizeof(WAVEFORMATEX)
	mov	ebx, sizeof(WAVEFORMATEX)
	.if eax != ebx
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;=================================
	; Make sure the data format is PCM
	;=================================
	.if wfmtx.wFormatTag != WAVE_FORMAT_PCM
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;=================================
	; Ascend up one level
	;=================================
	invoke mmioAscend, hwav, ADDR child, NULL
	.if eax != NULL
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;============================
	; Set the child id to data
	;============================
	mmioFOURCC 'd', 'a', 't', 'a' 
	mov	child.ckid, eax

	;=================================
	; Descend into the data chunk
	;=================================
	invoke mmioDescend, hwav, ADDR child, ADDR parent, MMIO_FINDCHUNK
	.if eax != NULL
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif


	;===================================
	; Now allocate memory for the sound
	;===================================
	invoke GlobalAlloc, GMEM_FIXED, child.ckSize
	mov	snd_buffer, eax
	.if eax == NULL
		;===================
		; Close the file
		;===================
		invoke mmioClose, hwav, NULL

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;=======================================
	; Read the WAV data and close the file
	;=======================================
	invoke mmioRead, hwav, snd_buffer, child.ckSize
	invoke mmioClose, hwav, 0

	;================================
	; Set the rate, size, & state
	;================================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, sound_id
	mul	ecx
	mov	ecx, eax
	mov	eax, wfmtx.nSamplesPerSec
	mov	sound_fx[ecx].rate, eax
	mov	eax, child.ckSize
	mov	sound_fx[ecx].lsize, eax
	mov	sound_fx[ecx].state, SOUND_LOADED

	;==========================
	; Clear the format struc
	;==========================
	invoke RtlFillMemory, ADDR pcmwf, sizeof(WAVEFORMATEX), 0

	;=============================
	; Now fill our desired fields
	;=============================
	mov	pcmwf.wFormatTag, WAVE_FORMAT_PCM
	mov	ax, wfmtx.nChannels
	mov	pcmwf.nChannels, ax
	mov	eax, wfmtx.nSamplesPerSec
	mov	pcmwf.nSamplesPerSec, eax
	xor	eax, eax
	mov	ax, wfmtx.nBlockAlign
	mov	pcmwf.nBlockAlign, ax
	mov	eax, pcmwf.nSamplesPerSec
	xor	ecx, ecx
	mov	cx, pcmwf.nBlockAlign
	mul	ecx
	mov	pcmwf.nAvgBytesPerSec, eax
	mov	ax, wfmtx.wBitsPerSample
	mov	pcmwf.wBitsPerSample, ax
	mov	pcmwf.cbSize, 0

	;=================================
	; Prepare to create the DS buffer
	;=================================
	DSINITSTRUCT ADDR dsbd, sizeof(DSBUFFERDESC)
	mov	dsbd.dwSize, sizeof(DSBUFFERDESC)
		; Put other flags you want to play with in here such
		; as CTRL_PAN, CTRL_FREQ, etc or pass them in
	mov	eax, flags
	mov	dsbd.dwFlags, eax
	or	dsbd.dwFlags, DSBCAPS_STATIC or DSBCAPS_CTRLVOLUME \
			or DSBCAPS_LOCSOFTWARE
	mov	ebx, child.ckSize
	mov	eax, offset pcmwf
	mov	dsbd.dwBufferBytes, ebx
	mov	dsbd.lpwfxFormat, eax

	;=================================
	; Create the sound buffer
	;=================================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, sound_id
	mul	ecx
	lea	ecx, sound_fx[eax].dsbuffer
	DSINVOKE CreateSoundBuffer, lpds, ADDR dsbd, ecx, NULL
	.if eax != DS_OK
		;===================
		; Free the buffer
		;===================
		invoke GlobalFree, snd_buffer

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;==================================
	; Lock the buffer so we can copy
	; our sound data into it
	;==================================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, sound_id
	mul	ecx
	mov	ecx, eax
	DSBINVOKE mLock, sound_fx[ecx].dsbuffer, NULL, child.ckSize, ADDR audio_ptr_1,\ 
		ADDR audio_length_1, ADDR audio_ptr_2, ADDR audio_length_2,\
		DSBLOCK_FROMWRITECURSOR
	.if eax != DS_OK
		;===================
		; Free the buffer
		;===================
		invoke GlobalFree, snd_buffer

		;=====================
		; Jump and return out
		;=====================
		jmp	err
		
	.endif

	;==============================
	; Copy first section of buffer
	; then the second section
	;==============================
		; First buffer
	mov	esi, snd_buffer
	mov	edi, audio_ptr_1
	mov	ecx, audio_length_1
	and	ecx, 3
	rep	movsb
	mov	ecx, audio_length_1
	shr	ecx, 2
	rep	movsd

		; Second buffer
	mov	esi, snd_buffer
	add	esi, audio_length_1
	mov	edi, audio_ptr_2
	mov	ecx, audio_length_2
	and	ecx, 3
	rep	movsd
	mov	ecx, audio_length_2
	shr	ecx, 2
	rep	movsd

	;==============================
	; Unlock the buffer
	;==============================
	mov	eax, sizeof(pcm_sound)
	mov	ecx, sound_id
	mul	ecx
	mov	ecx, eax
	DSBINVOKE Unlock, sound_fx[ecx].dsbuffer, audio_ptr_1, audio_length_1,\
		audio_ptr_2, audio_length_2
	.if eax != DS_OK
		;===================
		; Free the buffer
		;===================
		invoke GlobalFree, snd_buffer

		;=====================
		; Jump and return out
		;=====================
		jmp	err

	.endif

	;===================
	; Free the buffer
	;===================
	invoke GlobalFree, snd_buffer

done:
	;===================
	; We completed
	;===================
	return sound_id

err:
	;===================
	; We didn't make it
	;===================
	return -1

Load_WAV	ENDP
;########################################################################
; END Load_WAV
;########################################################################

;######################################
; THIS IS THE END OF THE PROGRAM CODE #
;######################################
end 

