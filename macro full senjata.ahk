; =========================================================================
; POINT BLANK - MULTI MODE CONTROLLER
; AWP: KEKER(30) -> TEMBAK(35) -> Q(28) -> 3(28) -> 1(28)
; SG : TEMBAK(35) -> Q(30) -> 3(28) -> 1(28) -> 1(28)
; AutoHotkey v1
;
; F1  = STOP SEMENTARA
; F6  = MODE AWP (Fast Scope + QC)
; F7  = MODE SG  (QC)
; F8  = MODE RECOIL (AUTO TAP EXTRA FAST)
; ESC = KELUAR DARI SCq31RIPT
; =========================================================================

#NoEnv
#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode Input
SetKeyDelay, 15, 15
SetMouseDelay, 15
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%

global MacroAktif := false
global ModeTerakhir := "RECOIL"

; -------------------------------------------------------------------------
; F5 - STOP SEMENTARA
; -------------------------------------------------------------------------
F5::
MacroAktif := false
SoundBeep, 400, 150
ToolTip, STATUS: STOP`nTekan F8 untuk melanjutkan, 20, 20
SetTimer, HapusToolTip, -1500
return

; -------------------------------------------------------------------------
; F6 - PILIH MODE AWP
; -------------------------------------------------------------------------
F6::
ModeTerakhir := "AWP"
MacroAktif := true
Gosub, TampilkanStatus
return

; -------------------------------------------------------------------------
; F7 - PILIH MODE SG
; -------------------------------------------------------------------------
F7::
ModeTerakhir := "SG"
MacroAktif := true
Gosub, TampilkanStatus
return

; -------------------------------------------------------------------------
; F8 - PILIH MODE RECOIL
; -------------------------------------------------------------------------
F8::
ModeTerakhir := "RECOIL"
MacroAktif := true
Gosub, TampilkanStatus
return

; -------------------------------------------------------------------------
; STATUS MODE
; -------------------------------------------------------------------------
TampilkanStatus:
if (ModeTerakhir = "AWP")
{
    SoundBeep, 600, 120
    ToolTip, MODE AWP AKTIF (30-35-28-28-28), 20, 20
}
else if (ModeTerakhir = "SG")
{
    SoundBeep, 700, 120
    ToolTip, MODE SG AKTIF (35-30-28-28-28), 20, 20
}
else if (ModeTerakhir = "RECOIL")
{
    SoundBeep, 800, 120
    ToolTip, MODE RECOIL AKTIF (Tap Extra Fast), 20, 20
}
SetTimer, HapusToolTip, -1500
return

; -------------------------------------------------------------------------
; HAPUS NOTIFIKASI
; -------------------------------------------------------------------------
HapusToolTip:
ToolTip
return

; -------------------------------------------------------------------------
; HANDLER KLIK KIRI - SEMUA MODE
; -------------------------------------------------------------------------
$LButton::

; ============================ MODE AWP ==================================
if (MacroAktif && ModeTerakhir = "AWP")
{
    ; --- 1. TEMBAK (35ms) ---
    Click, Down
    Sleep, 35
    Click, Up
    Sleep, 35

    ; --- 2. KEKER / SCOPE (30ms) ---
    SendInput, {RButton Down}
    Sleep, 30
    SendInput, {RButton Up}
    Sleep, 30

    ; --- 3. QC: Q -> 3 -> 1 (masing-masing 28ms) ---
    SendInput, {q Down}
    Sleep, 28
    SendInput, {q Up}
    Sleep, 28

    SendInput, {3 Down}
    Sleep, 28
    SendInput, {3 Up}
    Sleep, 28

    SendInput, {1 Down}
    Sleep, 28
    SendInput, {1 Up}
    Sleep, 28
}
; ============================ MODE SG ===================================
else if (MacroAktif && ModeTerakhir = "SG")
{
    ; --- 1. TEMBAK (35ms) ---
    Click, Down
    Sleep, 35
    Click, Up
    Sleep, 35

    ; --- 2. QC: Q -> 3 -> 1 -> 1 ---
    ; Q (30ms)
    SendInput, {q Down}
    Sleep, 30
    SendInput, {q Up}
    Sleep, 30

    ; 3 (28ms)
    SendInput, {3 Down}
    Sleep, 28
    SendInput, {3 Up}
    Sleep, 28

    ; 1 (28ms)
    SendInput, {1 Down}
    Sleep, 28
    SendInput, {1 Up}
    Sleep, 28

    ; 1 (28ms)
    SendInput, {1 Down}
    Sleep, 28
    SendInput, {1 Up}
    Sleep, 28
}
; ============================ MODE RECOIL ===============================
else if (MacroAktif && ModeTerakhir = "RECOIL")
{
    while GetKeyState("LButton", "P")
    {
        SendInput, {LButton Down}
        Sleep, 30
        SendInput, {LButton Up}
        Sleep, 25
    }
}
; ============================ DEFAULT ===================================
else
{
    Click, Down
    Sleep, 15
    Click, Up
}
return

; -------------------------------------------------------------------------
; F1 - KELUAR
; -------------------------------------------------------------------------
F1::
ExitApp
return