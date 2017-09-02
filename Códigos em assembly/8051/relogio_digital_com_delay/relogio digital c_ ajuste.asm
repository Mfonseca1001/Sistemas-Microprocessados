
;-------------------------------------------------------
;Rel�gio Digital com ajuste e exibi��o do dia da semana |
;Desenvolvido por Marcele Fonseca			|
;------------------------------------------------------


DSP0       EQU       P2.4
DSP1       EQU       P2.0
DSP2       EQU       P2.1
DSP3       EQU       P2.2
DSP4       EQU       P2.3
DSP5       EQU       P2.5
DSP6       EQU       P2.6
DSP7       EQU       P2.7
CH1        EQU       P3.0
CH2        EQU       P3.1
CH3	   EQU	     P3.2
CH4	   EQU	     P3.3
CH5	   EQU	     P3.4		

bseg

flg_DP0:   dbit      1
flg_DP1:   dbit      1
flg_DP2:   dbit      1
flg_DP3:   dbit      1
flg_DP4:   dbit      1   
flg_DP5:   dbit      1
flg_DP6:   dbit      1
flg_DP7:   dbit      1
flg_1:	   dbit	     1
f_hora:	   dbit	     1
f_data:	   dbit	     1
flg_s:	   dbit	     1

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
CONT:	   ds	 	 1 
          
cseg

inicio1:
      	    mov       seg,#0
            mov       min,#0
            mov       hor,#0
            mov       dia,#01
            mov       mes,#01
            mov       ano,#00

inicio2:
	    MOV       P0,#0FFh
            MOV       P2,#0FFh
            SETB      flg_DP0

volta:
          JB        flg_DP0,offDSP0
          JB        flg_DP1,offDSP1
          JB        flg_DP2,offDSP2
          JB        flg_DP3,offDSP3
          JB        flg_DP4,offDSP4
          JB        flg_DP5,offDSP5
          JB        flg_DP6,offDSP6
          JB        flg_DP7,offDSP7

          JMP       encontro1

offDSP0:
          SETB      DSP0
          MOV       P0, COD1
          CLR       DSP1
          CLR       flg_DP0
          SETB      flg_DP1
          JMP       encontro1
          
offDSP1:
          SETB      DSP1
          MOV       P0, COD2
          CLR       DSP2
          CLR       flg_DP1
          SETB      flg_DP2
          JMP       encontro1
          
offDSP2:
          SETB      DSP2
          MOV       P0, COD3
          CLR       DSP3
          CLR       flg_DP2
          SETB      flg_DP3
          JMP       encontro1
          
offDSP3:
          SETB      DSP3
          MOV       P0, COD4
          CLR       DSP4
          CLR       flg_DP3
          SETB      flg_DP4
          JMP       encontro1

offDSP4:
          SETB      DSP4
          MOV       P0, COD5
          CLR       DSP5
          CLR       flg_DP4
          SETB      flg_DP5
          JMP       encontro1

offDSP5:
          SETB      DSP5
          MOV       P0, COD6
          CLR       DSP6
          CLR       flg_DP5
          SETB      flg_DP6
          JMP       encontro1

offDSP6:
          SETB      DSP6
          MOV       P0, COD7
          CLR       DSP7
          CLR       flg_DP6
          SETB      flg_DP7
          JMP       encontro1

offDSP7:
          SETB      DSP7
          MOV       P0, COD0
          CLR       DSP0
          CLR       flg_DP7
          SETB      flg_DP0
          JMP       encontro1

;delay*************************************************************************************************************************************

encontro1:
         mov       R1,#20

loop:
         mov       R0,#61
         djnz      R0,$
         djnz      R1,loop
inccont:
	
		  inc 	cont
          mov	a,cont
	      cjne	a,#255,voltay
	      jmp	zerarcont
voltay:	  jmp	volta

zerarcont: mov	cont,#0
	 	   jmp	conversao

conversao:;*************************************************************************************************************************
		jnb		ch1,clrflg_1
		jmp		tstch2

clrflg_1:
		jnb		ch2,flg_semana_1 	;se a ch1 e ch2 =0, mostra o dia da semana
		clr		flg_1
		jmp		tstflg_1

flg_semana_1:
		setb		flg_s
		jb		flg_s,mostrad_sem
		jmp		conversao

mostrad_sem:; DIA DA SEMANA IMPORTANTE!!!

	mov		a,ano	; movo o ano para acumulador	
	mov		b,#100	;movo 100 para 'b'
	add 		a,b	;somo a+b
	mov		r0,a	; valor de A= ano+100
	mov		b,#4	
	div		ab
	mov		r1,a	; valor de B= ano n�o bissexto	
	mov     	a,ano
    	mov     	b,#4
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
	mov	cod7,#0FFh	;segunda-feira
	mov	cod6,#92h
	mov	cod5,#86h
	mov	cod4,#0C2h
	mov	cod3,#0c1h
	mov	cod2,#0ABh
	mov	cod1,#0A1h
	mov	cod0,#88h

terca:	cjne	a,#1,quarta
	mov	cod7,#0FFh	;ter�a-feira
	mov	cod6,#0FFh
	mov	cod5,#0FFh
	mov	cod4,#87h
	mov	cod3,#86h
	mov	cod2,#0AFh
	mov	cod1,#0C6h
	mov	cod0,#88h

quarta:
 	cjne	a,#2,quinta
	mov	cod7,#0FFh	;quarta-feira
	mov	cod6,#0FFh
	mov	cod5,#98h
	mov	cod4,#0C1h
	mov	cod3,#88h
	mov	cod2,#0AFh
	mov	cod1,#087h
	mov	cod0,#88h
	
 quinta:
 	cjne	a,#3,sexta
	mov	cod7,#0FFh	;quinta-feira
	mov	cod6,#0FFh
	mov	cod5,#98h
	mov	cod4,#0C1h
	mov	cod3,#0CFh
	mov	cod2,#0ABh
	mov	cod1,#087h
	mov	cod0,#88h

sexta:
	cjne	a,#4,sabado
	mov	cod7,#0FFh	;sexta-feira
	mov	cod6,#0FFh
	mov	cod5,#0FFh
	mov	cod4,#92h
	mov	cod3,#86h
	mov	cod2,#89h
	mov	cod1,#087h
	mov	cod0,#88h

sabado:
	cjne	a,#5,domingo
	mov	cod7,#0FFh	;s�bado
	mov	cod6,#0FFh
	mov	cod5,#92h
	mov	cod4,#88h
	mov	cod3,#83h
	mov	cod2,#88h
	mov	cod1,#0A1h
	mov	cod0,#0A3h
	
domingo:
	cjne	a,#6,segundax
	mov	cod7,#0FFh	;domingo
	mov	cod6,#0A1h
	mov	cod5,#0A3h
	mov	cod4,#0C8h
	mov	cod3,#0CFh
	mov	cod2,#0ABh
	mov	cod1,#0C2h
	mov	cod0,#0A3h

segundax:	jmp	inccont	

tstch2:
		jnb		ch2,setflg_1
		jmp		tstflg_1

setflg_1:
		setb		flg_1
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

		jnb		ch3,setf_data
		jmp		tstch4_1

setf_data:
		setb		f_data
		jmp		inc_dia
		
inc_dia:;############################################ AJUSTE DO DIA ###################################################################
		jmp		incdia

tstch4_1:
		jnb		ch4,setf_data1
		jmp		tstch5_1
		
setf_data1:
		setb	f_data
		jmp		inc_mes
		
inc_mes:;################################### AJUSTE DO M�S ####################################################################
		inc		mes
		mov		a,mes
		cjne		a,#13,dif3
		jmp		zerames
dif3:
		jc		setdata
zerames:
		mov		mes,#1
		jmp     	setdata    
tstch5_1:
		jnb		ch5,setf_data2
		jmp		clrf_data

setf_data2:
		setb		f_data
		jmp		inc_ano
clrf_data:
		clr		f_data
		jmp		co_data		
inc_ano:;########################################### AJUSTE DO ANO ###################################################################
		inc       	ano
        	mov       	a,ano
        	cjne      	a,#100,dif2
	    	jmp		zeraano
                    
dif2:   
		jc        	setdata
zeraano:
        	mov       	ano,#0
setdata:
		clr		  f_data
		jmp		  co_data

c_manual_1:; AJUSTE DA HORA, MINUTO E SEGUNDO, IMPORTANTE!!!!
	
		jnb		ch3,hora_1
		jmp		tstch4

hora_1:
		setb		f_hora
		jmp		inc_hora
		
inc_hora:	   ;############################################ AJUSTE DA HORA ##########################################
		
		inc       hor
        	mov       a,hor
        	cjne      a,#24,dif60_23
        	jmp       zerahora
dif60_23:
		jc        setfhora
zerahora:
		mov       hor,#0
		jmp	  setfhora
tstch4:
		jnb	  ch4,hora1
		jmp	  tstch5
		
hora1:
		setb	f_hora
		jmp	inc_min
		
inc_min:;######################## AJUSTE DOS MINUTOS ##################################################
		    inc       min
                    mov       a,min
                    cjne      a,#60,dif60_123
                    jmp       zeramin1
dif60_123:          
		    jc	      setfhora

zeramin1:            
		mov       min,#0
		jmp	  setfhora
setfhora:	
		clr	  f_hora
		jmp	  co_hora
		

tstch5:
		jnb		ch5,hora_11
		jmp		hora0

hora_11:
		setb		f_hora
		jmp		clr_seg
hora0:
		clr		f_hora
		jmp		co_hora		
clr_seg:	mov     	seg,#0	;########################### ZERA O SEGUNDO ######################################################

co_hora:
	mov	a,seg
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod1,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod0,a

	mov	a,min
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod3,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod2,a

	mov	a,hor
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod5,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod4,a

	mov	cod6,0FFh
	mov	cod7,0FFh
	jmp	contagem

co_data:
	mov	a,dia
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod7,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod6,a

	mov	a,mes
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod5,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod4,a

	mov	cod2,#0C0h
	mov	cod3,#0A4h	 

	mov	a,ano
	mov	b,#10
	div  	ab
	mov	dptr,#tabela
	movc	a,@a+dptr
	mov	cod1,a
	mov	a,b
	movc	a,@a+dptr
	mov	cod0,a
	jmp	contagem

contagem:
	inc       seg
    	mov       a,seg
    	cjne      a,#60,dif60
    	jmp       zeraseg

dif60:              jc        volta_1
zeraseg:            mov       seg,#0
          
                    inc       min
                    mov       a,min
                    cjne      a,#60,dif60_1
                    jmp       zeramin
dif60_1:            jc        volta_1 
zeramin:            mov       min,#0

                    inc       hor
                    mov       a,hor
                    cjne      a,#24,dif60_2
                    jmp       zerahor
dif60_2:            jc        volta_1
zerahor:            mov       hor,#0

incdia:
                    inc       dia
                    mov       a,mes
                    cjne      a,#1,tstmes2
                    jmp       sm31

tstmes2:            cjne      a,#2,tstmes3
                    jmp       fev

tstmes3:           
                    cjne      a,#3,tstmes4
                    jmp       sm31
                    
tstmes4:            
                    cjne      a,#4,tstmes5
                    jmp       sm30
                    
tstmes5:            
                    cjne      a,#5,tstmes6
                    jmp       sm31
                    
tstmes6:            
                    cjne      a,#6,tstmes7
                    jmp       sm30

tstmes7:            
                    cjne      a,#7,tstmes8
                    jmp       sm31
					   
tstmes8:           
                    cjne      a,#8,tstmes9
                    jmp       sm31

tstmes9:            
                    cjne      a,#9,tstmes10
                    jmp       sm30

tstmes10:          
                    cjne      a,#10,tstmes11
                    jmp       sm31

tstmes11:           
                    cjne      a,#11,tstmes12
                    jmp       sm30
                    
tstmes12:          
                    cjne      a,#12,volta_1
                    jmp       dia31



dia31:              	jnb       ch3,novodia31		
			mov       a,dia
                    	cjne      a,#31,anonovo
			ljmp	  setdata	;rever
volta_1:            	jmp       volta

novodia31:        		
			mov       a,dia
                    	cjne      a,#31,novoanonovo
			ljmp	  setdata1
novoanonovo:
			jc	  setdata1; rever
			mov       dia,#1
                    	mov       mes,#1
			jmp       setdata;rever	
                    
anonovo:			
			jc	  dia31
			mov       dia,#1
                    	mov       mes,#1
			inc       ano
                    	mov       a,ano
                    	cjne      a,#99,volta_2
			jmp	  voltax
                    
volta_2:            	jc        voltax
                  	mov       ano,#0
                    	jmp       voltax

sm31:               
			jnb	  ch3,novosm31
                    	mov       a,dia
                    	cjne      a,#31,volta_4
                    	jmp       volta
novosm31:
			mov       a,dia
                    	cjne      a,#31,volta_4_1
                    	jmp       setdata
 setdata1:           	jmp       setdata	

volta_4:            	jc        voltax
			jmp       dia_1
volta_4_1: 		jc        setdata1 ;rever
			jmp	  dia_1_1

dia_1_1:		mov       dia,#1
                   	inc       mes
			jmp	  setdata1
dia_1:             	mov       dia,#1
                    	inc       mes
                    	jmp       volta

sm30:               
			jnb	  ch3,novosm30
			mov       a,dia
                    	cjne      a,#30,volta_5
                    	jmp       volta
volta_5:            	jc        voltax 
			jmp	  dia_1

novosm30:  		mov       a,dia
                    	cjne      a,#31,volta_5_1
volta_5_1:		jc        setdata1   ;REVER
			jmp	  dia_1_1
					
fev:                
		 	jnb	  ch3,novofev
                    	mov       a,ano
                    	mov       b,#4
                    	div       ab 
                    	mov       a,b 
			jz	  tst29 
                    	jmp       tst28

tst29:    
                    	mov       a,dia
                    	cjne      a,#29,volta_6
                    	jmp       volta

volta_6:            	jc        voltax
			jmp	  dia_1
voltax:             	jmp       volta
tst28:       
                    	mov       a,dia
                    	cjne      a,#28,volta_7
                    	jmp       volta
novofev:		mov       a,ano
                    	mov       b,#4
                    	div       ab 
                    	mov       a,b 
			jz	  novotst29 
			jmp       novotst28
novotst29:
			mov       a,dia
                    	cjne      a,#29,volta_6_1
                	jmp	  setdata
volta_6_1:          	jc        setdata1 ;REVER
			jmp	  dia_1_1


novotst28: 		mov       a,dia
                    	cjne      a,#28,volta_6_1
                    	jmp       volta

volta_7:            	jc        voltax  
			jmp	  dia_1					

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

		end