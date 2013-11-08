@echo off
cd sndrender
nmake all SSE42=1 RELEASE=1
cd ..

cd z80
nmake all SSE42=1 RELEASE=1
cd ..

nmake all SSE42=1 RELEASE=1
