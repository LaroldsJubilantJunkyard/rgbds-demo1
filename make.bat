mkdir dist
mkdir bin
rgbasm -L -o bin/hello-world.o src/hello-world.asm
rgblink -o dist/hello-world.gb bin/hello-world.o
rgbfix -v -p 0xFF dist/hello-world.gb