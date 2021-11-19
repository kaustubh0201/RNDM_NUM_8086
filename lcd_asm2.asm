#make_bin#

DATA SEGMENT
    PORTA EQU 00H
    PORTB EQU 040H
    PORTC EQU 080H
    PORT_CON EQU 0C0H

    XPORTA EQU 02H
    XPORTB EQU 042H
    XPORTC EQU 082H
    XPORT_CON EQU 0C2H

    INITIAL_SEED DB DUP(0)
    
    M DB 0FFH
    A DB 094H
    C DB 026H
DATA ENDS

CODE SEGMENT

MOV AX,DATA
MOV DS, AX

ORG 0000H

JMP START

LCG_RNG:
    PUSH BP 
    MOV BP,SP
    SUB SP,2
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; initial seed
    MOV AH, 00H
    MOV AL, INITIAL_SEED

    MUL A
    ADD AL, C
    DIV M
    MOV AL, AH

    MOV INITIAL_SEED, AL

    POP DX 
    POP CX
    POP BX 
    POP AX
    
    MOV SP,BP
    POP BP
RET
  
CLEAR_LCD_DISPLAY:
  	PUSH BP 
    MOV BP,SP
    SUB SP,2 

    PUSH AX
    PUSH DX   
  	
  	MOV AL,00H         
  	MOV DX,PORTC
  	OUT DX,AL 

  	MOV DX, PORTB
  	MOV AX, 00H
  	OUT DX, AX
  
  	MOV DX, PORTA
  	MOV AX, 01H
  	OUT DX, AX
  
  	MOV AL,0FFH
  	MOV DX,PORTC
  	OUT DX,AL 
  
  	CALL MYDELAY

  	MOV AL,00H
  	MOV DX,PORTC
  	OUT DX,AL
  
  	MOV DX, PORTB
  	MOV AX, 01H
  	OUT DX, AX
  	
    POP DX
    POP AX
    MOV SP,BP
    POP BP 
  RET
  	
  	

MYDELAY:
    PUSH BP
    PUSH CX

    MOV BP,SP
    SUB SP,2

    MOV CX, 0FFH
    D: LOOP D


    MOV SP,BP
    POP CX
    POP BP
RET

EXT_DELAY:
    PUSH BP
    PUSH CX

    MOV BP,SP
    SUB SP,2

    MOV CX, 0FFFFH
    D1: LOOP D1


    MOV SP,BP
    POP CX
    POP BP
RET


PRINT_LCD:
    PUSH BP 
    MOV BP,SP
    SUB SP,2

    ; PUSHING GPRs
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; +4 because +2 for BP and +2 for IP
    MOV AL, [BP + 4]
    MOV DX, PORTA
    OUT DX, AL
    
    CALL MYDELAY

    MOV AL,0FFH
    MOV DX,PORTC
    OUT DX,AL 

    CALL MYDELAY 
           
    MOV AL,00H
    MOV DX,PORTC
    OUT DX,AL

    ;POPPING GPRS
    POP DX
    POP CX
    POP CX
    POP AX

    MOV SP,BP
    POP BP     
RET

MYPRINT:
    PUSH BP 
    MOV BP,SP
    SUB SP,2 
    ; PUSHING GPRs
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
        
    
    MOV AL, INITIAL_SEED
    MOV BL, 0AH;
    

    ;print subroutine here 
    UP:
        MOV DH, 00H;
        MOV AH, 00H;
        DIV BL;
        MOV BX, AX;  

        MOV DL, BH
        ADD DL, '0'

        PUSH DX
        CALL PRINT_LCD
        POP DX
        
        MOV AX, BX;
        MOV BX, 000AH;   

        CMP AL, 00H
        JNE UP
    
    CALL EXT_DELAY


    ;POPPING GPRS
    POP DX
    POP CX
    POP CX
    POP AX
  
    MOV SP,BP
    POP BP     
RET

START:
    MOV DX, PORT_CON
    MOV AL, 10000000B
    OUT DX, AL


    JMP XX
 
XX:  
    MOV AL,00H           ;command setting cursor
    MOV DX,PORTC
    OUT DX,AL    
    MOV AL, 0EH 
    MOV DX, PORTA
    OUT DX,AL

    CALL MYDELAY

    MOV AL,0FFH
    MOV DX,PORTC
    OUT DX,AL 
    CALL MYDELAY

    MOV AL,00H           ;command setting 8 bit mode
    MOV DX,PORTC
    OUT DX,AL    
    MOV AL, 038H 
    MOV DX, PORTA
    OUT DX,AL

    CALL MYDELAY

    MOV AL,0FFH
    MOV DX,PORTC
    OUT DX,AL 
    CALL MYDELAY
             
    MOV AL,00H           ;command setting 8 bit mode
    MOV DX,PORTC
    OUT DX,AL                              
    MOV AL,0FH           ;command setting 8 bit mode
    MOV DX,PORTB
    OUT DX,AL  
 
    ; LCD PROGRAM ENDS
 
    MOV DX, XPORT_CON
    MOV AL, 10010000B
    OUT DX, AL

    MOV DX, XPORTB
    MOV AL, 01H
    OUT DX, AL
    
    CALL MYDELAY

    ; read
    MOV DX, XPORTA
    IN AL, DX

    
    CALL MYDELAY
    MOV INITIAL_SEED, AL
    
    MOV DX, XPORTC;
    OUT DX, AL;
   
    MOV DX, XPORTB
    MOV AL, 00H
    OUT DX, AL

XY:
    CALL LCG_RNG
  
    CALL MYDELAY

    CALL MYPRINT

    CALL CLEAR_LCD_DISPLAY

    CALL MYDELAY

    MOV DX, XPORTB
    MOV AL, 00000000B
    OUT DX,AL

    CALL MYDELAY
 
    MOV DX, XPORTB
    MOV AL, 00000001B
    OUT DX,AL
 
    CALL MYDELAY   

    JMP XY  

CODE ENDS
END