; SLL.asm 0.77a
;
;   System Link Layer (Code)
;
;==============================================================================
SCANFC equ 1
;==============================================================================


public _temp_buf_sprintf
xdataseg	segment	xdata
	rseg	xdataseg
_temp_buf_sprintf: ds 100

	xseg	at	0fe00h
Interface: ds	100h

;============================================================================
;  Rotinas de baixo nivel de acesso ao display endereços em xdata
CODETEC     equ     0xfe00    // Código da tecla pressionada
FBUFFER     equ     0xff00    // 128 para o setor lido ou escrito
GCOR        equ     0xff80    ;cor do pixel	  N,R,G,B ;
BGCOR       equ     0xff84    ;cor do fundo do caracter	  N,R,G,B ;
CARCOR      equ     0xff88   ;cor do frente do caracter	   N,R,G,B ;
GRADP       equ     0xff8C   ;pointer da memória grafica	  N,R,G,B ;
TXADP       equ     0xff90   ;pointer da memória de texto	   N,R,G,B ;
WRGRCOM     equ     0xff94   ;Comando de escrita no grafico
RDGRCOM     equ     0xff98   ;Leitura do grafico
WRTXCOM     equ     0xff9C   ;Comando de escrita no texto Joga caracter ascii com incremento do ADP
RDTXCOM     equ     0xffA0   ;Leitura no texto 
RDTXICOM    equ     0xffA4   ;Leitura no texto com incremento do ADP
RDGRICOM    equ     0xffA8   ;Leitura do grafico com incremento do ADP
WRGRPFIXCOM equ     0xffAC  ;Escrita na memoria gráfica usando paleta fixa
GRDATARD    equ     0xffB0  ; R,G,B lido da memoria gráfica pelo comando RDGRICOM ou RDGRCOM
SELJOIN     equ     0xffB4  ; Seleciona XOR=0 AND=1 OR=2
GRTXMODE    equ     0xffb4    // Seleciona XOR=0 OR=1 AND=2
GRPIXMODE   equ     0xffb5    // Seleciona como o pixel vai ser atulizado, O=sem operação, 1=OR com antigo , 2=AND
GRPLNSEL    equ     0xffb7   ;Seleciona o plano grafico atual (BACKPLN ou FIRSTPLN)
;============================================================================


public	_gotoxy	   ; void gotoxy(char x,char y)    R7, R5
public	_printchar
public	_prints
public    _paintscr
public    _paintscr2
public	_settxADP
public	_setgrADP
public	_clrscr
public    _function_sys
public    _printbmp
public    _plotxy
public    _pplotxy
public    _moveto
public    _lineto
public    _drawcircle
public    _drawdiscus
public    _drawcirclex
public    _drawdiscusx
public    _version
public    _xendian16
public    _xendian32
public    _decodebmp
public    Copybackplane
public    _CopyInterPlane
public    _getbmpinfo
public     _CopyRect
public	_CopyMatrix
public	Unlook
public	_CopyRectX
public	_scrollg
public	_scroll
public	_putchar
public	_getkey
public	kbhit
public	DXInit
public	DXShutdown
public 	DXCopyBackPlane
public	_DXCopyRectX
public	_DXCopyMatrix
public	_DXCopyRect
public    _DXPrintBmp
public	VgaTable
public	_BmpToMatrix
public	_drawrecta
public	_rdkeyboard
public	_mplotxy
public	_btow 
public	_PtInRect
public	_vkeydown 
public	_BmpRotateToMatrix
public	_RotateBmp
public	_searchdata
public	VMOff
public	_Surfaces
public  _PaintPlane
public	_strtoscr
public	_flush

;public	?_searchdata?BYTE


SCLK	equ	P3.3	; INT1 CLOCK DO TECLADO 
SDATA	equ	P3.4      ; DATA DO ELCADO

;?DT?_searchdata?sll segment data
;?PR?_searchdata?sll segment code

;	rseg	?DT?_searchdata?sll
;?_searchdata?BYTE:	ds	6

;	rseg	?PR?_searchdata?sll
;_searchdata:
;	jmp	_searchdata_entry
		
          cseg      at 0fe00h
startsll:
; ******************************************************
; posiciona ADP na janela de texto na posição calculada
; a partir das cordenadas x y, ADP = Y * 30 + X + 1920  
; void gotoxy(char x,char y)    R7, R5
; ******************************************************
_gotoxy:
	mov	a,r5		; Y * 30
	mov	b,#30		; 30 colunas
	mul	ab
	add	a,r7                ;  
	xch	a,b
	addc	a,#0		; Passa p carry  A:B contem endereço relativo
	xch	a,b                 ; Y * 40 + X
	add	a,#low(0)	; Soma mais o endereço da memoria de caracteres
	xch	a,b
	addc	a,#high(0)	; A:B contem agora o endereço real da memo de carac.
	mov	r6,a		; R6 pega o High
	mov	r7,b		; R7 pega o Low				
	ljmp	_settxadp		; Seta posição
;----------------------------------------------------------
; Determina a posição do ADP na memória de 
; vídeo void setADP(int)  R6:R7
;----------------------------------------------------------
_setgradp:
          mov       dptr,#GRADP
          mov       a,r6
          movx      @dptr,a
          inc       dptr
          mov       a,r7
          movx      @dptr,a
          ret 
;----------------------------------------------------------
; Determina a posição do ADP na memória de 
; vídeo void setADP(int)  R6:R7
;----------------------------------------------------------
_settxadp:
          mov       dptr,#TXADP
          mov       a,r6
          movx      @dptr,a
          inc       dptr
          mov       a,r7
          movx      @dptr,a
          ret 
;----------------------------------------------------------
; Pinta a tela gráfica com um padrão
; void paintscr(BYTE r,BYTE g,BYTE b)  R7 R5 R3
;----------------------------------------------------------
_paintscr2:
	jmp	_paintscr

;----------------------------------------------------------
; void _clrscr(BYTE r,BYTE g,BYTE b)
; Limpa a tela de texto
;----------------------------------------------------------

_clrscr:
          mov       dptr,#BGCOR+1
          mov       a,r7
          movx      @dptr,a
          inc       dptr
          mov       a,r5
          movx      @dptr,a
          inc       dptr
          mov       a,r3
          movx      @dptr,a

          mov       dptr,#TXADP
          mov       a,#0
          movx      @dptr,a
          inc       dptr
          movx      @dptr,a

          mov       dptr,#WRTXCOM
          mov       r7,a
          mov       r6,a
clrloop2:
          mov	a,#0x20 // espaço
          movx      @dptr,a
          inc       r7
          mov       a,r7
          jnz        testa2
          inc       r6
testa2:	cjne	r7,#low(480),clrloop2
	cjne	r6,#high(480),clrloop2
          mov       a,#0
	mov	r6,a		; R6 pega o High
	mov	r7,a		; R7 pega o Low				
	ljmp	_settxadp		; Seta posição

;--------------------------------------------------------
; Envia uma string a posição de memoria definida 
; pelo ADP "Imprime uma frase na tela de texto" 
; void prints(char *) r3:r2:r1
;----------------------------------------------------------
_prints:
	mov	dpl,r1
	mov	dph,r2
	
prints0F:	lcall	getdatap	
	jz	printsxF		; achou zero fim
          push      dpl
          push      dph
	mov	r7,a
	lcall	_printchar
          pop       dph
          pop       dpl
	inc	dptr
	inc	r1
	sjmp	prints0F	
printsxF:
	ret
;---------------------------------------------------------
; Imprime um caracter na posição ADP	 expande 0a para 0a 0d
; void printchar(char);
; char putchar(char)
;---------------------------------------------------------
_putchar:
_printchar:
          mov       a,r7
          cjne	a,#0ah,Nlinefeed          
	lcall	Nlinefeed
	mov	a,#0dh	
Nlinefeed:
          mov       dptr,#WRTXCOM
          movx      @dptr,a
          ret
;-----------------------------------------------------------
; Ler um caracter do teclado usando interface de hardware em xdata
;-----------------------------------------------------------
_getkey: 	mov	dptr,#CODETEC
lgetkey:	movx	a,@dptr
	jnb	acc.7,lgetkey
	anl	a,#7fh
	movx	@dptr,a
	inc	dptr
	movx	a,@dptr
	mov	r7,a
	ret

IF SCANFC == 1
extrn 	bit(?C?CHARLOADED)
ENDIF

_flush:
IF SCANFC == 1

          clr	?C?CHARLOADED
ENDIF
	ret

;------------------------------------------------------------
; Teste tecla disponivel
;------------------------------------------------------------
kbhit:  	mov	dptr,#CODETEC
	movx	a,@dptr
	mov	c,acc.7	  ; se bit 7 de acc = 1 tem tecla
	ret
	
;************************************************************
;
;************************************************************
_version:	mov	r0,#0
	mov	dptr,#verstr

versprox:	mov	a,r0
	movc	a,@a+dptr
	push	dpl
	push	dph

	mov	dpl,r1
	mov	dph,r2	

	CJNE     	r3,#0x01,vers0
	movx	@dptr,a           ; Considera xdata *
	jmp	vers1

vers0:	CJNE     	r3,#0x00,vers3
	mov	@r1,a	        ; Considera idata/data *
vers1:	inc	r1
	xch	a,r1
	jnz	vers2
	inc	r2
vers2:	inc	r0
	pop	dph
	pop	dpl
	xch	a,r1
	jz	versfim
	jmp	versprox
vers3:	mov	r1,#0
	jmp	vers2
versfim:	ret

;----------------------------------------------------------
;ver0:	lcall	getdatap	
;	jz	ver1		; achou zero fim
;          inc	r1
;	jnz	_version
;	inc	r2
;	jmp	_version
;ver1:     ret
;---------------------------------------------------------
; permuta entre big e litter endian     r4:r5:r6:r7
;---------------------------------------------------------
_xendian16: 
          xch       a,r6
          xch       a,r7
          xch       a,r6
          ret
_xendian32: 
          xch       a,r4
          xch       a,r7
          xch       a,r4
          xch       a,r5
          xch       a,r6
          xch       a,r5
          ret
;************************************************************
; Retorna com a valor apontado pelo pointer uso interno    
;************************************************************
getdatap: CJNE     	R3,#0xFF,getdatap1
	clr	a
	movc	a,@a+dptr         ; Considera Code *
	ret
getdatap1:CJNE     	R3,#0x01,getdatap0 
	movx	a,@dptr           ; Considera xdata *
	ret
getdatap0:CJNE     	R3,#0x00,getdatap2 
	mov	a,@r1	        ; Considera idata *
	ret
getdatap2:movx	a,@r1
	ret	
;----------------------------------------------------------
; Ler teclado   r3:r2:r1  poteiro para salvar tecla c = 1 tem tecla
;----------------------------------------------------------
_rdkeyboard:  
	lcall	kbhit
          jnc	kb_fimx
	lcall	_getkey
	mov	dpl,r1
	mov	dph,r2
	mov	a,r7
	cjne	r3,#01h,difxdata
	movx	@dptr,a
	jmp	kb_fink
difxdata:
	cjne	r3,#00h,difdata
	mov	@r1,a
	jmp	kb_fink
difdata:	clr	c
	jmp	kb_fimx
kb_fink:	setb	c
kb_fimx:	ret
;------------------------------------------------
;  WORD:r6:r7 btow(BYTE y:r7,BYTE x:r5)
;------------------------------------------------
_btow: 	mov	a,r5
	mov	r6,a
	ret
;---------------------------------------------------------    		
; void          PaintPlane (char plane,char cor);
;---------------------------------------------------------    		
_PaintPlane:
	mov	a,r7
	mov	r6,a
	mov	dptr,#GRPLNSEL
	movx	@dptr,a
	mov	a,r5
	mov	r7,a
	mov	r3,a
	call	_paintscr
	mov	a,r6
	mov	dptr,#GRPLNSEL
	movx	@dptr,a
	ret
;----------------------------------------------------------
_plotxy:  mov        a,#0
          acall      CALLVM
          ret

_printbmp:mov       a,#1
          acall      CALLVM
          ret
_moveto:
          mov       a,#2
          acall     CALLVM
          ret
_lineto:
          mov       a,#3
          acall     CALLVM
          ret
_drawcircle:
          mov       a,#4
          acall     CALLVM
          ret
_drawdiscus:
          mov       a,#5
          acall     CALLVM
          ret
_decodebmp:
          mov       a,#6
          acall     CALLVM
          ret

Copybackplane:
          mov       a,#7
          acall     CALLVM
          ret

_getbmpinfo:
          mov       a,#8
          acall     CALLVM
          ret

_CopyRect:                  ;CopyRect(PRECT); 
          mov       a,#9
          acall     CALLVM
          ret

_drawcirclex:
          mov       a,#10
          acall     CALLVM
          ret

_drawdiscusx:
          mov       a,#11
          acall     CALLVM
          ret

_CopyMatrix:
          mov       a,#12
          acall     CALLVM
          ret
Unlook:
          mov       a,#13
          acall     CALLVM
          ret

_CopyRectX:
          mov       a,#14
          acall     CALLVM
          ret

_scroll:
          mov       a,#15
          acall     CALLVM
          ret

_pplotxy: mov       a,#16
          acall     CALLVM
          ret

_paintscr:
          mov       a,#17
          acall     CALLVM
          ret

DXInit:
          mov       a,#18
          acall     CALLVM
          ret

DXShutdown:
          mov       a,#19
          acall     CALLVM
          ret

DXCopyBackPlane:
          mov       a,#20
          acall     CALLVM
          ret

_DXCopyRectX:
          mov       a,#21
          acall     CALLVM
          ret

_DXCopyMatrix:
          mov       a,#22
          acall     CALLVM
          ret

_DXCopyRect:
          mov       a,#23
          acall     CALLVM
          ret

_DXPrintBmp:
          mov       a,#24
          acall     CALLVM
          ret

_BmpToMatrix:
          mov       a,#25
          acall     CALLVM
          ret

_drawrecta:
          mov       a,#26
          acall     CALLVM
          ret

_scrollg:
          mov       a,#27
          acall     CALLVM
          ret

_mplotxy:
          mov       a,#28
          acall     CALLVM
          ret

_PtInRect: ; bit PtInRect(BYTE x, BYTE y,PRECT);
          mov       a,#29
          acall     CALLVM
          ret

_vkeydown: ;bit           vkeydown(BYTE cod); 
          mov       a,#30
          acall     CALLVM
          ret

_BmpRotateToMatrix: ;BmpRotateToMatrix(MATRIX xdata * mvetor, int ang, char * nomebmp);
          mov       a,#31
          acall     CALLVM
          ret

_RotateBmp:  ;RotateBmp(PSROTATE prot);
          mov       a,#32
          acall     CALLVM
          ret

_searchdata:
          mov       a,#33
          acall     CALLVM
          ret

VMOff:
          mov       a,#34
          acall     CALLVM
          ret

_CopyInterPlane:
          mov       a,#35
          acall     CALLVM
          ret

_Surfaces:
          mov       a,#36
          acall     CALLVM
          ret

_strtoscr:
          mov       a,#37
          acall     CALLVM
          ret

_function_sys:
          mov       a,#38
          acall     CALLVM
          ret

verstr:	db	"0.77",0

          cseg      at 0xfffe
CALLVM:   ret

;------------------------------------------------------------------------------
;  This file is part of the C51 Compiler package
;  Copyright (c) 1988-2005 Keil Elektronik GmbH and Keil Software, Inc.
;  Version 8.01
;
;  *** <<< Use Configuration Wizard in Context Menu >>> ***
;------------------------------------------------------------------------------
;  STARTUP.A51:  This code is executed after processor reset.
;
;  To translate this file use A51 with the following invocation:
;
;     A51 STARTUP.A51
;
;  To link the modified STARTUP.OBJ file to your application use the following
;  Lx51 invocation:
;
;     Lx51 your object file list, STARTUP.OBJ  controls
;
;------------------------------------------------------------------------------
;
;  User-defined <h> Power-On Initialization of Memory
;
;  With the following EQU statements the initialization of memory
;  at processor reset can be defined:
;
; <o> IDATALEN: IDATA memory size <0x0-0x100>
;     <i> Note: The absolute start-address of IDATA memory is always 0
;     <i>       The IDATA space overlaps physically the DATA and BIT areas.
IDATALEN        EQU     100H
;
; <o> XDATASTART: XDATA memory start address <0x0-0xFFFF> 
;     <i> The absolute start address of XDATA memory
XDATASTART      EQU     100H     
;
; <o> XDATALEN: XDATA memory size <0x0-0xFFFF> 
;     <i> The length of XDATA memory in bytes.
XDATALEN        EQU     0FE00H      
;
; <o> PDATASTART: PDATA memory start address <0x0-0xFFFF> 
;     <i> The absolute start address of PDATA memory
PDATASTART      EQU     0H
;
; <o> PDATALEN: PDATA memory size <0x0-0xFF> 
;     <i> The length of PDATA memory in bytes.
PDATALEN        EQU     100H
;
;</h>
;------------------------------------------------------------------------------
;
;<h> Reentrant Stack Initialization
;
;  The following EQU statements define the stack pointer for reentrant
;  functions and initialized it:
;
; <h> Stack Space for reentrant functions in the SMALL model.
;  <q> IBPSTACK: Enable SMALL model reentrant stack
;     <i> Stack space for reentrant functions in the SMALL model.
IBPSTACK        EQU     0       ; set to 1 if small reentrant is used.
;  <o> IBPSTACKTOP: End address of SMALL model stack <0x0-0xFF>
;     <i> Set the top of the stack to the highest location.
IBPSTACKTOP     EQU     0xFF +1     ; default 0FFH+1  
; </h>
;
; <h> Stack Space for reentrant functions in the LARGE model.      
;  <q> XBPSTACK: Enable LARGE model reentrant stack
;     <i> Stack space for reentrant functions in the LARGE model.
XBPSTACK        EQU     0       ; set to 1 if large reentrant is used.
;  <o> XBPSTACKTOP: End address of LARGE model stack <0x0-0xFFFF>
;     <i> Set the top of the stack to the highest location.
XBPSTACKTOP     EQU     0xFFFF +1   ; default 0FFFFH+1 
; </h>
;
; <h> Stack Space for reentrant functions in the COMPACT model.    
;  <q> PBPSTACK: Enable COMPACT model reentrant stack
;     <i> Stack space for reentrant functions in the COMPACT model.
PBPSTACK        EQU     0       ; set to 1 if compact reentrant is used.
;
;   <o> PBPSTACKTOP: End address of COMPACT model stack <0x0-0xFFFF>
;     <i> Set the top of the stack to the highest location.
PBPSTACKTOP     EQU     0xFF +1     ; default 0FFH+1  
; </h>
;</h>
;------------------------------------------------------------------------------
;
;  Memory Page for Using the Compact Model with 64 KByte xdata RAM
;  <e>Compact Model Page Definition
;
;  <i>Define the XDATA page used for PDATA variables. 
;  <i>PPAGE must conform with the PPAGE set in the linker invocation.
;
; Enable pdata memory page initalization
PPAGEENABLE     EQU     0       ; set to 1 if pdata object are used.
;
; <o> PPAGE number <0x0-0xFF> 
; <i> uppermost 256-byte address of the page used for PDATA variables.
PPAGE           EQU     0
;
; <o> SFR address which supplies uppermost address byte <0x0-0xFF> 
; <i> most 8051 variants use P2 as uppermost address byte
PPAGE_SFR       DATA    0A0H
;
; </e>
;------------------------------------------------------------------------------


                NAME    ?C_STARTUP

                EXTRN CODE (?C_START)
                PUBLIC  ?C_STARTUP

?C_C51STARTUP   SEGMENT   CODE
?STACK          SEGMENT   IDATA

                RSEG    ?STACK
                DS      1


                CSEG    AT      0
?C_STARTUP:     LJMP    STARTUP1

                RSEG    ?C_C51STARTUP

STARTUP1:

IF IDATALEN <> 0
                MOV     R0,#IDATALEN - 1
                CLR     A
IDATALOOP:      MOV     @R0,A
                DJNZ    R0,IDATALOOP
ENDIF

IF XDATALEN <> 0
                MOV     DPTR,#XDATASTART
                MOV     R7,#LOW (XDATALEN)
  IF (LOW (XDATALEN)) <> 0
                MOV     R6,#(HIGH (XDATALEN)) +1
  ELSE
                MOV     R6,#HIGH (XDATALEN)
  ENDIF
                CLR     A
XDATALOOP:      MOVX    @DPTR,A
                INC     DPTR
                DJNZ    R7,XDATALOOP
                DJNZ    R6,XDATALOOP
ENDIF

IF PPAGEENABLE <> 0
                MOV     PPAGE_SFR,#PPAGE
ENDIF

IF PDATALEN <> 0
                MOV     R0,#LOW (PDATASTART)
                MOV     R7,#LOW (PDATALEN)
                CLR     A
PDATALOOP:      MOVX    @R0,A
                INC     R0
                DJNZ    R7,PDATALOOP
ENDIF

IF IBPSTACK <> 0
EXTRN DATA (?C_IBP)

                MOV     ?C_IBP,#LOW IBPSTACKTOP
ENDIF

IF XBPSTACK <> 0
EXTRN DATA (?C_XBP)

                MOV     ?C_XBP,#HIGH XBPSTACKTOP
                MOV     ?C_XBP+1,#LOW XBPSTACKTOP
ENDIF

IF PBPSTACK <> 0
EXTRN DATA (?C_PBP)
                MOV     ?C_PBP,#LOW PBPSTACKTOP
ENDIF

                MOV     SP,#?STACK-1
                LJMP    ?C_START
;**************************************************************
; Tabela da paleta de cores VGA  256 entradas RGB 24 bits
;**************************************************************
 	cseg	at 0xfb00
VgaTable:	db  0x00, 0x00, 0x00 ,  0x00, 0x00, 0xaa 
	db  0x00, 0xaa, 0x00 ,  0x00, 0xaa, 0xaa 
	db  0xaa, 0x00, 0x00 ,  0xaa, 0x00, 0xaa 
	db  0xaa, 0x55, 0x00 ,  0xaa, 0xaa, 0xaa 
	db  0x55, 0x55, 0x55 ,  0x55, 0x55, 0xff 
	db  0x55, 0xff, 0x55 ,  0x55, 0xff, 0xff 
	db  0xff, 0x55, 0x55 ,  0xff, 0x55, 0xff 
	db  0xff, 0xff, 0x55 ,  0xff, 0xff, 0xff 
/* Gray Scale Table */
	db  0x00, 0x00, 0x00 ,  0x14, 0x14, 0x14 
	db  0x20, 0x20, 0x20 ,  0x2c, 0x2c, 0x2c 
	db  0x38, 0x38, 0x38 ,  0x45, 0x45, 0x45 
	db  0x51, 0x51, 0x51 ,  0x61, 0x61, 0x61 
	db  0x71, 0x71, 0x71 ,  0x82, 0x82, 0x82 
	db  0x92, 0x92, 0x92 ,  0xa2, 0xa2, 0xa2 
	db  0xb6, 0xb6, 0xb6 ,  0xcb, 0xcb, 0xcb 
	db  0xe3, 0xe3, 0xe3 ,  0xff, 0xff, 0xff 
/* 24-color Table */
	db  0x00, 0x00, 0xff ,  0x41, 0x00, 0xff 
	db  0x7d, 0x00, 0xff ,  0xbe, 0x00, 0xff 
	db  0xff, 0x00, 0xff ,  0xff, 0x00, 0xbe 
	db  0xff, 0x00, 0x7d ,  0xff, 0x00, 0x41 
	db  0xff, 0x00, 0x00 ,  0xff, 0x41, 0x00 
	db  0xff, 0x7d, 0x00 ,  0xff, 0xbe, 0x00 
	db  0xff, 0xff, 0x00 ,  0xbe, 0xff, 0x00 
	db  0x7d, 0xff, 0x00 ,  0x41, 0xff, 0x00 
	db  0x00, 0xff, 0x00 ,  0x00, 0xff, 0x41 
	db  0x00, 0xff, 0x7d ,  0x00, 0xff, 0xbe 
	db  0x00, 0xff, 0xff ,  0x00, 0xbe, 0xff 
	db  0x00, 0x7d, 0xff ,  0x00, 0x41, 0xff 
	db  0x7d, 0x7d, 0xff ,  0x9e, 0x7d, 0xff 
	db  0xbe, 0x7d, 0xff ,  0xdf, 0x7d, 0xff 
	db  0xff, 0x7d, 0xff ,  0xff, 0x7d, 0xdf 
	db  0xff, 0x7d, 0xbe ,  0xff, 0x7d, 0x9e 
	db  0xff, 0x7d, 0x7d ,  0xff, 0x9e, 0x7d 
	db  0xff, 0xbe, 0x7d ,  0xff, 0xdf, 0x7d 
	db  0xff, 0xff, 0x7d ,  0xdf, 0xff, 0x7d 
	db  0xbe, 0xff, 0x7d ,  0x9e, 0xff, 0x7d 
	db  0x7d, 0xff, 0x7d ,  0x7d, 0xff, 0x9e 
	db  0x7d, 0xff, 0xbe ,  0x7d, 0xff, 0xdf 
	db  0x7d, 0xff, 0xff ,  0x7d, 0xdf, 0xff 
	db  0x7d, 0xbe, 0xff ,  0x7d, 0x9e, 0xff 
	db  0xb6, 0xb6, 0xff ,  0xc7, 0xb6, 0xff 
	db  0xdb, 0xb6, 0xff ,  0xeb, 0xb6, 0xff 
	db  0xff, 0xb6, 0xff ,  0xff, 0xb6, 0xeb 
	db  0xff, 0xb6, 0xdb ,  0xff, 0xb6, 0xc7 
	db  0xff, 0xb6, 0xb6 ,  0xff, 0xc7, 0xb6 
	db  0xff, 0xdb, 0xb6 ,  0xff, 0xeb, 0xb6 
	db  0xff, 0xff, 0xb6 ,  0xeb, 0xff, 0xb6 
	db  0xdb, 0xff, 0xb6 ,  0xc7, 0xff, 0xb6 
	db  0xb6, 0xdf, 0xb6 ,  0xb6, 0xff, 0xc7 
	db  0xb6, 0xff, 0xdb ,  0xb6, 0xff, 0xeb 
	db  0xb6, 0xff, 0xff ,  0xb6, 0xeb, 0xff 
	db  0xb6, 0xdb, 0xff ,  0xb6, 0xc7, 0xff 
	db  0x00, 0x00, 0x71 ,  0x1c, 0x00, 0x71 
	db  0x38, 0x00, 0x71 ,  0x55, 0x00, 0x71 
	db  0x71, 0x00, 0x71 ,  0x71, 0x00, 0x55 
	db  0x71, 0x00, 0x38 ,  0x71, 0x00, 0x1c 
	db  0x71, 0x00, 0x00 ,  0x71, 0x1c, 0x00 
	db  0x71, 0x38, 0x00 ,  0x71, 0x55, 0x00 
	db  0x71, 0x71, 0x00 ,  0x55, 0x71, 0x00 
	db  0x38, 0x71, 0x00 ,  0x1c, 0x71, 0x00 
	db  0x00, 0x71, 0x00 ,  0x00, 0x71, 0x1c 
	db  0x00, 0x71, 0x38 ,  0x00, 0x71, 0x55 
	db  0x00, 0x71, 0x71 ,  0x00, 0x55, 0x71 
	db  0x00, 0x38, 0x71 ,  0x00, 0x1c, 0x71 
	db  0x38, 0x38, 0x71 ,  0x45, 0x38, 0x71 
	db  0x55, 0x38, 0x71 ,  0x61, 0x38, 0x71 
	db  0x71, 0x38, 0x71 ,  0x71, 0x38, 0x61 
	db  0x71, 0x38, 0x55 ,  0x71, 0x38, 0x45 
	db  0x71, 0x38, 0x38 ,  0x71, 0x45, 0x38 
	db  0x71, 0x55, 0x38 ,  0x71, 0x61, 0x38 
	db  0x71, 0x71, 0x38 ,  0x61, 0x71, 0x38 
	db  0x55, 0x71, 0x38 ,  0x45, 0x71, 0x38 
	db  0x38, 0x71, 0x38 ,  0x38, 0x71, 0x45 
	db  0x38, 0x71, 0x55 ,  0x38, 0x71, 0x61 
	db  0x38, 0x71, 0x71 ,  0x38, 0x61, 0x71 
	db  0x38, 0x55, 0x71 ,  0x38, 0x45, 0x71 
	db  0x51, 0x51, 0x71 ,  0x59, 0x51, 0x71 
	db  0x61, 0x51, 0x71 ,  0x69, 0x51, 0x71 
	db  0x71, 0x51, 0x71 ,  0x71, 0x51, 0x69 
	db  0x71, 0x51, 0x61 ,  0x71, 0x51, 0x59 
	db  0x71, 0x51, 0x51 ,  0x71, 0x59, 0x51 
	db  0x71, 0x61, 0x51 ,  0x71, 0x69, 0x51 
	db  0x71, 0x71, 0x51 ,  0x69, 0x71, 0x51 
	db  0x61, 0x71, 0x51 ,  0x59, 0x71, 0x51 
	db  0x51, 0x71, 0x51 ,  0x51, 0x71, 0x59 
	db  0x51, 0x71, 0x61 ,  0x51, 0x71, 0x69 
	db  0x51, 0x71, 0x71 ,  0x51, 0x69, 0x71 
	db  0x51, 0x61, 0x71 ,  0x51, 0x59, 0x71 
	db  0x00, 0x00, 0x41 ,  0x10, 0x00, 0x41 
	db  0x20, 0x00, 0x41 ,  0x30, 0x00, 0x41 
	db  0x41, 0x00, 0x41 ,  0x41, 0x00, 0x30 
	db  0x41, 0x00, 0x20 ,  0x41, 0x00, 0x10 
	db  0x41, 0x00, 0x00 ,  0x41, 0x10, 0x00 
	db  0x41, 0x20, 0x00 ,  0x41, 0x30, 0x00 
	db  0x41, 0x41, 0x00 ,  0x30, 0x41, 0x00 
	db  0x20, 0x41, 0x00 ,  0x10, 0x41, 0x00 
	db  0x00, 0x41, 0x00 ,  0x00, 0x41, 0x10 
	db  0x00, 0x41, 0x20 ,  0x00, 0x41, 0x30 
	db  0x00, 0x41, 0x41 ,  0x00, 0x30, 0x41 
	db  0x00, 0x20, 0x41 ,  0x00, 0x10, 0x41 
	db  0x20, 0x20, 0x41 ,  0x28, 0x20, 0x41 
	db  0x30, 0x20, 0x41 ,  0x38, 0x20, 0x41 
	db  0x41, 0x20, 0x41 ,  0x41, 0x20, 0x38 
	db  0x41, 0x20, 0x30 ,  0x41, 0x20, 0x28 
	db  0x41, 0x20, 0x20 ,  0x41, 0x28, 0x20 
	db  0x41, 0x30, 0x20 ,  0x41, 0x38, 0x20 
	db  0x41, 0x41, 0x20 ,  0x38, 0x41, 0x20 
	db  0x30, 0x41, 0x20 ,  0x28, 0x41, 0x20 
	db  0x20, 0x41, 0x20 ,  0x20, 0x41, 0x28 
	db  0x20, 0x41, 0x30 ,  0x20, 0x41, 0x38 
	db  0x20, 0x41, 0x41 ,  0x20, 0x38, 0x41 
	db  0x20, 0x30, 0x41 ,  0x20, 0x28, 0x41 
	db  0x2c, 0x2c, 0x41 ,  0x30, 0x2c, 0x41 
	db  0x34, 0x2c, 0x41 ,  0x3c, 0x2c, 0x41 
	db  0x41, 0x2c, 0x41 ,  0x41, 0x2c, 0x3c 
	db  0x41, 0x2c, 0x34 ,  0x41, 0x2c, 0x30 
	db  0x41, 0x2c, 0x2c ,  0x41, 0x30, 0x2c 
	db  0x41, 0x34, 0x2c ,  0x41, 0x3c, 0x2c 
	db  0x41, 0x41, 0x2c ,  0x3c, 0x41, 0x2c 
	db  0x34, 0x41, 0x2c ,  0x30, 0x41, 0x2c 
	db  0x2c, 0x41, 0x2c ,  0x2c, 0x41, 0x30 
	db  0x2c, 0x41, 0x34 ,  0x2c, 0x41, 0x3c 
	db  0x2c, 0x41, 0x41 ,  0x2c, 0x3c, 0x41 
	db  0x2c, 0x34, 0x41 ,  0x2c, 0x30, 0x41 
	db  0x00, 0x00, 0x00 ,  0x00, 0x00, 0x00 
	db  0x00, 0x00, 0x00 ,  0x00, 0x00, 0x00 
	db  0x00, 0x00, 0x00 ,  0x00, 0x00, 0x00 
	db  0x00, 0x00, 0x00 ,  0x00, 0x00, 0x00 

	END




