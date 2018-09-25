;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		CONT		;UMA VARI�VEL AUXILIAR, PARA CONTAGENS 
		DISPLAY		;VARIAVEL USADA PARA RECEBER OS BITS DO SINAL
		DISPLAY_AUX	;VARIAVEL PARA CONVERTER OS BITS DO SINAL DE ENTRADA
				;PARA OS BITS EQUIVALENTE AO SEU N�MERO, POR EXEMPLO
				;A TECLA 1 EQUIVALE AOS BITS 0000000 DO SINAL
				;MAS SEU NUMERO EM BIN�RIO � 0000001
		
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

SUBROTINA1

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAIDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000011'	;DEFININDO O TEMPO EM 1:16
	MOVWF	OPTION_REG	;DEFINE OPCOES DE OPERACAO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPCOES DE INTERRUPCOES
	CALL 0X3FF
	MOVWF OSCCAL
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	;CORPO DA ROTINA PRINCIPAL.
	
	;UTILIZO AS PORTAS GP0,GP1,GP2,GP3,GP4 E GP5
	;GP0, GP1, GP2 E GP4 SERVEM PARA SETAR O DISPLAY
	;GP3 � MINHA ENTRADA DO SINAL
	;GP5 � UTILIZADO PARA SET O LED
	BTFSC	GPIO,GP3    ;FICO CONFERINDO SE CHEGOU ALGUM SINAL NA ENTRADA
	GOTO	MAIN	    ;SE N�O CHEGOU NADA FICO NESSE LOOP SEMPRE CONFERINDO
	MOVLW	.114	    ;SE ENTROU SET O TMR0 PARA INICIAR EM 114, POIS SE 
	MOVWF	TMR0	    ;ESTOUROU O TEMPO, QUER DIZER QUE CHEGOU UM START BIT
	BCF	INTCON, T0IF	;LIMPO O T0IF
START_BIT	
	BTFSS	GPIO,GP3    ;FICO CONFERINDO SE O SINAL ACABOU
	GOTO	START_BIT   ;SE N�O ACABOU, FICAR� NESSE LOOP AT� ACABAR
	BTFSS	INTCON,T0IF ;SE ACABOU, VEJO SE O TEMPO ESTOUROU, SE N�O ESTOUROU
	GOTO	MAIN	    ;� PORQUE N�O CHEGOU UM START BIT
	MOVLW	.6	    ;SE CHEGOU UM STARTBIT, UTILIZO O CONT COMO AUXILIAR
	MOVWF	CONT	    ;PARA LIMITAR OS BITS QUE VOU ARMAZENAR 
LOOP_1	
	BTFSC	GPIO,GP3    ;FICO CONFERINDO O SINAL AT� O SINAL CHEGAR
	GOTO	LOOP_1
	MOVLW	.187	    ;SE O SINAL CHEGOU, SET O TEMPO EM 187
	MOVWF	TMR0	    ;PARA VER SE O BIT � 0 OU 1
	BCF	INTCON,T0IF ;LIMPO O T0IF
TECLA_BIT	
	BTFSS	GPIO,GP3    ;CONFIRO AT� O SINAL ACABAR
	GOTO	TECLA_BIT
	MOVLW	.224	    ;SE ELE ACABAR, EU FA�O UMA COMPARA��O PARA VER
	SUBWF	TMR0	    ;SE O TEMPO FOI DE 600 OU 1200
	BTFSS	STATUS,C
	GOTO	BIT_0	    ;SE O SINAL FOR DE 600 SET O BIT EM 0
	GOTO    BIT_1	    ;SE O SINAL FOR DE 1200 SET O BIT EM 1
BIT_0
	BCF	DISPLAY,6   ;SET O BIT MAIS SIGNFICATIVO, E ROTACIONO PARA
	RRF	DISPLAY	    ;ELE IR AT� O MENOS SIGNIFICATIVO 
	GOTO	FORA
BIT_1
	BSF	DISPLAY,6   ;UTILIZO A MESMA ESTRAT�GIA PARA O BIT 1
	RRF	DISPLAY
	GOTO	FORA
FORA
	DECF	CONT,F	    ;CONFIRO SE JA PREENCHI TODOS OS BITS
	BTFSS	STATUS,Z    ;SE N�O, EU VOLTO PARA O LOOP_1 PARA COMPLETAR OS BITS
	GOTO	LOOP_1
	MOVFW	DISPLAY	    ;SE SIM, CONFIRO SE RECEBI UMA TECLA MENOR QUE 10
	MOVWF	DISPLAY_AUX ;SE SIM, EU COLOCO NO DISPLAY QUAL FOI A TECLA
	MOVLW	.10	    ;QUE FOI PRESSIONADA
	SUBWF	DISPLAY_AUX ;SE N�O, EU COLOCO O LED PARA ACENDER POR 100ms
	BTFSS	STATUS,C
	GOTO	SET_DISPLAY_1
	BSF	GPIO,GP0    ;APAGO O DISPLAY SET AS SAIDAS EM 1
	BSF	GPIO,GP1    
	BSF	GPIO,GP2
	BSF	GPIO,GP4
	MOVLW	.25
	MOVWF	CONT
	BSF	GPIO,GP5    ;LIGO O LED, FICO CONFERINDO SE ELE ATINGIU O TEMPO
LED			    ;UTILIZANDO UM CONTADOR DE 25, POIS DO JEITO QUE SETEI
	MOVLW	.6	    ;O TMR0 ELE N�O PASSAR� DE 4ms, 
	MOVWF	TMR0
	BCF	INTCON,T0IF
LOOP_2	
	BTFSS	INTCON,T0IF
	GOTO	LOOP_2	    
	DECF	CONT,F	    ;QUANDO O CONT CHEGAR A 0, � PQ ATINGIU O TEMPO 
	BTFSS	STATUS,Z    ;E POSSO DESLIGAR O LED
	GOTO	LED
	BCF	GPIO,GP5    ;DESLIGO O LED AP�S 100ms
	GOTO	MAIN	
SET_DISPLAY_1	
	MOVFW	DISPLAY	    
	MOVWF	DISPLAY_AUX ;CONFIRO SE O SINAL QUE CHEGOU FOI 0001001
	MOVLW	.9	    ;POIS ESSE SINAL EQUIVALE A TECLA 0
	SUBWF	DISPLAY_AUX ;SE FOR ISSO QUE CHEGOU, EU SET AS SAIDAS EM 0000
	BTFSS	STATUS,Z    ;PARA O DISPLAY MOSTRAR O NUMERO 0
	GOTO	SET_DISPLAY_2	;SE N�O FOI ESSE SINAL, EU VOU PARA O SET_DISPLAY_2
	BCF	GPIO,GP0
	BCF	GPIO,GP1
	BCF	GPIO,GP2
	BCF	GPIO,GP4
	GOTO	MAIN	    ;VOLTO PARA O INICIO
SET_DISPLAY_2
	MOVLW	.1	    ;SOMO O SINAL COM 1, PARA COLOCAR NO DISPLAY O VALOR 
	ADDWF	DISPLAY,F   ;CERTO DA TECLA
	BTFSS	DISPLAY,0   ;CONFIRO O BIT NA POSI��O 0, SE FOR 1 EU SETA O GP0 
	GOTO	CLEARGP0	   ;SE FOR 0, DOU UM CLEAR NO GP0
	GOTO	SETGP0	   ;E ESSA REGRA SERVE PARA OS BITS SEGUNITES
BIT1
	BTFSS	DISPLAY,1
	GOTO	CLEARGP1
	GOTO	SETGP1
BIT2
	BTFSS	DISPLAY,2
	GOTO	CLEARGP2
	GOTO	SETGP2
BIT3
	BTFSS	DISPLAY,3
	GOTO	CLEARGP4
	GOTO	SETGP4
	
;NESSA PARTE SET OU CLEAR OS GPIO, FORMANDO A SAIDA EQUIVALENTE AO NUMERO	
;SE O AUXILIAR ESTIVER 1001, AS SAIDAS GP0=1 GP1=0 GP2=0 GP4=1
SETGP0
	BSF	GPIO,GP0 
	GOTO	BIT1
CLEARGP0	
	BCF	GPIO,GP0
	GOTO	BIT1
SETGP1	
	BSF	GPIO,GP1
	GOTO	BIT2
CLEARGP1	
	BCF	GPIO,GP1
	GOTO	BIT2
SETGP2
	BSF	GPIO,GP2
	GOTO	BIT3
CLEARGP2
	BCF	GPIO,GP2
	GOTO	BIT3
SETGP4
	BSF	GPIO,GP4
	GOTO	MAIN 
CLEARGP4	
	BCF	GPIO,GP4
	GOTO	MAIN
	
	
	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
