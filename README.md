# Paddy Moindrot's ZX81 music programs

Machine-code music programs written by Paddy Moindrot for the Sinclair ZX81 in the 1980s.
ZXYLOPHONE and COMPOSER were recovered from his cassettes in November 2026. TUNES was
published as a type-in in *Sinclair Programs*, March 1985.

The ZX81 has no sound hardware. These programs make notes by switching the TV sync pulse
on and off, so the sound comes out of the TV speaker. They have to run in FAST mode.

## The programs

| File | What it is |
|---|---|
| `programs/ZXYLOPHONE_fixed.p` | ZXYLOPHONE with three fixes: a `FAST` line, `IN A,(254)` instead of `IN A,(255)`, and a SHIFT+RUBOUT stop that no longer leaves HL on the stack. Enter `RUN` to play. |
| `programs/COMPOSER_finished.p` | COMPOSER, finished in 2026 using Paddy's note table, tone loop and stop key. R records a tune, P plays it back, S saves it with the program. |
| `programs/ZXYLOPHONE_as_found.p` | ZXYLOPHONE exactly as it came off the cassette. |
| `programs/TUNES_1985.p` | TUNES from *Sinclair Programs*, March 1985: the published 43 bytes unchanged, with "When the Saints Go Marching In" in the line 2 REM. |

All need 16K and start by themselves once loaded. The `downloads` folder has the same
files zipped with a short README. `source/COMPOSER_finished.asm` is the Z80 source for the
finished COMPOSER (assembles with pasmo).

## Write-up and playable emulator

The full story, with the bugs explained and a JtyOne-based emulator with the TV sound
added, is here: https://claude.ai/artifact/AMB2T7izCwdEEjXw357ebX

The analysis, fixes and finished COMPOSER were done with help from Claude (Anthropic's AI).
The original programs are © Paddy Moindrot.
