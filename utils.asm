printString macro cadena
    mov dx, offset cadena
    mov ah, 09h
    int 21h
endm
