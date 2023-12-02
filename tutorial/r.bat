@echo off

set LUA_PATH=;;..\lua\?.lua
set LUA_PATH=%LUA_PATH%;..\luajit-sdl2_image\?.lua

luajit platformer_part%1%.lua
