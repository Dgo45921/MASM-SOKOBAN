printString macro cadena
    mov dx, offset cadena
    mov ah, 09h
    int 21h
endm

saveBufferedInput macro buffer
    mov ah, 0Ah
    mov dx, offset buffer
    int 21h
endm


bufferPrinter macro buffer2
    
    mov bx, 01
    mov di, offset buffer2 ; guardamos la direccion del primer byte del buffer
    inc di         ; incrementamos 1 unidad la direccion
    xor ch, ch
    mov cl, [di]
    inc di
    mov dx, di  ; metemos a cx el primer byte
    mov ah, 40
    int 21h
    printString newLine
endm