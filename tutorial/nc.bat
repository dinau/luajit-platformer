@echo off

if "%1"=="" (
  set src=platformer_part8
) else (
  set src=platformer_part%1
)

nim c -r -d:release %src%
