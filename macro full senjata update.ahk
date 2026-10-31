; =========================================================================
; POINT BLANK - MACRO FULL SENJATA (UPDATE)
; AutoHotkey v1.1  (WAJIB v1, JANGAN v2)
;
; HOTKEY:
;   F1  = Keluar
;   F2  = Lihat status / setting aktif
;   F3  = Quick Change lebih CEPAT
;   F4  = Quick Change lebih LAMBAT / lebih AMAN
;   F5  = STOP / MATIKAN SEMUA MACRO
;   F6  = SNIPER KEKER  : Scope -> Tembak -> Quick Change
;   F7  = SG PUTER      : Tembak -> Quick Change
;   F8  = SPAS          : Tembak -> Quick Change
;   F9  = SHOTGUN ZOMBIE: Tembak -> Quick Change cepat
;   F10 = SENJATA BIASA : AUTO TAP RECOIL ORI (tap cepat selama klik ditahan)
;   F11 = Tap LEBIH CEPAT (jeda antar tap dikurangi)
;   F12 = Tap LEBIH LAMBAT / AMAN (jeda antar tap ditambah)
;   Shift+F11 = Hold klik lebih PENDEK
;   Shift+F12 = Hold klik lebih LAMA
;   Ctrl+F10  = Reset tap recoil ke setting ORI (30 / 24 ms)

;
; CARA PAKAI:
;   - Pilih mode dengan F6..F10
;   - Klik kiri = 1x aksi. Tahan klik kiri = ulang otomatis.
;   - Kalau tembakan "boncos" / peluru hilang / senjata tidak nembak:
;       tekan F4 beberapa kali (QC jadi lebih lambat), lalu tes lagi.
;   - Kalau sudah tidak boncos dan mau lebih cepat:
;       tekan F3 beberapa kali.
;   - Mode F10 (AUTO TAP RECOIL ORI):
;       Tahan klik kiri = tap cepat berulang (klik turun 30ms, jeda 24ms,
;       klik naik) sampai klik dilepas, sama seperti macro recoil ori.
;       Langsung berhenti begitu klik kiri dilepas.
;       Kalau tap terlalu cepat / peluru boncos -> F12.
;       Kalau mau lebih cepat                    -> F11.
;       Ctrl+F10 untuk balik ke setting ori (30 / 24 ms).
; =========================================================================

#Requires AutoHotkey v1.1
#NoEnv
#SingleInstance Force
#MaxThreadsPerHotkey 1
#MaxHotkeysPerInterval 999
SendMode Input
SetKeyDelay, 0, 0
SetMouseDelay, -1
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
DllCall("Winmm\timeBeginPeriod", "UInt", 1)

; =========================================================================
; ANALISA ANTI-BONCOS (PENTING)
;
; 1) Peluru PB itu hitscan, tapi tetap butuh waktu sampai server mencatat
;    tembakan. Kalau senjata langsung dipindah sebelum peluru "keregister",
;    tembakan dianggap batal = BONCOS.
;    -> Karena itu ada JEDA REGISTRASI (Reg) setelah klik, baru pindah.
;
; 2) Setelah balik ke senjata utama (1), masih ada animasi tarik/ready.
;    Kalau langsung klik lagi sebelum animasi selesai, klik tidak
;    menghasilkan peluru = BONCOS.
;    -> Karena itu ada JEDA READY sebelum siklus berikutnya.
;
; 3) Tiap senjata beda karakter:
;    - AWP / sniper keker : butuh Reg lebih lama (bolt-action).
;    - SG puter           : butuh nunggu animasi spin mulai, lalu QC.
;    - SPAS               : butuh nunggu pump, QC meng-cancel pump.
;    - Shotgun zombie     : lebih toleran, bisa QC lebih cepat.
;
; 4) Kecepatan pindah senjata dipengaruhi item Quick Change / beret.
;    Default di bawah sudah aman. Kalau punya QC 50% / beret, tekan F3.
;    Kalau belum punya item QC, tekan F4 supaya tidak boncos.
; =========================================================================

; ------------------------ KONFIGURASI GLOBAL ----------------------------
global MacroAktif := false
global Mode       := "NONE"

; No Recoil (senjata biasa) - AUTO TAP RECOIL ORI
; Sama persis dengan macro recoil ori:
;   - Klik pertama langsung ditembak (tahan 30ms lalu lepas).
;   - Selama klik kiri DITAHAN, script tap berulang: jeda 24ms,
;     klik turun 30ms, klik naik.
;   - Begitu klik kiri dilepas, tap langsung berhenti (tidak ada sisa).
;
; Timing default = setting ORI (Hold 30ms, Jeda 24ms).
; F11/F12  = ubah jeda antar tap (cepat / lambat).
; Shift+F11/F12 = ubah lama tahan klik.
; Ctrl+F10 = balik ke setting ORI.
global NR_Down    := 30     ; ms klik ditahan tiap tap (ori: 30)
global NR_Gap     := 24     ; ms jeda antar tap (ori: 24)

; Quick Change
global QC_Step    := 26     ; ms tahan + jeda per tombol (Q / 3 / 1)
global QC_Offset  := 0      ; offset jeda Reg/Ready, tuning F3/F4 (ms)

; ------------------------ AWP / SNIPER KEKER ----------------------------
global AWP_Scope  := true   ; pakai keker (RButton) sebelum nembak
global AWP_ScopeT := 28     ; ms tahan RButton
global AWP_ScopeD := 55     ; ms tunggu scope stabil (tambah kalau peluru melenceng)
global AWP_Hold   := 26     ; ms tahan klik tembak
global AWP_Reg    := 100    ; ms jeda registrasi peluru (anti boncos)
global AWP_Seq    := "q 3 1"
global AWP_Ready  := 180    ; ms jeda sampai senjata siap nembak lagi

; ------------------------ SG PUTER --------------------------------------
global SGP_Hold   := 26
global SGP_Reg    := 90
global SGP_Seq    := "q 3 1 1"   ; combo asli SG puter; kalau boncos coba "q 3 1"
global SGP_Ready  := 170

; ------------------------ SPAS ------------------------------------------
global SPS_Hold   := 26
global SPS_Reg    := 100
global SPS_Seq    := "q 3 1"     ; kalau SPAS masih boncos, coba "q 3 1 1"
global SPS_Ready  := 190

; ------------------------ SHOTGUN ZOMBIE --------------------------------
global SGZ_Hold   := 24
global SGZ_Reg    := 75
global SGZ_Seq    := "3 1"       ; paling cepat; kalau boncos coba "q 3 1"
global SGZ_Ready  := 150

; ============================== HOTKEY ==================================
Tampil("MACRO READY`nF6 Sniper | F7 SG | F8 SPAS | F9 Zombie | F10 Auto Tap Recoil`nF2 = status / setting")

F1::
Click, Up
SendInput, {RButton Up}
SendInput, {q Up}
SendInput, {3 Up}
SendInput, {1 Up}
DllCall("Winmm\timeEndPeriod", "UInt", 1)
ExitApp
return

F2::
Tampil("MODE : " . NamaMode(Mode) . "`nQC Offset : " . QC_Offset . " ms`nRecoil : AUTO TAP (ori)  Hold " . NR_Down . " ms / Jeda " . NR_Gap . " ms`n`nF3 = QC cepat | F4 = QC lambat`nF11/F12 = kecepatan tap`nShift+F11/F12 = lama tahan klik`nCtrl+F10 = reset tap ke ori")
return

F3::
QC_Offset -= 10
if (QC_Offset < -40)
    QC_Offset := -40
Tampil("Quick Change LEBIH CEPAT`nOffset: " . QC_Offset . " ms`nKalau boncos, tekan F4")
return

F4::
QC_Offset += 10
if (QC_Offset > 120)
    QC_Offset := 120
Tampil("Quick Change LEBIH LAMBAT / AMAN`nOffset: " . QC_Offset . " ms")
return

F5::
MacroAktif := false
Mode := "NONE"
SoundBeep, 400, 120
Tampil("MACRO OFF`nTekan F6..F10 untuk pilih mode")
return

F6::
SetMode("AWP", "SNIPER KEKER + QC")
return

F7::
SetMode("SGP", "SG PUTER + QC")
return

F8::
SetMode("SPS", "SPAS + QC")
return

F9::
SetMode("SGZ", "SHOTGUN ZOMBIE + QC")
return

F10::
SetMode("NORMAL", "SENJATA BIASA - AUTO TAP RECOIL ORI")
return

F11::
NR_Gap -= 2
if (NR_Gap < 8)
    NR_Gap := 8
Tampil("Tap LEBIH CEPAT`nJeda antar tap: " . NR_Gap . " ms")
return

F12::
NR_Gap += 2
if (NR_Gap > 120)
    NR_Gap := 120
Tampil("Tap LEBIH LAMBAT / AMAN`nJeda antar tap: " . NR_Gap . " ms")
return

+F11::
NR_Down -= 2
if (NR_Down < 10)
    NR_Down := 10
Tampil("Hold klik LEBIH PENDEK`nHold: " . NR_Down . " ms")
return

+F12::
NR_Down += 2
if (NR_Down > 100)
    NR_Down := 100
Tampil("Hold klik LEBIH LAMA`nHold: " . NR_Down . " ms")
return

^F10::
NR_Down := 30
NR_Gap  := 24
Tampil("Tap recoil direset ke setting ORI`nHold: " . NR_Down . " ms | Jeda: " . NR_Gap . " ms")
return

; ======================= KLIK KIRI (SAAT MACRO ON) ======================
#If (MacroAktif)
$LButton::
if (Mode = "NORMAL")
{
    NoRecoil()
    return
}

; Minimal 1 siklus walau klik cuma sebentar (biar tidak ada klik yang hilang)
SatuSiklus()

; Kalau ditahan, ulang terus
while (GetKeyState("LButton", "P") && MacroAktif)
    SatuSiklus()

Click, Up
return

$LButton Up::
return
#If

; ============================== FUNGSI ==================================
SatuSiklus()
{
    global Mode
    global AWP_Scope, AWP_ScopeT, AWP_ScopeD, AWP_Hold, AWP_Reg, AWP_Seq, AWP_Ready
    global SGP_Hold, SGP_Reg, SGP_Seq, SGP_Ready
    global SPS_Hold, SPS_Reg, SPS_Seq, SPS_Ready
    global SGZ_Hold, SGZ_Reg, SGZ_Seq, SGZ_Ready

    if (Mode = "AWP")
    {
        if (AWP_Scope)
        {
            SendInput, {RButton Down}
            Sleep, %AWP_ScopeT%
            SendInput, {RButton Up}
            Sleep, %AWP_ScopeD%
        }
        QC(AWP_Hold, AWP_Reg, AWP_Seq, AWP_Ready)
    }
    else if (Mode = "SGP")
        QC(SGP_Hold, SGP_Reg, SGP_Seq, SGP_Ready)
    else if (Mode = "SPS")
        QC(SPS_Hold, SPS_Reg, SPS_Seq, SPS_Ready)
    else if (Mode = "SGZ")
        QC(SGZ_Hold, SGZ_Reg, SGZ_Seq, SGZ_Ready)
}

SetMode(m, label)
{
    global MacroAktif, Mode
    Mode := m
    MacroAktif := true
    SoundBeep, 850, 90
    if (m = "NORMAL")
        Tampil("MODE: " . label . "`nTahan klik = tap cepat | F12 kalau boncos")
    else
        Tampil("MODE: " . label . "`nF4 kalau boncos | F3 kalau mau lebih cepat")
}

NamaMode(m)
{
    if (m = "AWP")
        return "SNIPER KEKER"
    if (m = "SGP")
        return "SG PUTER"
    if (m = "SPS")
        return "SPAS"
    if (m = "SGZ")
        return "SHOTGUN ZOMBIE"
    if (m = "NORMAL")
        return "SENJATA BIASA (RECOIL ORI / AUTO TAP)"
    return "OFF"
}

Tampil(teks)
{
    ToolTip, %teks%, 20, 20
    SetTimer, HapusToolTip, -1800
}

HapusToolTip:
ToolTip
return

; -------------------------------------------------------------------------
; QC: Tembak -> jeda registrasi -> pindah senjata -> jeda ready
; -------------------------------------------------------------------------
QC(hold, reg, seq, ready)
{
    global QC_Step, QC_Offset

    Click, Down
    Sleep, %hold%
    Click, Up

    r := reg + QC_Offset
    if (r < 50)
        r := 50
    Sleep, %r%

    st := QC_Step
    if (st < 12)
        st := 12

    for _, k in StrSplit(seq, " ")
    {
        SendInput, % "{" . k . " Down}"
        Sleep, %st%
        SendInput, % "{" . k . " Up}"
        Sleep, %st%
    }

    rd := ready + QC_Offset
    if (rd < 80)
        rd := 80
    Sleep, %rd%
}

; -------------------------------------------------------------------------
; NO RECOIL: AUTO TAP (dari MACRO RECOIL ORI)
; Klik ditahan -> tap cepat berulang: klik turun NR_Down ms, klik naik,
; jeda NR_Gap ms, ulangi. Langsung stop begitu klik kiri dilepas.
; -------------------------------------------------------------------------
NoRecoil()
{
    global NR_Down, NR_Gap
    global MacroAktif, Mode

    ; Tembak pertama langsung
    Click, Down
    Sleep, %NR_Down%
    Click, Up

    ; Loop selama LButton ditahan
    while (GetKeyState("LButton", "P") && MacroAktif && Mode = "NORMAL")
    {
        ; Cek sebelum jeda biar langsung stop pas lepas
        if (!GetKeyState("LButton", "P") || !MacroAktif || Mode != "NORMAL")
            break

        Sleep, %NR_Gap%

        if (!GetKeyState("LButton", "P") || !MacroAktif || Mode != "NORMAL")
            break

        Click, Down
        Sleep, %NR_Down%
        Click, Up
    }

    ; Pastikan release terakhir
    Click, Up
}
