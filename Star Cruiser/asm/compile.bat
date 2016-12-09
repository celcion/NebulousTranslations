:: детали в asm-файлах
:: собираем замену для исходного кода
ASM68K.EXE /p hack.asm, hack.bin
:: собираем вставку нового кода
ASM68K.EXE /p add.asm, add.bin
