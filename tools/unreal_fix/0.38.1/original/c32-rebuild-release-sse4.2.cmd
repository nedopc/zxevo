@echo off
cd sndrender
nmake clean
nmake all SSE42=1 RELEASE=1
cd ..

cd z80
nmake clean
nmake all SSE42=1 RELEASE=1
cd ..

nmake clean
nmake all SSE42=1 RELEASE=1
