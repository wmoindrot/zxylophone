; =============================================================
;  COMPOSER  -  by Paddy Moindrot (ZX81, 16K)
;  Finished 2026 from his unfinished code: same note table,
;  same tone loop (IN = sync on, delay, OUT = sync off, delay)
;  and the same SHIFT+RUBOUT stop key.
;
;  RAND USR 16514  records a tune from the ZXYLOPHONE keys
;  RAND USR 16517  plays it back
;  PEEK 16520+256*PEEK 16521 = number of notes in the tune
;  Run in FAST mode: the ZX81 can only make sound with the
;  display switched off.
;
;  The tune is stored as the raw key code and how many times
;  the tone loop went round, so playback goes through exactly
;  the same code as recording and keeps the same pitch and timing.
; =============================================================

KEYBOARD equ $02BB
DECODE   equ $07BD
RESTLEN  equ 100                ; loop length used for silences
MAXEV    equ 480                ; notes and rests the tune can hold

        org $4082

        jp record               ; 16514
        jp play                 ; 16517
notes:  defw 0                  ; 16520 number of notes recorded

; Paddy's note table, one byte per key in ROM key-table order
; (bigger number = lower note, 0 = key not used)
table:  defb 245,214,185,171,0,230,201,0,157,0,100,85,71,62,0,0,91,77,0,0
        defb 0,35,46,55,0,27,31,39,49,0,0,0,111,132,0,95,103,120,141

; ---------------- record ----------------
record: call waitrel
        ld hl,buffer
        ld (ptr),hl
        ld hl,0
        ld (notes),hl
        call term               ; empty tune until something is played
rwait:  call scanraw            ; wait for the first key
        ret c                   ; SHIFT+RUBOUT before playing anything
        ld a,c
        inc a
        jr z,rwait
        ld (curk),bc
        ld hl,0
        ld (cnt),hl
rloop:  call step               ; one tone cycle (or a slice of silence)
        ld hl,(cnt)
        inc hl
        ld a,h
        or l
        jr z,rl1                ; very long note: stop counting at 65535
        ld (cnt),hl
rl1:    call scanraw
        jr c,rstop
        ld hl,(curk)
        ld a,h
        cp b
        jr nz,rnew
        ld a,l
        cp c
        jr z,rloop              ; same key still held (or still silent)
rnew:   push bc                 ; key changed: store what went before
        call flush
        pop bc
        jr c,rdone              ; tune memory full
        ld (curk),bc
        ld hl,0
        ld (cnt),hl
        jr rloop
rstop:  ld bc,(curk)            ; keep the last note, drop a final silence
        ld a,c
        inc a
        call nz,flush
rdone:  jp term

; ---------------- play back ----------------
play:   call waitrel
        ld hl,buffer
pnext:  ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,d
        or e
        ret z                   ; count 0 marks the end of the tune
        push hl
        ld (curk),bc
pl1:    push de
        call scanraw            ; same keyboard read as when recording
        pop de
        jr c,pstop              ; SHIFT+RUBOUT stops playback
        push de
        ld bc,(curk)
        call step
        pop de
        dec de
        ld a,d
        or e
        jr nz,pl1
        pop hl
        jr pnext
pstop:  pop hl
        ret

; ---------------- one pass of the music loop ----------------
; BC = key code: plays one cycle of that key's note, or a rest
step:   ld a,c
        inc a
        jr z,srest
        call lookup
        or a
        jr z,srest
        ld b,a
tone:   in a,($FE)              ; sync on   (Paddy had $FF here)
        call delay
        out ($FF),a             ; sync off
delay:  ld a,b                  ; Paddy's delay loop
dl1:    dec a
        jr nz,dl1
        ret
srest:  ld b,RESTLEN
        call delay
        jr delay

; key code -> note value (0 if the key isn't a note)
lookup: call DECODE
        ld de,-$7E
        add hl,de
        ld a,h
        or a
        jr nz,lbad
        ld a,l
        cp 39
        jr nc,lbad
        ld de,table
        add hl,de
        ld a,(hl)
        ret
lbad:   xor a
        ret

; read keyboard: BC = key code, carry set if SHIFT+RUBOUT
scanraw:
        call KEYBOARD
        ld a,h
        cp $FC
        jr nz,sr1
        ld a,l
        cp $EF
        jr nz,sr1
        scf
        ret
sr1:    set 0,h                 ; ignore SHIFT, as Paddy did
        ld b,h
        ld c,l
        and a
        ret

; wait until no key is pressed
waitrel:
        call KEYBOARD
        ld a,l
        inc a
        jr nz,waitrel
        ret

; store (curk, cnt) in the tune; carry set if the tune is now full
flush:  ld hl,(ptr)
        ld bc,(curk)
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        ld de,(cnt)
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (ptr),hl
        ld a,c
        inc a
        jr z,fl1
        call lookup
        or a
        jr z,fl1
        ld hl,(notes)
        inc hl
        ld (notes),hl
fl1:    ld hl,(ptr)
        ld de,bufend
        and a
        sbc hl,de
        ccf
        ret

term:   ld hl,(ptr)             ; end marker: key 0, count 0
        xor a
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a
        ret

ptr:    defw buffer
curk:   defw 0
cnt:    defw 0

buffer: defs MAXEV*4
bufend: defs 4
