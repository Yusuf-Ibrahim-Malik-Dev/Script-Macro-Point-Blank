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
;   F10 = SENJATA BIASA : BREN CENTER (nembak cepat + aim balik ke tengah)
;   F11 = Kurangi tarikan recoil (pull down)
;   F12 = Tambah tarikan recoil (pull down)
;   Shift+F11 = Tap lebih CEPAT (kalau boncos, jangan dipakai)
;   Shift+F12 = Tap lebih LAMBAT / AMAN (kalau peluru masih boncos)
;   Ctrl+F10  = ON/OFF aim balik ke tengah setelah selesai nembak

;
; CARA PAKAI:
;   - Pilih mode dengan F6..F10
;   - Klik kiri = 1x aksi. Tahan klik kiri = ulang otomatis.
;   - Kalau tembakan "boncos" / peluru hilang / senjata tidak nembak:
;       tekan F4 beberapa kali (QC jadi lebih lambat), lalu tes lagi.
;   - Kalau sudah tidak boncos dan mau lebih cepat:
;       tekan F3 beberapa kali.
;   - Mode F10 (BREN CENTER):
;       Tahan klik kiri = nembak cepat ala BREN, tiap peluru di-tap ulang.
;       Setelah klik dilepas, aim OTOMATIS balik ke titik awal (tengah),
;       jadi tembakan berikutnya selalu mulai dari center lagi.
;       Kalau crosshair masih naik  -> F12 beberapa kali.
;       Kalau justru turun ke bawah -> F11.
;       Kalau peluru boncos           -> Shift+F12 (tap diperlambat).
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

; No Recoil (senjata biasa) - BREN CENTER
; Tiap peluru di-TAP ulang (bukan dikunci full-auto), jadi recoil tidak
; menumpuk dan kelompok peluru tetap di tengah. Tetap terasa cepat ala BREN.
; Setelah klik dilepas, mouse dikembalikan ke posisi awal (aim balik ke
; tengah), jadi burst berikutnya tidak melenceng ke bawah.
; Kalau crosshair masih naik: tekan F12 (tambah pull down).
; Kalau crosshair malah turun : tekan F11.
; Kalau peluru boncos / tidak keluar: tekan Shift+F12 (tap diperlambat).
global NR_Down    := 1      ; px tarik mouse ke bawah tiap peluru
global NR_Pulse   := 15     ; ms tahan klik per peluru (jangan terlalu kecil)
global NR_Gap     := 18     ; ms jeda antar peluru (kecil = lebih cepat)
global NR_MaxDown := 150    ; batas tarik ke bawah per burst (biar tidak ngunci bawah)
global NR_Return  := true   ; aim balik ke titik awal tiap selesai nembak

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
Tampil("MACRO READY`nF6 Sniper | F7 SG | F8 SPAS | F9 Zombie | F10 No Recoil`nF2 = status / setting")

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
Tampil("MODE : " . NamaMode(Mode) . "`nQC Offset : " . QC_Offset . " ms`nRecoil Down : " . NR_Down . " px / peluru`nTap : " . NR_Pulse . " ms tahan + " . NR_Gap . " ms jeda`nAim balik ke tengah : " . (NR_Return ? "ON" : "OFF") . "`n`nF3 = QC cepat | F4 = QC lambat`nF11/F12 = tarikan recoil`nShift+F11/F12 = kecepatan tap")
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
SetMode("NORMAL", "SENJATA BIASA - NO RECOIL")
return

F11::
NR_Down -= 1
if (NR_Down < 0)
    NR_Down := 0
Tampil("Recoil pull DOWN: " . NR_Down . " px")
return

F12::
NR_Down += 1
if (NR_Down > 40)
    NR_Down := 40
Tampil("Recoil pull DOWN: " . NR_Down . " px")
return

+F11::
NR_Gap -= 2
if (NR_Gap < 10)
    NR_Gap := 10
Tampil("Tap LEBIH CEPAT`nJeda: " . NR_Gap . " ms`nKalau boncos tekan Shift+F12")
return

+F12::
NR_Gap += 2
if (NR_Gap > 80)
    NR_Gap := 80
Tampil("Tap LEBIH LAMBAT / AMAN`nJeda: " . NR_Gap . " ms")
return

^F10::
NR_Return := !NR_Return
Tampil("Aim balik ke tengah: " . (NR_Return ? "ON" : "OFF"))
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
{
    if (Mode = "NORMAL")
    {
        NoRecoil()
        break
    }
    SatuSiklus()
}

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
        Tampil("MODE: " . label . "`nF12 kalau crosshair masih naik")
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
        return "SENJATA BIASA (NO RECOIL)"
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
; NO RECOIL: BREN CENTER
; Tiap peluru di-TAP ulang (Down -> jeda -> Up -> jeda), bukan ditahan
; full-auto. Recoil tidak sempat menumpuk, jadi kelompok peluru tetap
; di tengah. Mouse ditarik sedikit ke bawah tiap peluru (NR_Down) supaya
; crosshair tidak naik, lalu SETELAH SELESAI NEMBAK mouse dikembalikan
; ke posisi awal (NR_Return) supaya aim balik ke tengah.
; -------------------------------------------------------------------------
NoRecoil()
{
    global NR_Down, NR_Pulse, NR_Gap, NR_MaxDown, NR_Return, MacroAktif, Mode

    totalTurun := 0

    while (GetKeyState("LButton", "P") && MacroAktif && Mode = "NORMAL")
    {
        ; 1. Tarik recoil sedikit (kalau NR_Down = 0 berarti murni center)
        if (NR_Down > 0 && totalTurun < NR_MaxDown)
        {
            DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", NR_Down, "UInt", 0, "UPtr", 0)
            totalTurun += NR_Down
        }

        ; 2. Tap 1 peluru -> tidak full-auto nyangkut = tetap center
        SendInput, {LButton Down}
        Sleep, %NR_Pulse%
        SendInput, {LButton Up}
        Sleep, %NR_Gap%
    }

    SendInput, {LButton Up}

    ; 3. Balikkan aim ke posisi awal (tengah) setelah selesai nembak
    if (NR_Return && totalTurun > 0)
        DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", -totalTurun, "UInt", 0, "UPtr", 0)
}
