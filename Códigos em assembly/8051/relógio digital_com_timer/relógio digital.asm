;Rel�gio digital com timer em assembly............. Jhonathas e Marcele
;Dia 20/09/2016

DSP0      	EQU       P2.4
DSP1      	EQU       P2.0
DSP2       	EQU       P2.1
DSP3       	EQU       P2.2
DSP4       	EQU       P2.3
DSP5       	EQU       P2.5
DSP6       	EQU       P2.6
DSP7       	EQU       P2.7
CH1        	EQU       P3.0
CH2        	EQU       P3.1
CH3		EQU	P3.2
CH4	 	EQU	P3.3
CH5	 	EQU	P3.4		

	bseg
flg_1:	          dbit	1
f_hora:	          dbit	1
f_data:	          dbit	1
flg_s:	          dbit	1
flgcont:            dbit      1


	dseg      at 8   
COD0:      ds        1
COD1:      ds        1    
COD2:      ds        1                
COD3:      ds        1  
COD4:      ds        1 
COD5:      ds        1  
COD6:      ds        1  
COD7:      ds        1
 
SEG:       ds        1
MIN:       ds        1
HOR:       ds        1
DIA:       ds        1
MES:       ds        1
ANO:       ds        1 
cont:      ds        1
cont2:     ds        1

          iseg      at 80h     ;segmento de pilha
pilha:    ds        20

          cseg      at 0
inicio:   jmp       inicio2

          cseg      at 000bh         ; interrup��o timer 0
          MOV       TH0,#(256-250)   ; vou gerar 250Hz
          jmp       saidoaperto ; rotina de contagem

          cseg      at 001bh
          mov       TH1,#(256-156)   ; vou gerar 400HZ
                 
varredura:
          push      psw
          push      acc
           ; varredura dos display
           JNB DSP0, DISPLAYZ0	;IR PARA O DISPLAY0
           JNB DSP1, DISPLAYZ1	;IR PARA O DISPLAY1
           JNB DSP2, DISPLAYZ2	;IR PARA O DISPLAY2
           JNB DSP3, DISPLAYZ3	;IR PARA O DISPLAY3
           JNB DSP4, DISPLAYZ4	;IR PARA O DISPLAY4
           JNB DSP5, DISPLAYZ5	;IR PARA O DISPLAY5
           JNB DSP6, DISPLAYZ6	;IR PARA O DISPLAY6
           JNB DSP7, DISPLAYZ7	;IR PARA O DISPLAY7
          
DISPLAYZ0:
          		SETB DSP0		;DESLIGA DISPLAY0
          		MOV P0,COD1		;JOGA EM P0 O COD1
          		CLR DSP1		;LIGA DISPLAY1
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1

DISPLAYZ1:
          		SETB DSP1		;DESLIGA DISPLAY1
          		MOV P0,COD2		;JOGA EM P0 O COD2 
          		CLR DSP2		;LIGA DISPLAY2
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1

DISPLAYZ2:
          
          		SETB DSP2		;DESLIGA DISPLAY2
          		MOV P0,COD3		;JOGA EM P0 O COD3
          		CLR DSP3		;LIGA DISPLAY3
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1

DISPLAYZ3:
          		SETB DSP3		;DESLIGA DISPLAY3
          		MOV P0,COD4		;JOGA EM P0 O COD4
          		CLR DSP4		;LIGA DISPLAY4
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1

DISPLAYZ4:
         
          		SETB DSP4		;DESLIGA DISPLAY4
          		MOV P0,COD5		;JOGA EM P0 O COD5
          		CLR DSP5		;LIGA DISPLAY5
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1

DISPLAYZ5:
          		SETB DSP5		;DESLIGA DISPLAY5
          		MOV P0,COD6		;JOGA EM P0 O COD6
          		CLR DSP6		;LIGA DISPLAY6
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1
           
DISPLAYZ6:
          
          		SETB DSP6		;DESLIGA DISPLAY6
          		MOV P0,COD7		;JOGA EM P0 O COD7
          		CLR DSP7		;LIGA DISPLAY7
          		JMP ENCONTRO1	;PULA PARA O ENCONTRO1
DISPLAYZ7:
          		SETB DSP7		;DESLIGA DISPLAY7
          		MOV P0,COD0		;JOGA EM P0 O COD0
                		CLR DSP0		;LIGA DISPLAY0
                              jmp      encontro1
 inc       cont2
          mov       a,cont2
          cjne      a,#100,return
          mov       cont2,#0
          setb      flgcont
          reti
return:
          reti
Encontro1:

          pop       acc
          pop       psw
          reti
             
inicio2: 
          jb                  flgcont,continua
          jmp                 inicio2           
continua: 
          mov       sp,#pilha-1
          mov       TMOD,#00h 
          mov       TH0,#(256-250)       ; vou gerar 250Hz
          mov	TH1,#(256-156)
          setb      TR0
          setb      TR1
          mov       ie,#8Ah              ; habilita a interrup��o timer 0 e 1
conversao: 
	SETB      DSP0
          mov       seg,#0
          mov       min,#0
          mov       hor,#0
          mov       dia,#01
          mov       mes,#01
          mov       ano,#00
         
volta:
		  jnb		ch1,clrflg_1
		  jmp		tstch2

clrflg_1:
		  jnb		ch2,flg_semana_1 	;se a ch1 e ch2 =0, mostra o dia da semana
		  clr		flg_1
		  jmp		tstflg_1

flg_semana_1:
		  setb		flg_s
		  jb		flg_s,mostrad_sem

mostrad_sem:; DIA DA SEMANA IMPORTANTE!!!

		  mov		a,ano	; movo o ano para acumulador	
		  mov		b,#100	;movo 100 para 'b'
		  add 		a,b		;somo a+b
		  mov		r0,a	; valor de A= ano+100
		  mov		b,#4	;
		  div		ab
	            mov		r1,a	; valor de B= ano n�o bissexto	
	            mov     	a,ano
                      mov    	          b,#4
  	            div     	ab 
                      mov     	a,b 
	            jz		tstmes 	;ano bissexto? se sim, vai para teste do m�s, se n�o, segue normal
	            jmp		passo3

tstmes:	  
                      mov		a,mes
		  cjne		a,#2,menor
decr1:
		  dec		r1
		  jmp		passo3

menor:	  
                      jc		decr1
		  jmp		passo3

passo3:	  
                      mov		a,mes
		  mov		dptr,#tabela_1
		  movc		a,@a + dptr
		  mov		r2,a	;valor de C
		  mov		a,dia
		  dec		a	;valor de D= dia -1
	   	  add		a,r2	; D+C
		  add		a,r1	; B+C+D
		  add		a,r0	;A+B+C+D
		  mov		b,#7
		  div		ab
		  mov		a,b

segunda:
	cjne	a,#0,terca
	mov		cod7,#0FFh	;segunda-feira
	mov		cod6,#92h
	mov		cod5,#86h
	mov		cod4,#0C2h
	mov		cod3,#0c1h
	mov		cod2,#0ABh
	mov		cod1,#0A1h
	mov		cod0,#88h

terca:	
	cjne	a,#1,quarta
	mov		cod7,#0FFh	;ter�a-feira
	mov		cod6,#0FFh
	mov		cod5,#0FFh
	mov		cod4,#87h
	mov		cod3,#86h
	mov		cod2,#0AFh
	mov		cod1,#0C6h
	mov		cod0,#88h

quarta:
 	cjne	a,#2,quinta
	mov		cod7,#0FFh	;quarta-feira
	mov		cod6,#0FFh
	mov		cod5,#98h
	mov		cod4,#0C1h
	mov		cod3,#88h
	mov		cod2,#0AFh
	mov		cod1,#087h
	mov		cod0,#88h
	
 quinta:
 	cjne	a,#3,sexta
	mov		cod7,#0FFh	;quinta-feira
	mov		cod6,#0FFh
	mov		cod5,#98h
	mov		cod4,#0C1h
	mov		cod3,#0CFh
	mov		cod2,#0ABh
	mov		cod1,#087h
	mov		cod0,#88h

sexta:
	cjne	a,#4,sabado
	mov		cod7,#0FFh	;sexta-feira
	mov		cod6,#0FFh
	mov		cod5,#0FFh
	mov		cod4,#92h
	mov		cod3,#86h
	mov		cod2,#89h
	mov		cod1,#087h
	mov		cod0,#88h

sabado:
	cjne	a,#5,domingo
	mov		cod7,#0FFh	;s�bado
	mov		cod6,#0FFh
	mov		cod5,#92h
	mov		cod4,#88h
	mov		cod3,#83h
	mov		cod2,#88h
	mov		cod1,#0A1h
	mov		cod0,#0A3h
	
domingo:
	cjne	a,#6,segundax
	mov		cod7,#0FFh	;domingo
	mov		cod6,#0A1h
	mov		cod5,#0A3h
	mov		cod4,#0C8h
	mov		cod3,#0CFh
	mov		cod2,#0ABh
	mov		cod1,#0C2h
	mov		cod0,#0A3h

segundax:	
	jmp volta

tstch2:
		jnb		ch2,setflg_1
		jmp		tstflg_1

setflg_1:
		setb	          flg_1
		jmp		tstflg_1

tstflg_1:
		jb		flg_1,tstf_data
		jmp		tstf_hora

tstf_data:
		jb		f_data,c_manual_0
		jmp		c_manual_0	

tstf_hora:
		jb		f_hora,c_manual_1
		jmp		c_manual_1
		jmp		co_hora

c_manual_0:; AJUSTE DO DIA, MES E ANO, IMPORTANTE!!!
		jb                  flgcont,testacomdelay
                    jmp                 c_manual_0

testacomdelay:
                    jnb		ch3,setf_data
		jmp		tstch4_1
setf_data:
		setb	          f_data
		jmp		inc_dia
		
inc_dia:;############################################ AJUSTE DO DIA ###################################################################
		jmp		incdia

tstch4_1:
		jnb		ch4,setf_data1
		jmp		tstch5_1
		
setf_data1:
		setb	          f_data
		jmp		inc_mes
		
inc_mes:;################################### AJUSTE DO M�S ####################################################################
		inc		mes
		mov		a,mes
		cjne	          a,#13,dif3
		jmp		zerames
dif3:
		jc		setdata
zerames:
		mov		mes,#1
		jmp                 setdata    
tstch5_1:
		jnb		ch5,setf_data2
		jmp		clrf_data

setf_data2:
		setb	          f_data
		jmp		inc_ano
clrf_data:
		clr		f_data
		jmp		co_data		
inc_ano:;########################################### AJUSTE DO ANO ###################################################################
		inc                 ano
                    mov                 a,ano
                    cjne                a,#100,dif2
	   	jmp		zeraano
                    
dif2:   
                    jc                  setdata
zeraano:
                    mov                 ano,#0
setdata:
		clr		  f_data
		jmp		  co_data

c_manual_1:; AJUSTE DA HORA, MINUTO E SEGUNDO, IMPORTANTE!!!!
	
		jnb		ch3,hora_1
		jmp		tstch4

hora_1:
		setb	          f_hora
		jmp		inc_hora
		
inc_hora:	   ;############################################ AJUSTE DA HORA ##########################################
		
		inc                 hor
                    mov                 a,hor
                    cjne                a,#24,dif60_23
                    jmp                 zerahora
dif60_23:
		jc                  setfhora
zerahora:
		mov                 hor,#0
		jmp		setfhora
tstch4:
		jnb		ch4,hora1
		jmp		tstch5
		
hora1:
		setb	          f_hora
		jmp		inc_min
		
inc_min:;######################## AJUSTE DOS MINUTOS ##################################################
		inc                 min
                    mov                 a,min
                    cjne                a,#60,dif60_123
                    jmp                 zeramin1
dif60_123:
		jc		setfhora

zeramin1:  
		mov                 min,#0
		jmp		setfhora
setfhora:		
		clr		f_hora
		jmp		co_hora
tstch5:
		jnb		ch5,hora_11
		jmp		hora0
hora_11:
		setb	          f_hora
		jmp		clr_seg
hora0:
		clr		f_hora
		jmp		co_hora		
clr_seg:		
		mov                 seg,#0
			;########################### ZERA O SEGUNDO ######################################################

co_hora:
		mov		a,seg
		mov		b,#10
		div  	          ab
		mov		dptr,#tabela
		movc	          a,@a+dptr
		mov		cod1,a
		mov		a,b
		movc	          a,@a+dptr
		mov		cod0,a

		mov		a,min
		mov		b,#10
		div  	          ab
		mov		dptr,#tabela
		movc	          a,@a+dptr
		mov		cod3,a
		mov		a,b
		movc	          a,@a+dptr
		mov		cod2,a

		mov		a,hor
		mov		b,#10
		div  	          ab
		mov		dptr,#tabela
		movc	          a,@a+dptr
		mov		cod5,a
		mov		a,b
		movc	          a,@a+dptr
		mov		cod4,a

		mov		cod6,0FFh
		mov		cod7,0FFh
		jmp		volta

co_data:
		mov		a,dia
		mov		b,#10
		div       	ab
		mov		dptr,#tabela
		movc      	a,@a+dptr
		mov		cod7,a
		mov		a,b
		movc      	a,@a+dptr
		mov		cod6,a

		mov		a,mes
		mov		b,#10
		div       	ab
		mov		dptr,#tabela
		movc      	a,@a+dptr
		mov		cod5,a
		mov		a,b
		movc	          a,@a+dptr
		mov		cod4,a

		mov		cod2,#0C0h
		mov		cod3,#0A4h	 

		mov		a,ano
		mov		b,#10
		div  	          ab
		mov		dptr,#tabela
		movc	          a,@a+dptr
		mov		cod1,a
		mov		a,b
		movc	          a,@a+dptr
		mov		cod0,a
		jmp		volta

tabela:		;tabela para a contagem de 0-9 no display
		db	0c0h
		db	0f9h
		db	0a4h
		db	0b0h
		db	99h
		db	92h
		db	82h
		db	0d8h
		db	80h
		db	90h

tabela_1:	;tabela dos meses p/ dia da semana	
		db	0h	;nenhum m�s
		db	0h	;janeiro
		db	3h
		db	3h
		db	6h
		db	1h
		db	4h
		db	6h
		db	2h
		db	5h
		db	0h
		db	3h
		db	5h ;dezembro

incdia:
                    inc       dia
                    mov       a,mes
                    cjne      a,#1,tstmes2
                    jmp       novosm31

tstmes2:            cjne      a,#2,tstmes3
                    jmp       novofev

tstmes3:           
                    cjne      a,#3,tstmes4
                    jmp       novosm31
                    
tstmes4:            
                    cjne      a,#4,tstmes5
                    jmp       novosm30
                    
tstmes5:            
                    cjne      a,#5,tstmes6
                    jmp       novosm31
                    
tstmes6:            
                    cjne      a,#6,tstmes7
                    jmp       novosm30

tstmes7:            
                    cjne      a,#7,tstmes8
                    jmp       novosm31
					   
tstmes8:           
                    cjne      a,#8,tstmes9
                    jmp       novosm31

tstmes9:            
                    cjne      a,#9,tstmes10
                    jmp       novosm30

tstmes10:          
                    cjne      a,#10,tstmes11
                    jmp       novosm31

tstmes11:           
                    cjne      a,#11,tstmes12
                    jmp       novosm30
                    
tstmes12:          
                    cjne      a,#12,volta_1
                    jmp       novodia31

volta_1:            jmp       conversao

novodia31:
		jb        ch3,volta_1        		
		mov       a,dia
                    cjne      a,#31,novoanonovo
		jmp	setdata1
novoanonovo:
		jc	setdata1
		mov       dia,#1
                    mov       mes,#1
		jmp       setdata	

novosm31:
		jb	ch3,volta_1
		mov       a,dia
                    cjne      a,#31,volta_4
                    jmp       setdata
setdata1:          
		jmp       setdata	

volta_4: 		
		jc        setdata1 
		jmp       dia_1

dia_1:		
		mov       dia,#1
                    inc       mes
		jmp	setdata1

novosm30:  	
		jb	ch3,volta_1
		mov       a,dia
                    cjne      a,#31,volta_5
volta_5:
		jc        setdata1   
		jmp	dia_1

novofev:
		jb	ch3,volta_1
		mov   	a,ano
                    mov       b,#4
                    div       ab 
                    mov       a,b 
		jz	novotst29 
		jmp       novotst28
novotst29:
		mov       a,dia
                    cjne      a,#29,volta_6
                	jmp       setdata
volta_6:          
		jc        setdata1 
		jmp	dia_1

novotst28: 	
		mov       a,dia
                    cjne      a,#28,volta_6
                    jmp       retorno
		jmp	dia_1
retorno:		
		reti

saidoaperto:
          
                    mov       TH0,#(256-250)   ; vou gerar 250Hz
                    push      acc
                    push      psw
                    inc       cont
                    mov       a,cont
                    cjne      a,#250,vousair
                    mov       cont,#0
                    jmp	contagem     ; rotina de contagem
vousair:
                    jmp       retorno_1_1
         

contagem:
		inc       seg
    		mov       a,seg
    		cjne      a,#60,dif60
    		jmp       zeraseg

dif60:             
		jc        volta_1_1
zeraseg:            
		mov       seg,#0
                    inc       min
                    mov       a,min
                    cjne      a,#60,dif60_1
                    jmp       zeramin
dif60_1:            
		jc        volta_1_1 
zeramin:            
		mov       min,#0
                    inc       hor
                    mov       a,hor
                    cjne      a,#24,dif60_2
                    jmp       zerahor
dif60_2:            
		jc        volta_1_1
zerahor:           
		mov       hor,#0
	          inc       dia
                    mov       a,mes
                    cjne      a,#1,tstmes2_1
                    jmp       sm31_1

tstmes2_1:            
	  cjne      a,#2,tstmes3_1
            jmp       fev_1

tstmes3_1:           
            cjne      a,#3,tstmes4_1
            jmp       sm31_1
                    
tstmes4_1:            
            cjne      a,#4,tstmes5_1
            jmp       sm30_1
                    
tstmes5_1:            
            cjne      a,#5,tstmes6_1
            jmp       sm31_1
                    
tstmes6_1:            
            cjne      a,#6,tstmes7_1
            jmp       sm30_1

tstmes7_1:            
            cjne      a,#7,tstmes8_1
            jmp       sm31_1
					   
tstmes8_1:           
            cjne      a,#8,tstmes9_1
            jmp       sm31_1

tstmes9_1:            
            cjne      a,#9,tstmes10_1
            jmp       sm30_1

tstmes10_1:          
            cjne      a,#10,tstmes11_1
            jmp       sm31_1

tstmes11_1:           
            cjne      a,#11,tstmes12_1
            jmp       sm30_1
                    
tstmes12_1:          
            cjne      a,#12,volta_1_1
            jmp       dia31_1
dia31_1:             		
	          mov       a,dia
                    cjne      a,#31,anonovo_1
		jmp		  volta_1_1	;rever
volta_1_1:           
		jmp       retorno_1_1	
                    
anonovo_1:			
		jc		  dia31_1
		mov       dia,#1
                    mov       mes,#1
		inc       ano
                    mov       a,ano
                    cjne      a,#99,volta_2_1
		jmp       retorno_1_1
                    
volta_2_1:            
		jc        retorno_1_1
                    mov       ano,#0
                    jmp       retorno_1_1

sm31_1:               
                    mov       a,dia
                    cjne      a,#31,volta_4_1
                    jmp       retorno_1_1
	

volta_4_1:            
		jc        retorno_1_1
		jmp       dia_1_1

dia_1_1:             
		mov       dia,#1
                    inc       mes
                    jmp       retorno_1_1

sm30_1:               
		mov       a,dia
                    cjne      a,#30,volta_5_1
                    jmp       retorno_1_1
volta_5_1:            
		jc        retorno_1_1 
		jmp		  dia_1_1
					
fev_1:                
                    mov       a,ano
                    mov       b,#4
                    div       ab 
                    mov       a,b 
		jz	tst29_1 
                    jmp       tst28_1

tst29_1:    
                    mov       a,dia
                    cjne      a,#29,volta_6_1
                    jmp       retorno_1_1

volta_6_1:        
		jc        retorno_1_1
		jmp	dia_1_1
tst28_1:       
                    mov       a,dia
                    cjne      a,#28,volta_7_1
                    jmp       retorno_1_1

volta_7_1:           
		jc        retorno_1_1 
		jmp	 	  dia_1_1
retorno_1_1:		   
                        pop   psw
                        pop   acc
                        reti	


          end




