; =========================================================================
; POINT BLANK - MULTI MODE CONTROLLER (FIXED)
; AWP: KEKER(30) -> TEMBAK(35) -> Q(28) -> 3(28) -> 1(28)
; SG : TEMBAK(35) -> Q(30) -> 3(28) -> 1(28) -> 1(28)
; RECOIL: Auto Tap (langsung stop pas lepas klik)
; AutoHotkey v1
;
; F5  = STOP SEMENTARA
; F6  = MODE AWP
; F7  = MODE SG
; F8  = MODE RECOIL
; F1  = KELUAR
; =========================================================================

#NoEnv
#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode Input
SetKeyDelay, 10, 10
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
; F6 - MODE AWP
; -------------------------------------------------------------------------
F6::
ModeTerakhir := "AWP"
MacroAktif := true
Gosub, TampilkanStatus
return

; -------------------------------------------------------------------------
; F7 - MODE SG
; -------------------------------------------------------------------------
F7::
ModeTerakhir := "SG"
MacroAktif := true
Gosub, TampilkanStatus
return

; -------------------------------------------------------------------------
; F8 - MODE RECOIL
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
    ToolTip, MODE AWP AKTIF (Keker-Tembak-Q-3-1), 20, 20
}
else if (ModeTerakhir = "SG")
{
    SoundBeep, 700, 120
    ToolTip, MODE SG AKTIF (Tembak-Q-3-1-1), 20, 20
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
; HANDLER KLIK KIRI
; -------------------------------------------------------------------------
$LButton::

; ============================ MODE AWP ==================================
if (MacroAktif && ModeTerakhir = "AWP")
{
    ; --- 1. KEKER / SCOPE (30ms) ---
    SendInput, {RButton Down}
    Sleep, 30
    SendInput, {RButton Up}
    Sleep, 30

    ; --- 2. TEMBAK (35ms) ---
    Click, Down
    Sleep, 26
    Click, Up
    Sleep, 26

    ; --- 3. QC: Q -> 3 -> 1 (masing-masing 28ms) ---
    SendInput, {q Down}
    Sleep, 24
    SendInput, {q Up}
    Sleep, 24

    SendInput, {3 Down}
    Sleep, 24
    SendInput, {3 Up}
    Sleep, 24

    SendInput, {1 Down}
    Sleep, 24
    SendInput, {1 Up}
    Sleep, 24
}
; ============================ MODE SG ===================================
else if (MacroAktif && ModeTerakhir = "SG")
{
    ; --- 1. TEMBAK (35ms) ---
    Click, Down
    Sleep, 30
    Click, Up
    Sleep, 30

    ; --- 2. QC: Q -> 3 -> 1 -> 1 ---
    ; Q (30ms)
    SendInput, {q Down}
    Sleep, 26
    SendInput, {q Up}
    Sleep, 26

    ; 3 (28ms)
    SendInput, {3 Down}
    Sleep, 24
    SendInput, {3 Up}
    Sleep, 24

    ; 1 (28ms)
    SendInput, {1 Down}
    Sleep, 24
    SendInput, {1 Up}
    Sleep, 24

    ; 1 (28ms)
    SendInput, {1 Down}
    Sleep, 24
    SendInput, {1 Up}
    Sleep, 24
}
; ============================ MODE RECOIL ===============================
else if (MacroAktif && ModeTerakhir = "RECOIL")
{
    ; Tembak pertama langsung
    Click, Down
    Sleep, 30
    Click, Up

    ; Loop selama LButton ditahan
    while GetKeyState("LButton", "P")
    {
        ; Cek sebelum sleep — biar langsung stop pas lepas
        if !GetKeyState("LButton", "P")
            break

        Sleep, 25

        if !GetKeyState("LButton", "P")
            break

        Click, Down
        Sleep, 30
        Click, Up
    }

    ; Pastiin release terakhir
    Click, Up
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