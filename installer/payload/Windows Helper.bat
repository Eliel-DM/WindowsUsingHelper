@echo off
rem Windows Helper - lancador do modos.ps1 com elevacao de administrador
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%~dp0modos.ps1'"
