include sprites.asm
include utils.asm
NADA        equ      00
JUGADOR     equ      01
PARED       equ      02
CAJA        equ      03
OBJETIVO    equ      04
SUELO       equ      05
CORRECTPOS  equ      06
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
xJugador      db 0
yJugador      db 0
puntos        dw 0
;; MENÚS
opcion        db 0
maximo        db 0
xFlecha       dw 0
yFlecha       dw 0
;; CONTROLES
controlUp    db  48
controlDown     db  50
controlLeft db  4b
controlRight   db  4d
;; prompts change controls
promptUp    db  "Presione tecla arriba: ", "$"
promptDown     db  "Presione tecla abajo: ", "$"
promptLeft db  "Presione tecla izquierda: ", "$"
promptRight   db  "Presione tecla derecha: ", "$"
;; STRING CONTROLES
stringcontrolUp    db  " ", "$"
stringcontrolDown     db  " ", "$"
stringcontrolLeft db  " ", "$"
stringcontrolRight   db  " ", "$"
; string control indicator
mensajecontrolUp    db  "ARRIBA: ", "$"
mensajecontrolDown     db  "ABAJO: ", "$"
mensajecontrolLeft db  "IZQUIERDA: ", "$"
mensajecontrolRight   db  "DERECHA: ", "$"
mensajecambiarControles  db  "Cambiar controles", "$"
mensajeregresar  db  "Regresar", "$"
banderin  db 0
; mensajes de pausa
reaundarPausa  db  "Reanudar", "$"
salirPausa  db  "Salir", "$"
;; NIVELES
nivel_x           db  "NIV.00",00
handle_nivel      dw  0000
linea             db  100 dup (0)
elemento_actual   db  0
xElemento         db  0
yElemento         db  0
;; TOKENS
tk_pared      db  05,"pared"
tk_suelo      db  05,"suelo"
tk_jugador    db  07,"jugador"
tk_caja       db  04,"caja"
tk_objetivo   db  08,"objetivo"
tk_coma       db  01,","
;;
numero        db  5 dup (30)
contadormalPuestas db 0000
contadorLevel db 0000
;;

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
		mov [contadorLevel], 0000
		mov nivel_x[04], "0"
		mov nivel_x[05], "0"
		mov di, offset mapa
		mov cx, 3e8
		mov al, 0000
		call memset



		displayPrincipalMenu:
		call clear_pantalla
		call menu_principal
		mov AL, [opcion]
		cmp AL, 0
		je cargar_un_nivel

		cmp AL, 2
		je menuconfig

		cmp AL, 4
		je fin

		


		
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
	printString promptDown
	mov ah, 00
	int 16
	mov controlDown, ah
	mov stringcontrolDown[0], al

	mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor

	call clear_pantalla
	printString promptUp
	mov ah, 00
	int 16
	mov controlUp, ah
	mov stringcontrolUp[0], al

		mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor


	call clear_pantalla
	printString promptRight
	mov ah, 00
	int 16
	mov controlRight, ah
	mov stringcontrolRight[0], al

		mov DL, 05  ; columna 12
	mov DH, 01  ;fila 1
	mov BH, 00
	mov AH, 02 
	int 10
		;; <<-- posicionar el cursor


	call clear_pantalla
	printString promptLeft
	mov ah, 00
	int 16
	mov controlLeft, ah
	mov stringcontrolLeft[0], al






	jmp menuconfig

ciclo_juego:
		call pintar_mapa
		call entrada_juego
		jmp ciclo_juego
		;;;;;;;;;;;;;;;;
pasarSiguienteLevel:
	inc contadorLevel
	cmp contadorLevel, 01
	je gotoSecond
	cmp contadorLevel, 02
	je gotoThird
	jmp restart



	gotoSecond:
	mov nivel_x[04], "0"
	mov nivel_x[05], "1"

	mov di, offset mapa
	mov cx, 3e8
	mov al, 0000
	call memset
	jmp cargar_un_nivel


	gotoThird:
	mov nivel_x[04], "1"
	mov nivel_x[05], "0"
	mov di, offset mapa
	mov cx, 3e8
	mov al, 0000
	call memset
	jmp cargar_un_nivel


	restart:
		jmp exitfor



cargar_un_nivel:
		mov [contadormalPuestas], 0000
		mov AL, 00
		mov DX, offset nivel_x
		mov AH, 3d
		int 21
		jc inicio
		mov [handle_nivel], AX
		;;
ciclo_lineas:
		mov BX, [handle_nivel]
		call siguiente_linea
		cmp DL, 0ff      ;; fin-del-archivo?
		je ver_si_hay_algo_en_linea
		cmp DH, 00      ;; línea-con-algo?
		je ciclo_lineas
		jmp logica_parseo
ver_si_hay_algo_en_linea:
		cmp DH, 00
		je fin_parseo
		;;;;;;;;;;;;;;;;;;;;;;;
		;; lógica del parseo ;;
		;;;;;;;;;;;;;;;;;;;;;;;
		;; ignorar espacios o retornos de carro
logica_parseo:
		mov DI, offset linea
		push DI
		;; veríficar retorno de carro
		mov AL, [DI]
		cmp AL, 20
		je ignorar0
		cmp AL, 0d
		je ignorar0
		jmp iniciar_parseo
ignorar0:
		call ignorar_espacios
		;;
		;; al principio del buffer de la línea está: pared, caja, jugador, suelo, objetivo
iniciar_parseo:
		mov SI, offset tk_pared
		call cadena_igual
		cmp DL, 0ff               ;; cadenas iguales
		je es_pared
		pop DI
		push DI
		mov SI, offset tk_caja
		call cadena_igual
		cmp DL, 0ff               ;; cadenas iguales
		je es_caja
		pop DI
		push DI
		mov SI, offset tk_suelo
		call cadena_igual
		cmp DL, 0ff               ;; cadenas iguales
		je es_suelo
		pop DI
		push DI
		mov SI, offset tk_objetivo
		call cadena_igual
		cmp DL, 0ff               ;; cadenas iguales
		je es_objetivo
		pop DI
		push DI
		mov SI, offset tk_jugador
		call cadena_igual
		cmp DL, 0ff               ;; cadenas iguales
		je es_jugador
		pop DI
		jmp ciclo_lineas
es_pared:
		mov AL, PARED
		mov [elemento_actual], AL
		jmp continuar_parseo0
es_caja:
		mov AL, CAJA
		mov [elemento_actual], AL
		jmp continuar_parseo0
es_suelo:
		mov AL, SUELO
		mov [elemento_actual], AL
		jmp continuar_parseo0
es_objetivo:
		mov AL, OBJETIVO
		mov [elemento_actual], AL
		inc contadormalPuestas
		jmp continuar_parseo0
es_jugador:
		mov AL, JUGADOR
		mov [elemento_actual], AL
		jmp continuar_parseo0
		;; ignorar espacios
continuar_parseo0:
		pop SI         ; ignorara valor inicial de DI
		mov AL, [DI]
		cmp AL, 20
		jne ciclo_lineas
		call ignorar_espacios
		;; obtener una cadena numérica
		call leer_cadena_numerica
		push DI
		mov DI, offset numero
		call cadenaAnum
		mov [xElemento], AL
		pop DI
		;; ignorar espacios
		mov AL, [DI]
		cmp AL, 20
		je continuar_parseo1
		cmp AL, ','
		je continuar_parseo2
		jmp ciclo_lineas
continuar_parseo1:
		;; ignorar espacios
		call ignorar_espacios
continuar_parseo2:
		;; obtener una coma
		mov SI, offset tk_coma
		call cadena_igual
		cmp DL, 0ff
		jne ciclo_lineas
		;; ignorar espacios
		mov AL, [DI]
		cmp AL, 20
		jne ciclo_lineas
		call ignorar_espacios
		;; obtener una cadena numérica
		mov AL, [elemento_actual]
		cmp AL, JUGADOR
		jne seguir_normal_debug
seguir_normal_debug:
		call leer_cadena_numerica
		push DI
		mov DI, offset numero
		call cadenaAnum
		mov [yElemento], AL
		pop DI
		;; ignorar_espacios o retorno de carro
		mov AL, [DI]
		cmp AL, 20
		je ignorar1
		cmp AL, 0d
		je ignorar1
		jmp ver_final_de_linea
ignorar1:
		call ignorar_espacios
		;; ver si es el final de la cadena
ver_final_de_linea:
		mov AL, [DI]
		cmp AL, 00
		jne ciclo_lineas
		;; usar la información
		;;
		mov DL, [elemento_actual]
		mov AH, [xElemento]
		mov AL, [yElemento]
		call colocar_en_mapa
		mov AL, JUGADOR
		cmp AL, [elemento_actual]
		je guardar_coordenadas_jugador
		jmp ciclo_lineas
guardar_coordenadas_jugador:
		mov AH, [xElemento]
		mov AL, [yElemento]
		mov [xJugador], AH
		mov [yJugador], AL
		jmp ciclo_lineas
		;;;;;;;;;;;;;;;;;;;;;;;
fin_parseo:
		;; cerrar archivo
		mov AH, 3e
		mov BX, [handle_nivel]
		int 21
		;;
		jmp ciclo_juego
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
		mov DX, offset mensajecontrolUp
		mov AH, 09
		int 21
		pop DX

		; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrolUp
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
		mov DX, offset mensajecontrolDown
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrolDown
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
		mov DX, offset mensajecontrolLeft
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrolLeft
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
		mov DX, offset mensajecontrolRight
		mov AH, 09
		int 21
		pop DX

			; imprimiendo el caracter correspondiente
		push DX
		mov DX, offset stringcontrolRight
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
		mov AL, 00   ;; fila
		;;
ciclo_v:
		cmp AL, 19
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
                cmp DL, CORRECTPOS
		je pintar_caja_mapa
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
		mov DL, PARED
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
		mov AL, 1
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 2
		mov AL, 1
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 3
		mov AL, 1
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 4
		mov AL, 1
		call colocar_en_mapa
		mov DL, PARED
		mov AH, 5
		mov AL, 1
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



entrada_juego:
		mov AH, 01
		int 16
		jz fin_entrada_juego 
		mov AH, 00
		int 16
		;; AH <- scan code
		cmp AH, [controlUp]
		je mover_jugador_arr
		cmp AH, [controlDown]
		je mover_jugadorDown
		cmp AH, [controlLeft]
		je mover_jugadorLeft
		cmp AH, [controlRight]
		je mover_jugadorRight
		cmp AH, 3C
		je putPause

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
		je hay_paredUp
        cmp DL, CAJA 
		je hay_cajaUp
        cmp DL, OBJETIVO 
		je hay_objetivoUp
        cmp DL, CORRECTPOS 
		je hay_CORRECTPOSUp
		mov [yJugador], AL         
		;;
		mov DL, JUGADOR            
		push AX
		call colocar_en_mapa        
		pop AX
		;;
        cmp [banderin], 00     
        jne pintar_objetivoUp
        ;;
		mov DL, SUELO             
		inc AL                    
		call colocar_en_mapa        
		ret
hay_paredUp:
		ret
hay_CORRECTPOSUp:
		inc contadormalPuestas
       
        dec AL
        push AX
		call obtener_de_mapa
		pop AX
       
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je PutcorrPosUp
       
        mov DL, CAJA           
		push AX
		call colocar_en_mapa      
		pop AX
      
        inc AL 
        mov [yJugador], AL         
        mov DL, JUGADOR           
		push AX
		call colocar_en_mapa      
		pop AX
        cmp [banderin], 00    
        jne pintar_objetivoUp
        ;;
		mov DL, SUELO              
		inc AL                     
		call colocar_en_mapa       
        inc [banderin]
		ret
hay_cajaUp:
        ;revisar si hay algo arriba 
        dec AL
        push AX
		call obtener_de_mapa
		pop AX
       
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je PutcorrPosUp
      
        mov DL, CAJA           
		push AX
		call colocar_en_mapa       
		pop AX
        ;movemos jugador
        inc AL 
        mov [yJugador], AL         
        mov DL, JUGADOR           
		push AX
		call colocar_en_mapa       
		pop AX
        cmp [banderin], 00     
        jne pintar_objetivoUp
        ;;
		mov DL, SUELO               
		inc AL                     
		call colocar_en_mapa       
		ret
PutcorrPosUp:
		dec contadormalPuestas 
		cmp contadormalPuestas,0000
		je pasarSiguienteLevel
      
        mov DL, CORRECTPOS          
		push AX
		call colocar_en_mapa       
		pop AX
     
        inc AL 
        mov [yJugador], AL         
        mov DL, JUGADOR         
		push AX
		call colocar_en_mapa      
		pop AX
        cmp [banderin], 00     
        jne pintar_objetivoUp
        ;;
		mov DL, SUELO              
		inc AL                     
		call colocar_en_mapa       
		ret
hay_objetivoUp:
        inc [banderin]
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
pintar_objetivoUp:
        mov [banderin], 00      
        mov DL, OBJETIVO           
		inc AL                    
		call colocar_en_mapa        
		ret
        
mover_jugadorDown:
		mov AH, [xJugador]
		mov AL, [yJugador]
		inc AL
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_paredDown
        cmp DL, CAJA
		je hay_cajaDown
        cmp DL, OBJETIVO 
		je hay_objetivoDown
        cmp DL, CORRECTPOS 
		je hay_CORRECTPOSDown
		mov [yJugador], AL
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
        cmp [banderin], 00
        jne pintar_objetivoDown
        ;;
		mov DL, SUELO
		dec AL
		call colocar_en_mapa
		ret
hay_paredDown:
		ret
hay_CORRECTPOSDown:
		push AX
		printString salirPausa 
		inc contadormalPuestas
		pop AX
       
        inc AL
        push AX
		call obtener_de_mapa
		pop AX
        ;si lo hay ret
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je PutcorrPosDown
        
        mov DL, CAJA             
		push AX
		call colocar_en_mapa     
		pop AX
        ;movemos jugador
        dec AL 
        mov [yJugador], AL         
        mov DL, JUGADOR             
		push AX
		call colocar_en_mapa       
		pop AX
        ;;
        cmp [banderin], 00    
        jne pintar_objetivoDown
        ;;
        mov DL, SUELO              
		dec AL                     
		call colocar_en_mapa       
		inc [banderin]
        ret
hay_cajaDown:
      
        inc AL
        push AX
		call obtener_de_mapa
		pop AX
   
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je PutcorrPosDown
       
        mov DL, CAJA       
		push AX
		call colocar_en_mapa       
		pop AX
     
        dec AL 
        mov [yJugador], AL         
        mov DL, JUGADOR            
		push AX
		call colocar_en_mapa       
		pop AX
        ;;
        cmp [banderin], 00     
        jne pintar_objetivoDown
        ;;
        mov DL, SUELO              
		dec AL                   
		call colocar_en_mapa       
		ret
PutcorrPosDown:
		dec contadormalPuestas
		cmp contadormalPuestas,0000
		je pasarSiguienteLevel

        mov DL, CORRECTPOS           
		push AX
		call colocar_en_mapa        
		pop AX
        ;movemos jugador
        dec AL 
        mov [yJugador], AL         
        mov DL, JUGADOR            
		push AX
		call colocar_en_mapa      
		pop AX
        ;;
        cmp [banderin], 00     
        jne pintar_objetivoDown
        ;;
        mov DL, SUELO              
		dec AL                      
		call colocar_en_mapa       
		ret
hay_objetivoDown:
        inc [banderin]
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
pintar_objetivoDown:
        mov [banderin], 00     
        mov DL, OBJETIVO           
		dec AL                     
		call colocar_en_mapa         
		ret
mover_jugadorLeft:
		mov AH, [xJugador]
		mov AL, [yJugador]
		dec AH
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_paredLeft
        cmp DL, CAJA
		je hay_cajaLeft
        cmp DL, OBJETIVO
        je hay_objetivoLeft
        cmp DL, CORRECTPOS
        je hay_CORRECTPOSLeft
		mov [xJugador], AH
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
        cmp [banderin], 00
        jne pintar_objetivoLeft
        ;;
		mov DL, SUELO
		inc AH
		call colocar_en_mapa
		ret
hay_paredLeft:
		ret
hay_CORRECTPOSLeft:

		inc contadormalPuestas

        dec AH
        push AX
		call obtener_de_mapa
		pop AX

        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO 
		je ponerCorrPOSLeft
   
        mov DL, CAJA          
		push AX
		call colocar_en_mapa     
		pop AX
        ;movemos jugador
        inc AH 
        mov [xJugador], AH        
        mov DL, JUGADOR           
		push AX
		call colocar_en_mapa      
		pop AX
        ;;
        cmp [banderin], 00    
        jne pintar_objetivoLeft
        ;;
        mov DL, SUELO             
		inc AH                      
		call colocar_en_mapa       
        inc [banderin]
		ret
hay_cajaLeft:

        dec AH
        push AX
		call obtener_de_mapa
		pop AX
   
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO 
		je ponerCorrPOSLeft
      
        mov DL, CAJA          
		push AX
		call colocar_en_mapa      
		pop AX

        inc AH 
        mov [xJugador], AH        
        mov DL, JUGADOR          
		push AX
		call colocar_en_mapa        
		pop AX
        ;;
        cmp [banderin], 00      
        jne pintar_objetivoLeft
        ;;
        mov DL, SUELO               
		inc AH                     
		call colocar_en_mapa        
		ret
ponerCorrPOSLeft:
		dec contadormalPuestas
		cmp contadormalPuestas,0000
		je pasarSiguienteLevel
        mov DL, CORRECTPOS           
		push AX
		call colocar_en_mapa      
		pop AX

        inc AH 
        mov [xJugador], AH         
        mov DL, JUGADOR             
		push AX
		call colocar_en_mapa       
		pop AX
        ;;
        cmp [banderin], 00      
        jne pintar_objetivoLeft
        ;;
        mov DL, SUELO               
		inc AH                     
		call colocar_en_mapa        
		ret
hay_objetivoLeft:
        inc [banderin]
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
pintar_objetivoLeft:
        mov [banderin], 00      
        mov DL, OBJETIVO           
		inc AH                     
		call colocar_en_mapa       
		ret
mover_jugadorRight:
		mov AH, [xJugador]
		mov AL, [yJugador]
		inc AH
		push AX
		call obtener_de_mapa
		pop AX
		;; DL <- elemento en mapa
		cmp DL, PARED
		je hay_paredRight
        cmp DL, CAJA
		je hay_cajaRight
        cmp DL, OBJETIVO
        je hay_objetivoRight
        cmp DL, CORRECTPOS
        je hay_CORRECTPOSRight
		mov [xJugador], AH
		;;
		mov DL, JUGADOR
		push AX
		call colocar_en_mapa
		pop AX
		;;
        cmp [banderin], 00
        jne pintar_objetivoRight
        ;;
		mov DL, SUELO
		dec AH
		call colocar_en_mapa
		ret
hay_paredRight:
		ret
hay_CORRECTPOSRight:

		inc contadormalPuestas
      
        inc AH
        push AX
		call obtener_de_mapa
		pop AX
      
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je ponerCorrPOSRight
      
        mov DL, CAJA           
		push AX
		call colocar_en_mapa       
		pop AX

        dec AH 
        mov [xJugador], AH         
        mov DL, JUGADOR            
		push AX
		call colocar_en_mapa      
		pop AX
        ;;
        cmp [banderin], 00      
        jne pintar_objetivoRight
        ;;
        mov DL, SUELO               
		dec AH                     
		call colocar_en_mapa        
        inc [banderin]
		ret
hay_cajaRight:
       
        inc AH
        push AX
		call obtener_de_mapa
		pop AX
      
        cmp DL, PARED 
		je hay_paredUp
        cmp DL, CAJA 
		je hay_paredUp
        cmp DL, OBJETIVO
        je ponerCorrPOSRight
      
        mov DL, CAJA            
		push AX
		call colocar_en_mapa      
		pop AX
    
        dec AH 
        mov [xJugador], AH         
        mov DL, JUGADOR            
		push AX
		call colocar_en_mapa     
		pop AX
        ;;
        cmp [banderin], 00    
        jne pintar_objetivoRight
        ;;
        mov DL, SUELO               
		dec AH                      
		call colocar_en_mapa      
		ret
ponerCorrPOSRight:
		dec contadormalPuestas
		cmp contadormalPuestas,0000
		je pasarSiguienteLevel


        mov DL, CORRECTPOS           
		push AX
		call colocar_en_mapa        
		pop AX
      
        dec AH 
        mov [xJugador], AH         
        mov DL, JUGADOR            
		push AX
		call colocar_en_mapa       
		pop AX
        ;;
        cmp [banderin], 00     
        jne pintar_objetivoRight
        ;;
        mov DL, SUELO              
		dec AH                      
		call colocar_en_mapa       
		ret
hay_objetivoRight:
        inc [banderin]
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
pintar_objetivoRight:
        mov [banderin], 00      
        mov DL, OBJETIVO           
		dec AH                    
		call colocar_en_mapa       
		ret
fin_entrada_juego:
		ret


putPause:
	call menu_pause
	

pauseoption:
	mov AL, [opcion]
	cmp AL, 0
	je ciclo_juego
	cmp AL, 1
	je displayPrincipalMenu


menu_pause:
		call clear_pantalla
		mov AL, 0
		mov [opcion], AL      ;; reinicio de la variable de salida
		mov AL, 2
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
		mov DX, offset reaundarPausa
		mov AH, 09
		int 21
		pop DX
		;;
		;;;; REAUNUDAR
		add DH, 02
		mov BH, 00
		mov AH, 02
		int 10
		push DX
		mov DX, offset salirPausa
		mov AH, 09
		int 21
		pop DX
		;;
		

		;;;;
		call pintar_flecha
		;;;;
		;; LEER TECLA
		;;;;
entrada_menu_pause:
		mov AH, 00
		int 16
		cmp AH, 48
		je restar_opcion_menu_pause
		cmp AH, 50
		je sumar_opcion_menu_pause
		cmp AH, 3b  ;; le doy F1
		je fin_menu_pause
		jmp entrada_menu_pause
restar_opcion_menu_pause:
		mov AL, [opcion]
		dec AL
		cmp AL, 0ff
		je volver_a_ceroPause
		mov [opcion], AL
		jmp mover_flecha_menu_pause
sumar_opcion_menu_pause:
		mov AL, [opcion]
		mov AH, [maximo]
		inc AL
		cmp AL, AH
		je volver_a_maximoPause
		mov [opcion], AL
		jmp mover_flecha_menu_pause
volver_a_ceroPause:
		mov AL, 0
		mov [opcion], AL
		jmp mover_flecha_menu_pause
volver_a_maximoPause:
		mov AL, [maximo]
		dec AL
		mov [opcion], AL
		jmp mover_flecha_menu_pause
mover_flecha_menu_pause:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		mov AX, 50
		mov BX, 28
		mov CL, [opcion]
ciclo_ubicar_flecha_menu_pause:
		cmp CL, 0
		je pintar_flecha_menu_pause
		dec CL
		add BX, 10
		jmp ciclo_ubicar_flecha_menu_pause
pintar_flecha_menu_pause:
		mov [xFlecha], AX
		mov [yFlecha], BX
		call pintar_flecha
		jmp entrada_menu_pause
		;;
fin_menu_pause:
	jmp pauseoption
		ret




;; siguiente_linea - extrae la siguiente línea del archivo referenciado por el handle en BX
;; ENTRADA:
;;    - BX: handle
;; SALIDA:
;;    - [linea]: contenido de la línea que se extrajo, finalizada en 00 (nul0)
;;    - DL: si el archivo llegó a su fin
;;    - DH: la cantidad de caracteres en la línea
siguiente_linea:
		mov SI, 0000
		mov DI, offset linea
		;;
ciclo_sig_linea:
		mov AH, 3f
		mov CX, 0001
		mov DX, DI
		int 21h
		cmp AX, 0000
		je fin_siguiente_linea
		mov AL, [DI]
		cmp AL, 0a
		je quitar_nl_y_fin
		inc SI
		inc DI
		jmp ciclo_sig_linea
quitar_nl_y_fin:
		mov AL, 00
		mov [DI], AL
		mov DX, SI
		mov DH, DL
		mov DL, 00    ;; no ha finalizado el archivo
		ret
fin_siguiente_linea:
		int 03
		mov AL, 00
		mov [DI], AL
		mov DX, SI
		mov DH, DL
		mov DL, 0ff   ;; ya finalizó el archivo
		ret


;; cadena_igual - verifica que dos cadenas sean iguales
;; ENTRADA:
;;    - SI: cadena 1, con su tamaño en el primer byte
;;    - DI: cadena 2
;; SALIDA:
;;    - DL: 0ff si son iguales, 00 si no lo son
cadena_igual:
		mov CH, 00
		mov CL, [SI]
		inc SI
ciclo_cadena_igual:
		mov AL, [SI]
		cmp AL, [DI]
		jne fin_cadena_igual
		inc SI
		inc DI
		loop ciclo_cadena_igual
cadenas_son_iguales:
		mov DL, 0ff
		ret
fin_cadena_igual:
		mov DL, 00
		ret


;; ignorar_espacios - ignora una sucesión de espacios
;; ENTRADA:
;;    - DI: offset de una cadena cuyo primer byte se supone es un espacio
;; ...
ignorar_espacios:
ciclo_ignorar:
		mov AL, [DI]
		cmp AL, 20
		je ignorar_caracter
		cmp AL, 0d
		je ignorar_caracter
		jmp fin_ignorar
ignorar_caracter:
		inc DI
		jmp ciclo_ignorar
fin_ignorar:
		ret


;; memset - memset
;; ENTRADA:
;;    - DI: offset del inicio de la cadena de bytes
;;    - CX: cantidad de bytes
;;    - AL: valor que se pondrá en cada byte
memset:
		push DI
ciclo_memset:
		mov [DI], AL
		inc DI
		loop ciclo_memset
		pop DI
		ret


;; leer_cadena_numerica - lee una cadena que debería estar compuesta solo de números
;; ENTRADA:
;;    - DI: offset del inicio de la cadena numérica
;; SALIDA:
;;    - [numero]: el contenido de la cadena numérica
leer_cadena_numerica:
		mov SI, DI
		;;
		mov DI, offset numero
		mov CX, 0005
		mov AL, 30
		call memset
		;;
		mov DI, SI
		mov CX, 0000
ciclo_ubicar_ultimo:
		mov AL, [DI]
		cmp AL, 30
		jb copiar_cadena_numerica
		cmp AL, 39
		ja copiar_cadena_numerica
		inc DI
		inc CX
		jmp ciclo_ubicar_ultimo
copiar_cadena_numerica:
		push DI   ;;   <----
		dec DI
		;;
		mov SI, offset numero
		add SI, 0004
ciclo_copiar_num:
		mov AL, [DI]
		mov [SI], AL
		dec DI
		dec SI
		loop ciclo_copiar_num
		pop DI
		ret

;; cadenaAnum
;; ENTRADA:
;;    DI -> dirección a una cadena numérica
;; SALIDA:
;;    AX -> número convertido
;;;;
cadenaAnum:
		mov AX, 0000    ; inicializar la salida
		mov CX, 0005    ; inicializar contador
		;;
seguir_convirtiendo:
		mov BL, [DI]
		cmp BL, 00
		je retorno_cadenaAnum
		sub BL, 30      ; BL es el valor numérico del caracter
		mov DX, 000a
		mul DX          ; AX * DX -> DX:AX
		mov BH, 00
		add AX, BX 
		inc DI          ; puntero en la cadena
		loop seguir_convirtiendo
retorno_cadenaAnum:
		ret


fin:
.EXIT
END
