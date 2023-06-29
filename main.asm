include sprites.asm
include utils.asm
NADA        equ      00
JUGADOR     equ      01
PARED       equ      02
CAJA        equ      03
OBJETIVO    equ      04
SUELO       equ      05
.MODEL SMALL
.RADIX 16
.STACK
.DATA

getSprites

iniciar_juego db "INICIAR JUEGO$"
cargar_nivel  db "CARGAR NIVEL$"
configuracion db "CONFIGURACION$"
puntajes      db "PUNTAJES ALTOS$"
salir         db "SALIR$"
iniciales     db "Diego Andres Huite Alvarez",0A,"              202003585","$"
controlesActuales     db "CONTROLES ACTUALES","$"
;; JUEGO
xJugador      db 2
yJugador      db 4
puntos        dw 0
;; MENÚS
opcion        db 0
maximo        db 0
xFlecha       dw 0
yFlecha       dw 0
;; CONTROLES
control_arriba    db  48
control_abajo     db  50
control_izquierda db  4b
control_derecha   db  4d
;; prompts change controls
prompt_arriba    db  "Presione tecla arriba: ", "$"
prompt_abajo     db  "Presione tecla abajo: ", "$"
prompt_izquierda db  "Presione tecla izquierda: ", "$"
prompt_derecha   db  "Presione tecla derecha: ", "$"
;; STRING CONTROLES
stringcontrol_arriba    db  " ", "$"
stringcontrol_abajo     db  " ", "$"
stringcontrol_izquierda db  " ", "$"
stringcontrol_derecha   db  " ", "$"
; string control indicator
mensajecontrol_arriba    db  "ARRIBA: ", "$"
mensajecontrol_abajo     db  "ABAJO: ", "$"
mensajecontrol_izquierda db  "IZQUIERDA: ", "$"
mensajecontrol_derecha   db  "DERECHA: ", "$"
mensajecambiarControles  db  "Cambiar controles", "$"
mensajeregresar  db  "Regresar", "$"
.CODE
.STARTUP
inicio:
		;; MODO VIDEO ;;
		mov AH, 00
		mov AL, 13
		int 10
		;;

		;;;; POSICIONARNOS EN LA FILA 08 COLUMNA 05
		mov DL, 05
		mov DH, 08
		mov BH, 00
		mov AH, 02
		int 10
		;; IMPRIMIMOS MENSAJE
		
		printString iniciales
		; haciendo un for para un delay algo largo
		xor si, si
		

		cfor:
			cmp si, 0A
			je exitfor
			call delay

			inc si
			jmp cfor
		
		exitfor:

		displayPrincipalMenu:
		call clear_pantalla
		call menu_principal
		mov AL, [opcion]
		cmp AL, 0
		je quemadin
		cmp AL, 2
		je menuconfig

		

		;call mapa_quemado
		
menuconfig:
	call menu_config
	mov AL, [opcion]
	cmp AL, 0
	je changeControls
	cmp AL, 1
	je displayPrincipalMenu

changeControls:
	mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor

	call clear_pantalla
	printString prompt_abajo
	mov ah, 00
	int 16
	mov control_abajo, ah
	mov stringcontrol_abajo[0], al

		mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor

	call clear_pantalla
	printString prompt_arriba
	mov ah, 00
	int 16
	mov control_arriba, ah
	mov stringcontrol_arriba[0], al

		mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor


	call clear_pantalla
	printString prompt_derecha
	mov ah, 00
	int 16
	mov control_derecha, ah
	mov stringcontrol_derecha[0], al

		mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor


	call clear_pantalla
	printString prompt_izquierda
	mov ah, 00
	int 16
	mov control_izquierda, ah
	mov stringcontrol_izquierda[0], al






	jmp menuconfig



quemadin:
		call mapa_quemado
ciclo_juego:
		call pintar_mapa
		call entrada_juego
		jmp ciclo_juego
		;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;
		call menu_principal
		mov AL, [opcion]
		;; > INICIAR JUEGO
		;; > CARGAR NIVEL
		;; > CONFIGURACION
		;; > PUNTAJES ALTOS
		;; > SALIR
		cmp AL, 4
		je fin
		call clear_pantalla
		;;;;;;;;;;;;;;;;
infi:
		jmp infi
		jmp fin

;; pintar_pixel - pintar un pixel
;; ENTRADA:
;;     AX --> x pixel
;;     BX --> y pixel
;;     CL --> color
;; SALIDA: pintar pixel
;; AX + 320*BX
pintar_pixel:
		push AX
		push BX
		push CX
		push DX
		push DI
		push SI
		push DS
		mov DX, 0a000
		mov DS, DX
		;; (
		;; 	posicionarse en X
		mov SI, AX
		mov AX, 140
		mul BX
		add AX, SI
		mov DI, AX
		;;
		mov [DI], CL  ;; pintar
		;; )
		pop DS
		pop SI
		pop DI
		pop DX
		pop CX
		pop BX
		pop AX
		ret

;; pintar_sprite - pinta un sprite
;; Entrada:
;;    - DI: offset del sprite
;;    - SI: offset de las dimensiones
;;    - AX: x sprite 320x200
;;    - BX: y sprite 320x200
pintar_sprite:
		push DI
		push SI
		push AX
		push BX
		push CX
		inc SI
		mov DH, [SI]  ;; vertical
		dec SI        ;; dirección de tam horizontal
		;;
inicio_pintar_fila:
		cmp DH, 00
		je fin_pintar_sprite
		push AX
		mov DL, [SI]
pintar_fila:
		cmp DL, 00
		je pintar_siguiente_fila
		mov CL, [DI]
		call pintar_pixel
		inc AX
		inc DI
		dec DL
		jmp pintar_fila
pintar_siguiente_fila:
		pop AX
		inc BX
		dec DH
		jmp inicio_pintar_fila
fin_pintar_sprite:
		pop CX
		pop BX
		pop AX
		pop SI
		pop DI
		ret

;; delay - subrutina de retardo
delay:
		push SI
		push DI
		mov SI, 0200
cicloA:
		mov DI, 0130
		dec SI
		cmp SI, 0000
		je fin_delay
cicloB:
		dec DI
		cmp DI, 0000
		je cicloA
		jmp cicloB
fin_delay:
		pop DI
		pop SI
		ret
		

;; clear_pantalla - limpia la pantalla
;; ..
;; ..
clear_pantalla:
		mov CX, 19  ;; 25
		mov BX, 00
clear_v:
		push CX
		mov CX, 28  ;; 40
		mov AX, 00
clear_h:
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		add AX, 08
		loop clear_h
		add BX, 08
		pop CX
		loop clear_v
		ret




;; menu_principal - menu principal
;; ..
;; SALIDA
;;    - [opcion] -> código numérico de la opción elegida
menu_config:
		call clear_pantalla
		mov AL, 0
		mov [opcion], AL      ;; reinicio de la variable de salida
		mov AL, 2
		mov [maximo], AL
		mov AX, 3C
		mov BX, 58
		mov [xFlecha], AX
		mov [yFlecha], BX
	;; IMPRIMIR OPCIONES ;;
		;;;; INICIAR JUEGO
		mov DL, 0A  ; columna 12
		mov DH, 01  ;fila 1
		mov BH, 00
		mov AH, 02 
		int 10
		;; <<-- posicionar el cursor
		push DX
		mov DX, offset controlesActuales
		mov AH, 09
		int 21
		pop DX
		;;

		mov DL, 0C  ; columna 12
		mov DH, 01  ;fila 1
		mov BH, 00
		mov AH, 02 
		int 10
		;; <<-- posicionar el cursor
		;;;; ARRIBA: 
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajecontrol_arriba
		mov AH, 09
		int 21
		pop DX

		; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrol_arriba
		mov AH, 09
		int 21
		pop DX



		;;
		;;;; ABAJO: 
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajecontrol_abajo
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrol_abajo
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; izquierda
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajecontrol_izquierda
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrol_izquierda
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; DERECHA:
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajecontrol_derecha
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrol_derecha
		mov AH, 09
		int 21
		pop DX

		mov DL, 0A  ; columna 12
		mov DH, 09  ;fila 1
		mov BH, 00
		mov AH, 02 
		int 10

		
		;;;; CAMBIAR CONTROLES:
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajecambiarControles
		mov AH, 09
		int 21
		pop DX
		;;;; REGRESAR:
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset mensajeregresar
		mov AH, 09
		int 21
		pop DX

		
		;;;;
		call pintar_flecha
		;;;;
		;; LEER TECLA
		;;;;
entrada_menu_config:
		mov AH, 00
		int 16
		cmp AH, 48
		je restar_opcion_menu_config
		cmp AH, 50
		je sumar_opcion_menu_config
		cmp AH, 3b  ;; le doy F1
		je fin_menu_config
		jmp entrada_menu_config
restar_opcion_menu_config:
		mov AL, [opcion]
		dec AL
		cmp AL, 0ff
		je volver_a_ceroconfig
		mov [opcion], AL
		jmp mover_flecha_menu_config
sumar_opcion_menu_config:
		mov AL, [opcion]
		mov AH, [maximo]
		inc AL
		cmp AL, AH
		je volver_a_maximoconfig
		mov [opcion], AL
		jmp mover_flecha_menu_config
volver_a_ceroconfig:
		mov AL, 0
		mov [opcion], AL
		jmp mover_flecha_menu_config
volver_a_maximoconfig:
		mov AL, [maximo]
		dec AL
		mov [opcion], AL
		jmp mover_flecha_menu_config
mover_flecha_menu_config:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		mov AX, 3C
		mov BX, 58
		mov CL, [opcion]
ciclo_ubicar_flecha_menu_config:
		cmp CL, 0
		je pintar_flecha_menu_config
		dec CL
		add BX, 10
		jmp ciclo_ubicar_flecha_menu_config
pintar_flecha_menu_config:
		mov [xFlecha], AX
		mov [yFlecha], BX
		call pintar_flecha
		jmp entrada_menu_config
		;;
fin_menu_config:
		ret


;; menu_principal - menu principal
;; ..
;; SALIDA
;;    - [opcion] -> código numérico de la opción elegida
menu_principal:
		call clear_pantalla
		mov AL, 0
		mov [opcion], AL      ;; reinicio de la variable de salida
		mov AL, 5
		mov [maximo], AL
		mov AX, 50
		mov BX, 28
		mov [xFlecha], AX
		mov [yFlecha], BX
		;; IMPRIMIR OPCIONES ;;
		;;;; INICIAR JUEGO
		mov DL, 0c
		mov DH, 05
		mov BH, 00
		mov AH, 02
		int 10
		;; <<-- posicionar el cursor
		push DX
		mov DX, offset iniciar_juego
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; CARGAR NIVEL
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset cargar_nivel
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; PUNTAJES ALTOS
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset puntajes
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; CONFIGURACION
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset configuracion
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; SALIR
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset salir
		mov AH, 09
		int 21
		pop DX
		;;;;
		call pintar_flecha
		;;;;
		;; LEER TECLA
		;;;;
entrada_menu_principal:
		mov AH, 00
		int 16
		cmp AH, 48
		je restar_opcion_menu_principal
		cmp AH, 50
		je sumar_opcion_menu_principal
		cmp AH, 3b  ;; le doy F1
		je fin_menu_principal
		jmp entrada_menu_principal
restar_opcion_menu_principal:
		mov AL, [opcion]
		dec AL
		cmp AL, 0ff
		je volver_a_cero
		mov [opcion], AL
		jmp mover_flecha_menu_principal
sumar_opcion_menu_principal:
		mov AL, [opcion]
		mov AH, [maximo]
		inc AL
		cmp AL, AH
		je volver_a_maximo
		mov [opcion], AL
		jmp mover_flecha_menu_principal
volver_a_cero:
		mov AL, 0
		mov [opcion], AL
		jmp mover_flecha_menu_principal
volver_a_maximo:
		mov AL, [maximo]
		dec AL
		mov [opcion], AL
		jmp mover_flecha_menu_principal
mover_flecha_menu_principal:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		mov AX, 50
		mov BX, 28
		mov CL, [opcion]
ciclo_ubicar_flecha_menu_principal:
		cmp CL, 0
		je pintar_flecha_menu_principal
		dec CL
		add BX, 10
		jmp ciclo_ubicar_flecha_menu_principal
pintar_flecha_menu_principal:
		mov [xFlecha], AX
		mov [yFlecha], BX
		call pintar_flecha
		jmp entrada_menu_principal
		;;
fin_menu_principal:
		ret

;; pintar_flecha - pinta una flecha
pintar_flecha:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_flcha
		mov DI, offset data_sprite_flcha
		call pintar_sprite
		ret

;; adaptar_coordenada - 40x25->320x200
;; ENTRADA:
;;    AH -> x 40x25
;;    AL -> y 40x25
;; SALIDA:
;;    AX -> x 320x200
;;    BX -> y 320x200
adaptar_coordenada:
		mov DL, 08
		mov CX, AX
		mul DL
		mov BX, AX
		;;
		mov AL, CH
		mul DL
		ret
		
;; colocar_en_mapa - coloca un elemento en el mapa
;; ENTRADA:
;;    - DL -> código numérico del elemento
;;    - AH -> x
;;    - AL -> y
;; ...
colocar_en_mapa:
		mov CX, AX     ;;;   AH -> x -> CH
		mov BL, 28
		mul BL   ;; AL * BL  = AX
		mov CL, CH
		mov CH, 00     ;;; CX el valor de X completo
		add AX, CX
		mov DI, offset mapa
		add DI, AX
		mov [DI], DL
		ret


;; obtener_de_mapa - obtiene un elemento en el mapa
;; ENTRADA:
;;    - AH -> x
;;    - AL -> y
;; SALIDA:
;;    - DL -> código numérico del elemento
obtener_de_mapa:
		mov CX, AX
		mov BL, 28
		mul BL
		mov CL, CH
		mov CH, 00
		add AX, CX
		mov DI, offset mapa
		add DI, AX
		mov DL, [DI]
		ret


;; pintar_mapa - pinta los elementos del mapa
;; ENTRADA:
;; SALIDA:
pintar_mapa:
		mov AL, 01   ;; fila
		;;
ciclo_v:
		cmp AL, 18
		je fin_pintar_mapa
		mov AH, 00   ;; columna
		;;
ciclo_h:
		cmp AH, 28
		je continuar_v
		push AX
		call obtener_de_mapa
		pop AX
		;;
                cmp DL, NADA
		je pintar_vacio_mapa
		;;
                cmp DL, JUGADOR
		je pintar_jugador_mapa
		;;
                cmp DL, PARED
		je pintar_pared_mapa
		;;
                cmp DL, CAJA
		je pintar_caja_mapa
		;;
                cmp DL, OBJETIVO
		je pintar_objetivo_mapa
		;;
                cmp DL, SUELO
		je pintar_suelo_mapa
		;;
		jmp continuar_h
pintar_vacio_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		pop AX
		jmp continuar_h
pintar_suelo_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_suelo
		mov DI, offset data_sprite_suelo
		call pintar_sprite
		pop AX
		jmp continuar_h
pintar_jugador_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_jug
		mov DI, offset data_sprite_jug
		call pintar_sprite
		pop AX
		jmp continuar_h
pintar_pared_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_pared
		mov DI, offset data_sprite_pared
		call pintar_sprite
		pop AX
		jmp continuar_h
pintar_caja_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_caja
		mov DI, offset data_sprite_caja
		call pintar_sprite
		pop AX
		jmp continuar_h
pintar_objetivo_mapa:
		push AX
		call adaptar_coordenada
		mov SI, offset dim_sprite_obj
		mov DI, offset data_sprite_obj
		call pintar_sprite
		pop AX
		jmp continuar_h
continuar_h:
		inc AH
		jmp ciclo_h
continuar_v:
		inc AL
		jmp ciclo_v
fin_pintar_mapa:
		ret


;; mapa_quemado - mapa de prueba
mapa_quemado:
		mov DL, SUELO
		mov AH, 2
		mov AL, 2
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 3
		mov AL, 2
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 4
		mov AL, 2
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 2
		mov AL, 3
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 3
		mov AL, 3
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 4
		mov AL, 3
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 2
		mov AL, 4
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 3
		mov AL, 4
		call colocar_en_mapa
		mov DL, SUELO
		mov AH, 4
		mov AL, 4
		call colocar_en_mapa
		;;
		mov DL, JUGADOR
		mov AH, [xJugador]
		mov AL, [yJugador]
		call colocar_en_mapa
		;;
		mov DL, CAJA
		mov AH, 2
		mov AL, 3
		call colocar_en_mapa
		;;
		mov DL, OBJETIVO
		mov AH, 4
		mov AL, 2
		call colocar_en_mapa
		;;
		mov DL, PARED
		mov AH, 1
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 2
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 3
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 4
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 1
		mov AL, 2
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 2
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 1
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 3
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 1
		mov AL, 4
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 4
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 1
		mov AL, 5
		call colocar_en_mapa

		mov DL, PARED
		mov AH, 2
		mov AL, 5
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 3
		mov AL, 5
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 4
		mov AL, 5
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 5
		call colocar_en_mapa
		ret


;; entrada_juego - manejo de las entradas del juego
entrada_juego:
		mov AH, 01
		int 16
		jz fin_entrada_juego  ;; nada en el buffer de entrada
		mov AH, 00
		int 16
		;; AH <- scan code
		cmp AH, [control_arriba]
		je mover_jugador_arr
		cmp AH, [control_abajo]
		je mover_jugador_aba
		cmp AH, [control_izquierda]
		je mover_jugador_izq
		cmp AH, [control_derecha]
		je mover_jugador_der
		cmp AH, 3c
		ret
mover_jugador_arr:
		mov AH, [xJugador]
		mov AL, [yJugador]
		dec AL
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_pared_arriba
		mov [yJugador], AL
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
		mov DL, SUELO
		inc AL
		call colocar_en_mapa
		ret
hay_pared_arriba:
		ret
mover_jugador_aba:
		mov AH, [xJugador]
		mov AL, [yJugador]
		inc AL
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_pared_abajo
		mov [yJugador], AL
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
		mov DL, SUELO
		dec AL
		call colocar_en_mapa
		ret
hay_pared_abajo:
		ret
mover_jugador_izq:
		mov AH, [xJugador]
		mov AL, [yJugador]
		dec AH
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_pared_izquierda
		mov [xJugador], AH
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
		mov DL, SUELO
		inc AH
		call colocar_en_mapa
		ret
hay_pared_izquierda:
		ret
mover_jugador_der:
		mov AH, [xJugador]
		mov AL, [yJugador]
		inc AH
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_pared_derecha
		mov [xJugador], AH
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
		mov DL, SUELO
		dec AH
		call colocar_en_mapa
		ret
hay_pared_derecha:
		ret
fin_entrada_juego:
		ret


fin:
.EXIT
END
