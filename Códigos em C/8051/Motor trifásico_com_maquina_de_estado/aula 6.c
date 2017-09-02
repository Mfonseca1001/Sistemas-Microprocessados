/*******************************************
Acionamento de motor trifásico com máquina de estados
Desenvolvido por Marcele Fonseca
 
______5___4___3___2___1___0___
|X|X|F3L|F3H|F2L|F2H|F1L|F1H|
______________________________
*******************************************/
///////////////////////////// código para fazer a senoide ////////////////////////////////////
extern unsigned char code tabela[];

#include <intrins.h>
#include <regx52.h>
#include <math.h>
#define KCONST 17572L
long  i0, i1, i2;

int f =60;
unsigned char F1;
unsigned char F2;
unsigned char F3;
unsigned char x=0;
unsigned char state = 0 ;
int cont = 0;

unsigned char ON_F      = 		0xFF; 
unsigned char OFF_F     = 		0x00;
unsigned char Lhigh     = 		129;
unsigned char Llow      = 		125;
bit flg_ctrl     	    = 		1 ;        // flag de controle do motor
bit flg_inv				=		1;

                              
union t1{
   struct r1{
      unsigned int ACCH;
      unsigned int ACCL;
   }M;
   long ACC; // 32 bits
}R;

////////////////////////// Código novo /////////////////////////////////// 

#define F1_ON_H   ON_F  &= 0xFE
#define F1_ON_L   ON_F  &= 0xFD
#define F1_OFF_L  OFF_F |= 0x02
#define F1_OFF_H  OFF_F |= 0x01

#define F2_ON_H   ON_F  &= 0xFB
#define F2_ON_L   ON_F  &= 0xF7
#define F2_OFF_L  OFF_F |= 0x08
#define F2_OFF_H  OFF_F |= 0x07

#define F3_ON_H   ON_F  &= 0xEF
#define F3_ON_L   ON_F  &= 0xDF
#define F3_OFF_L  OFF_F |= 0x20
#define F3_OFF_H  OFF_F |= 0x10

void main() { 
// inicializar interrupção (escalonamemto)  

   TMOD=0x0;
   TH0=(256-16);
   IE=0x82;
   TR0=1;
   while(1);
}

void task1 (void){
// formação das senoides defasadas (vide tabela de seno)

   i0=i0+ KCONST*f;						 
   if(i0>=47185920) i0=i0 - 47185920;

   i1 = i0 + 15728640; 
   if(i1>=47185920) i1=i1 - 47185920;

   i2 = i0 + 31457280;
   if(i2>=47185920) i2=i2 - 47185920;

	if(flg_inv == 1){
	    R.ACC =i0;
    	F1= tabela[R.M.ACCH];

    	R.ACC =i1;     
    	F2= tabela[R.M.ACCH];
    
    	R.ACC =i2;
    	F3= tabela[R.M.ACCH];
	}
	else{
	    R.ACC =i0;
    	F2= tabela[R.M.ACCH];

    	R.ACC =i1;     
    	F1= tabela[R.M.ACCH];
    
    	R.ACC =i2;
    	F3= tabela[R.M.ACCH];
	}

// Comutação das portas para acionamento dos IGBT's
//Fase 1
    if(F1>Lhigh){
		F1_ON_H; F1_OFF_L;} 
	
	else  if(F1<Llow){
		F1_ON_L; F1_OFF_H;
	}

    else {
		F1_OFF_H; F1_OFF_L ;
	} 
//Fase 2      
    if(F2>Lhigh){
		F2_ON_H; F2_OFF_L;
	} 
	
	else  if(F2<Llow){
		F2_ON_L; F2_OFF_H;
	}

    else{
		F2_OFF_H; F2_OFF_L ;
	}
//Fase 3
    if(F3>Lhigh){
		F3_ON_H; F3_OFF_L;
	} 
	
	else  if(F3<Llow){
		F3_ON_L; F3_OFF_H;
	}
    else{
		F3_OFF_H; F3_OFF_L ;
	}

// condições de controle do motor

	if(flg_ctrl == 1){
	    
	    P1 |=OFF_F;
	    _nop_();
	    _nop_();
	    _nop_();
	
	    P1 &=ON_F;
	    ON_F = 0XFF;
	    OFF_F= 0x00;   
		   
	 }	else P1 = 0xFF;
} 
// 0,1s ->Task_2	 p/ 1s  cont =10,  p/ 5s cont =50
// ciclo de máquina de estados em anexo (imagem)
void task2(void){ 
	switch (state){
	
	      case 0 :
		  cont ++;
	      if(cont == 10){
	         cont = 0;
	         state = 1;        
	         f = 40;
	      }	//aguarda 1s, f muda para 40Hz 
	      break;  
	
	      case 1 :
		  cont ++;
	      if(cont == 10){
	         cont = 0;
	         state = 2;        
	         f = 80;
	      }	//aguarda 1s, f muda para 80Hz
	      break;
	
	      case 2 :
		  cont ++;
	      if(cont == 10){
	         cont = 0;
			 state = 3;
			 f = 120;        
	      }//aguarda 1s, f muda para 120Hz
	      break;
	
	      case 3 :
		  cont ++;
	      if(cont==10){
			 cont = 0; 
			 flg_ctrl = 0;
			 state = 4;      
	      }//aguarda 1s, para o motor
	      break;
	
	      case 4 :
		  cont ++;
	      if(cont==50){
			 cont = 0; 
			 flg_inv =~ flg_inv ;
			 flg_ctrl = 1;
			 state = 5; 
			 f = 40; 
	      }// aguarda 5s, inverte a fase e f inicia em 40Hz  
	      break;
	
	      case 5 :
		  cont ++;
		  if(cont==10){
			 cont = 0; 
			 state = 6;
			 f = 80;      
	      }//aguarda 1s, f muda para 80Hz
	      break;
	
	      case 6 :
		  cont ++;
		  if(cont==10){
			 cont = 0; 
			 state = 7;
			 f = 120;      
	      }//aguarda 1s, f muda para 120Hz
	      break;
	
	      case 7 :
		  cont ++;
	      if(cont==10){
			 cont = 0; 
			 flg_ctrl = 0;
			 state = 8;      
	      }//aguarda 1s, para o motor
	      break;
	
	      case 8 :
		  cont ++;
	      if(cont==50){
			 cont = 0;
			 flg_inv =~ flg_inv ;
			 flg_ctrl = 1;
			 state = 0;
	      }// aguarda 5s, inverte a fase, 'state' = 0 voltando para o inicio
	      break;
	
	}
}


  
 
