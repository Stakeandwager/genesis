@echo off
REM Run the Genesis tests on Windows. One argument: the Godot 4.7.1 executable.
REM
REM   run_tests.bat "C:\path\to\Godot_v4.7.1-stable_win64.exe"
REM   run_tests.bat "C:\path\to\godot.exe" --all    also the slow racing suites
REM
REM Nothing is copied and no scratch project is built: the tests live in this
REM repository and run against the scripts beside them, so what is tested is
REM what is committed.
REM
REM Each suite prints its own result line. "failures=0" or "bad=0" passed;
REM sweep_test prints a VERDICT instead, because what it reports is a finding
REM rather than a pass.
setlocal enabledelayedexpansion
set GODOT=%~1
if "%GODOT%"=="" set GODOT=godot
set ALL=%~2
cd /d "%~dp0"

"%GODOT%" --headless --import >nul 2>&1

for %%f in (tests\*.gd) do (
  set NAME=%%~nf
  set SKIP=
  set ARGS=

  REM Nothing is skipped as broken. report_test was, from 014 to 024, on the
  REM strength of "hangs with no output at all". It threw a script error on a
  REM key 012 deleted, and a script error in a SceneTree aborts _initialize
  REM before quit(), so it ran on until it was killed. See TRAPS 13.

  REM Not suites: replay needs REPLAY_LOG and REPLAY_OUT set, and prompt_test
  REM prints the TOOLS section of the AI's prompt, and four EQUIP readbacks,
  REM for a human to read rather than a verdict. 102: this said "the AI's
  REM prompt"; it prints one of its three registry sections. See
  REM field_type_test section 8.
  echo !NAME! | findstr /c:"replay" /c:"prompt_test" >nul && set SKIP=not a suite

  REM Minutes rather than seconds: several full races apiece.
  if not "%ALL%"=="--all" (
    echo !NAME! | findstr /c:"drive_test" /c:"session_test" >nul && set SKIP=slow, pass --all
  )

  REM Suites that step physics need a fixed rate.
  echo !NAME! | findstr /c:"carry_test" /c:"false_delivery" /c:"ledger" /c:"order_test" /c:"explore" /c:"walker" /c:"physics" /c:"behaviour" /c:"interference" /c:"repeat_test" /c:"drive" /c:"session" /c:"controller_reach" >nul && set ARGS=--fixed-fps 120

  if defined SKIP (
    echo !NAME!  --  skipped ^(!SKIP!^)
  ) else (
    echo --- !NAME!
    "%GODOT%" --headless !ARGS! --script "%%f" 2>&1 | findstr /c:"failures=" /c:"bad=" /c:"VERDICT" /c:"SCRIPT ERROR" /c:"Parse Error"
  )
)
endlocal
