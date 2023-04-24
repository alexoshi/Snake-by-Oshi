;===================================================================
;===================================================================
; DSOUND include file
;
;	Author: Chris Hobbs
;		Lightning Software
;		Http://www.fastsoftware.com
;
;===================================================================
;===================================================================

;======================================
; The DI version we support
;======================================
DIRECTINPUT_VERSION	equ	0500h

;======================================
; The GUID Definition
;======================================
GUID	STRUC
    Data1	dd 0
    Data2	dw 0
    Data3	dw 0
    Data4	db 8 dup(0)
GUID	ENDS

;======================================
; The MAKE_HRESULT MACRO
;======================================
MAKE_HRESULT MACRO hres_name,severity,facility,code

	hres_name = (severity SHL 31) OR ((facility AND 0FFFh) SHL 16) OR (code AND 0FFFFh)
ENDM

;======================================
; The MAKE_HRESULT MACRO
;======================================
_FACDS EQU 878h
MAKE_DSHRESULT MACRO hres_name,code
 MAKE_HRESULT hres_name,1,_FACDS,code
ENDM

;=========================================
; The std method calling convention
;=========================================
STDMETHOD	MACRO	name, argl :VARARG
	LOCAL @tmp_a
	LOCAL @tmp_b

	@tmp_a	TYPEDEF PROTO argl
	@tmp_b	TYPEDEF PTR @tmp_a
	name		@tmp_b		?
ENDM

;=========================================
; This will set the struct to zero
;=========================================
DSINITSTRUCT	MACRO	arg1, arg2
	invoke RtlFillMemory, arg1, arg2, 0
ENDM

;=========================================
; A Macro for invoking DSound stuff
;=========================================
DSINVOKE	MACRO	func, this, arglist :VARARG
	mov	eax , [this]
	mov	eax , [eax]

	IFB <arglist>
		INVOKE [IDirectSoundVtbl.func][eax], this
	ELSE
		INVOKE [IDirectSoundVtbl.func][eax], this, arglist
	ENDIF
ENDM

;=========================================
; A Macro for invoking DSoundBuffer stuff
;=========================================
DSBINVOKE	MACRO	func, this, arglist :VARARG
	mov	eax , [this]
	mov	eax , [eax]

	IFB <arglist>
		INVOKE [IDirectSoundBufferVtbl.func][eax], this
	ELSE
		INVOKE [IDirectSoundBufferVtbl.func][eax], this, arglist
	ENDIF
ENDM

;=========================================
; The main prototypes
;=========================================
DirectSoundCreate PROTO :DWORD,:DWORD,:DWORD
DirectSoundCaptureCreate PROTO :DWORD,:DWORD,:DWORD
DirectSoundCaptureEnumerateA PROTO :DWORD,:DWORD
DirectSoundCaptureEnumerate equ <DirectSoundCaptureEnumerateA>
DirectSoundEnumerateA PROTO :DWORD,:DWORD
DirectSoundEnumerate equ <DirectSoundEnumerateA>

;========================================
; The GUIDS that need to be defined
;========================================
EXTERNDEF	C CLSID_DirectSound:GUID
EXTERNDEF	C CLSID_DirectSoundCapture:GUID

;/****************************************************************************
; *
; *      Interfaces
; *
; ****************************************************************************/

EXTERNDEF	C IID_IDirectSound:GUID
EXTERNDEF	C IID_IDirectSoundBuffer:GUID
EXTERNDEF	C IID_IDirectSound3DListener:GUID
EXTERNDEF	C IID_IDirectSound3DBuffer:GUID
EXTERNDEF	C IID_IDirectSoundCapture:GUID
EXTERNDEF	C IID_IDirectSoundCaptureBuffer:GUID
EXTERNDEF	C IID_IDirectSoundNotify:GUID
EXTERNDEF	C IID_IKsPropertySet:GUID


;==============================
; The structures
;==============================
_DSCAPS STRUCT 4
dwSize					DWORD		?
dwFlags					DWORD		?
dwMinSecondarySampleRate		DWORD		?
dwMaxSecondarySampleRate		DWORD		?
dwPrimaryBuffers			DWORD		?
dwMaxHwMixingAllBuffers			DWORD		?
dwMaxHwMixingStaticBuffers		DWORD		?
dwMaxHwMixingStreamingBuffers		DWORD		?
dwFreeHwMixingAllBuffers		DWORD		?
dwFreeHwMixingStaticBuffers		DWORD		?
dwFreeHwMixingStreamingBuffers		DWORD		?
dwMaxHw3DAllBuffers			DWORD		?
dwMaxHw3DStaticBuffers			DWORD		?
dwMaxHw3DStreamingBuffers		DWORD		?
dwFreeHw3DAllBuffers			DWORD		?
dwFreeHw3DStaticBuffers			DWORD		?
dwFreeHw3DStreamingBuffers		DWORD		?
dwTotalHwMemBytes			DWORD		?
dwFreeHwMemBytes			DWORD		?
dwMaxContigFreeHwMemBytes		DWORD		?
dwUnlockTransferRateHwBuffers		DWORD		?
dwPlayCpuOverheadSwBuffers		DWORD		?
dwReserved1				DWORD		?
dwReserved2				DWORD		?
_DSCAPS ENDS

DSCAPS		TYPEDEF		_DSCAPS
LPDSCAPS	TYPEDEF		PTR _DSCAPS
LPCDSCAPS	TYPEDEF		PTR _DSCAPS




_DSBCAPS STRUCT 4
dwSize			DWORD		?
dwFlags			DWORD		?
dwBufferBytes		DWORD		?
dwUnlockTransferRate	DWORD		?
dwPlayCpuOverhead	DWORD		?
_DSBCAPS ENDS

DSBCAPS		TYPEDEF		_DSBCAPS
LPDSBCAPS		TYPEDEF		PTR _DSBCAPS
LPCDSBCAPS		TYPEDEF		PTR _DSBCAPS


_DSBUFFERDESC STRUCT 4
dwSize			DWORD		?
dwFlags			DWORD		?
dwBufferBytes		DWORD		?
dwReserved		DWORD		?
lpwfxFormat		DWORD		?
_DSBUFFERDESC		ENDS

DSBUFFERDESC		TYPEDEF		_DSBUFFERDESC
LPDSBUFFERDESC		TYPEDEF		PTR _DSBUFFERDESC
LPCDSBUFFERDESC		TYPEDEF		PTR _DSBUFFERDESC

_DSCCAPS STRUCT 4
dwSize		DWORD		?
dwFlags		DWORD		?
dwFormats	DWORD		?
dwChannels	DWORD		?
_DSCCAPS ENDS

DSCCAPS		TYPEDEF		_DSCCAPS
LPDSCCAPS	TYPEDEF		PTR _DSCCAPS
LPCDSCCAPS	TYPEDEF		PTR _DSCCAPS


_DSCBUFFERDESC STRUCT 4
dwSize		DWORD		?
dwFlags		DWORD		?
dwBufferBytes	DWORD		?
dwReserved	DWORD		?
lpwfxFormat	DWORD		?
_DSCBUFFERDESC ENDS

DSCBUFFERDESC		TYPEDEF		_DSCBUFFERDESC
LPDSCBUFFERDESC		TYPEDEF		PTR _DSCBUFFERDESC
LPCDSCBUFFERDESC	TYPEDEF		PTR _DSCBUFFERDESC

_DSCBCAPS STRUCT 4
dwSize		DWORD		?
dwFlags		DWORD		?
dwBufferBytes	DWORD		?
dwReserved	DWORD		?
_DSCBCAPS ENDS

DSCBCAPS	TYPEDEF		_DSCBCAPS
LPDSCBCAPS	TYPEDEF		PTR _DSCBCAPS
LPCDSCBCAPS	TYPEDEF		PTR _DSCBCAPS


_DSBPOSITIONNOTIFY STRUCT 4
dwOffset	DWORD		?
hEventNotify	DWORD		?
_DSBPOSITIONNOTIFY ENDS

DSBPOSITIONNOTIFY	TYPEDEF		_DSBPOSITIONNOTIFY
LPDSBPOSITIONNOTIFY	TYPEDEF		PTR _DSBPOSITIONNOTIFY
LPCDSBPOSITIONNOTIFY	TYPEDEF		PTR _DSBPOSITIONNOTIFY






;===================================================================
; The Virtual Table -- This is used for all the DirectX functions
;===================================================================
	;=======================================
	; The main DirectSound interface
	;=======================================
IDirectSoundVtbl	STRUC
	; IUnknown methods
	STDMETHOD QueryInterface, :PTR IDirectSound, :PTR, :PTR PTR
	STDMETHOD AddRef, :PTR IDirectSound
	STDMETHOD Release, :PTR IDirectSound
	; IDirectSound methods
	STDMETHOD CreateSoundBuffer,:PTR IDirectSound,:DWORD,:DWORD,:DWORD
	STDMETHOD GetCaps,:PTR IDirectSound, :DWORD
	STDMETHOD DuplicateSoundBuffer,:PTR IDirectSound,:DWORD,:DWORD
	STDMETHOD SetCooperativeLevel,:PTR IDirectSound,:DWORD,:DWORD
	STDMETHOD Compact,:PTR IDirectSound
	STDMETHOD GetSpeakerConfig,:PTR IDirectSound,:DWORD
	STDMETHOD SetSpeakerConfig,:PTR IDirectSound,:DWORD
	STDMETHOD Initialize,:PTR IDirectSound,:DWORD
IDirectSoundVtbl	ENDS

	;=======================================
	; The DirectSoundBuffer interface
	;=======================================
IDirectSoundBufferVtbl	STRUC
	; IUnknown methods
	STDMETHOD QueryInterface, :PTR IDirectSoundBuffer, :PTR, :PTR PTR
	STDMETHOD AddRef, :PTR IDirectSoundBuffer
	STDMETHOD Release, :PTR IDirectSoundBuffer
	; IDirectSoundBuffer methods
	STDMETHOD GetCaps, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD GetCurrentPosition, :PTR IDirectSoundBuffer,:DWORD,:DWORD
	STDMETHOD GetFormat, :PTR IDirectSoundBuffer,:DWORD,:DWORD,:DWORD
	STDMETHOD GetVolume, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD GetPan, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD GetFrequency, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD GetStatus, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD Initialize, :PTR IDirectSoundBuffer,:DWORD,:DWORD
	STDMETHOD mLock, :PTR IDirectSoundBuffer,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
	STDMETHOD Play, :PTR IDirectSoundBuffer,:DWORD,:DWORD,:DWORD
	STDMETHOD SetCurrentPosition, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD SetFormat, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD SetVolume, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD SetPan, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD SetFrequency, :PTR IDirectSoundBuffer,:DWORD
	STDMETHOD Stop, :PTR IDirectSoundBuffer
	STDMETHOD Unlock, :PTR IDirectSoundBuffer,:DWORD,:DWORD,:DWORD,:DWORD
	STDMETHOD Restore, :PTR IDirectSoundBuffer
IDirectSoundBufferVtbl	ENDS

;=======================================
; The DirectSound Vtbl addresses
;=======================================
IDirectSound		STRUC
	lpVtbl		DWORD		?
IDirectSound		ENDS

IDirectSoundBuffer	STRUC
	lpVtbl		DWORD		?
IDirectSoundBuffer	ENDS

;***** Return Codes *****
DS_OK EQU 0


; The call failed because resources (such as a priority level)
; were already being used by another caller.
MAKE_DSHRESULT DSERR_ALLOCATED,10

; The control (vol,pan,etc.) requested by the caller is not available.
MAKE_DSHRESULT DSERR_CONTROLUNAVAIL,30

; An invalid parameter was passed to the returning function
DSERR_INVALIDPARAM EQU E_INVALIDARG

; This call is not valid for the current state of this object
MAKE_DSHRESULT DSERR_INVALIDCALL,40

; An undetermined error occured inside the DirectSound subsystem
DSERR_GENERIC EQU E_FAIL

; The caller does not have the priority level required for the function to
; succeed.
MAKE_DSHRESULT DSERR_PRIOLEVELNEEDED,70

; Not enough free memory is available to complete the operation
DSERR_OUTOFMEMORY EQU E_OUTOFMEMORY

; The specified WAVE format is not supported
MAKE_DSHRESULT DSERR_BADFORMAT,100

; The function called is not supported at this time
DSERR_UNSUPPORTED EQU E_NOTIMPL

; No sound driver is available for use
MAKE_DSHRESULT DSERR_NODRIVER,120

; This object is already initialized
MAKE_DSHRESULT DSERR_ALREADYINITIALIZED,130

; This object does not support aggregation
DSERR_NOAGGREGATION EQU CLASS_E_NOAGGREGATION

; The buffer memory has been lost, and must be restored.
MAKE_DSHRESULT DSERR_BUFFERLOST,150

; Another app has a higher priority level, preventing this call from
; succeeding.
MAKE_DSHRESULT DSERR_OTHERAPPHASPRIO,160

; This object has not been initialized
MAKE_DSHRESULT DSERR_UNINITIALIZED,170

; The requested COM interface is not available
DSERR_NOINTERFACE EQU E_NOINTERFACE



; Flags

DSCAPS_PRIMARYMONO		EQU		000000001h
DSCAPS_PRIMARYSTEREO		EQU		000000002h
DSCAPS_PRIMARY8BIT		EQU		000000004h
DSCAPS_PRIMARY16BIT		EQU		000000008h
DSCAPS_CONTINUOUSRATE		EQU		000000010h
DSCAPS_EMULDRIVER		EQU		000000020h
DSCAPS_CERTIFIED		EQU		000000040h
DSCAPS_SECONDARYMONO		EQU		000000100h
DSCAPS_SECONDARYSTEREO		EQU		000000200h
DSCAPS_SECONDARY8BIT		EQU		000000400h
DSCAPS_SECONDARY16BIT		EQU		000000800h
DSBPLAY_LOOPING			EQU		000000001h
DSBSTATUS_PLAYING		EQU		000000001h
DSBSTATUS_BUFFERLOST		EQU		000000002h
DSBSTATUS_LOOPING		EQU		000000004h
DSBLOCK_FROMWRITECURSOR		EQU		000000001h
DSBLOCK_ENTIREBUFFER		EQU		000000002h
DSSCL_NORMAL			EQU		000000001h
DSSCL_PRIORITY			EQU		000000002h
DSSCL_EXCLUSIVE			EQU		000000003h
DSSCL_WRITEPRIMARY		EQU		000000004h
DS3DMODE_NORMAL			EQU		000000000h
DS3DMODE_HEADRELATIVE		EQU		000000001h
DS3DMODE_DISABLE		EQU		000000002h

DS3D_IMMEDIATE			EQU		000000000h
DS3D_DEFERRED			EQU		000000001h

DS3D_MINCONEANGLE		EQU		0t
DS3D_MAXCONEANGLE		EQU		360t
DS3D_DEFAULTCONEANGLE		EQU		360t
DS3D_DEFAULTCONEOUTSIDEVOLUME	EQU		0t
DSBCAPS_PRIMARYBUFFER		EQU		000000001h
DSBCAPS_STATIC			EQU		000000002h
DSBCAPS_LOCHARDWARE		EQU		000000004h
DSBCAPS_LOCSOFTWARE		EQU		000000008h
DSBCAPS_CTRL3D			EQU		000000010h
DSBCAPS_CTRLFREQUENCY		EQU		000000020h
DSBCAPS_CTRLPAN			EQU		000000040h
DSBCAPS_CTRLVOLUME		EQU		000000080h
DSBCAPS_CTRLPOSITIONNOTIFY	EQU		000000100h
DSBCAPS_CTRLDEFAULT		EQU		0000000e0h
DSBCAPS_CTRLALL			EQU		0000001f0h
DSBCAPS_STICKYFOCUS		EQU		000004000h
DSBCAPS_GLOBALFOCUS		EQU		000008000h
DSBCAPS_GETCURRENTPOSITION2	EQU		000010000h
DSBCAPS_MUTE3DATMAXDISTANCE	EQU		000020000h
DSCBCAPS_WAVEMAPPED		EQU		080000000h
DSSPEAKER_HEADPHONE		EQU		000000001h
DSSPEAKER_MONO			EQU		000000002h
DSSPEAKER_QUAD			EQU		000000003h
DSSPEAKER_STEREO		EQU		000000004h
DSSPEAKER_SURROUND		EQU		000000005h
DSSPEAKER_GEOMETRY_MIN		EQU		000000005h
DSSPEAKER_GEOMETRY_NARROW	EQU		00000000ah
DSSPEAKER_GEOMETRY_WIDE		EQU		000000014h
DSSPEAKER_GEOMETRY_MAX		EQU		0000000b4h
DSCCAPS_EMULDRIVER		EQU		000000020h
DSCBLOCK_ENTIREBUFFER		EQU		000000001h
DSCBSTATUS_CAPTURING		EQU		000000001h
DSCBSTATUS_LOOPING		EQU		000000002h
DSCBSTART_LOOPING		EQU		000000001h
DSBFREQUENCY_MIN		EQU		100t
DSBFREQUENCY_MAX		EQU		100000t
DSBFREQUENCY_ORIGINAL		EQU		0t
DSBPAN_LEFT			EQU		-10000t
DSBPAN_CENTER			EQU		0t
DSBPAN_RIGHT			EQU		10000t
DSBVOLUME_MIN			EQU		-10000t
DSBVOLUME_MAX			EQU		0t
DSBSIZE_MIN			EQU		4t
DSBSIZE_MAX			EQU		00fffffffh
DSBPN_OFFSETSTOP		EQU		0ffffffffh


LPDIRECTSOUND typedef PTR
LPDIRECTSOUNDBUFFER typedef PTR
LPDIRECTSOUND3DLISTENER typedef PTR
LPDIRECTSOUND3DBUFFER typedef PTR
LPDIRECTSOUNDCAPTURE typedef PTR
LPDIRECTSOUNDCAPTUREBUFFER typedef PTR
LPDIRECTSOUNDNOTIFY typedef PTR
