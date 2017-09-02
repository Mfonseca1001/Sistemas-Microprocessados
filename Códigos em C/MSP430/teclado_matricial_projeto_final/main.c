/*
* TECLADO MATRICIAL
* DESENVOLVIDO POR : MARCELE FONSECA
* PROJETO DA QUARTA UNIDADE DE SMP
*/

//------bibliotecas------
#include "io430.h"
#include <stdio.h>
//-----------------------

//-----definições globais-----

#define LCD_DIR P2DIR
#define LCD_OUT P2OUT
#define HOME

#ifdef HOME

#define LCD_PIN_RS BIT0 // P2.0
#define LCD_PIN_RW BIT1 // P2.1
#define LCD_PIN_EN BIT2 // P2.2

#define LCD_PIN_D7 BIT7 // P2.7
#define LCD_PIN_D6 BIT6 // P2.6
#define LCD_PIN_D5 BIT5 // P2.5

#define LCD_PIN_D4 BIT4 // P2.4

#else

#define LCD_PIN_RW BIT2 // P2.2
#define LCD_PIN_RS BIT1 // P2.1
#define LCD_PIN_EN BIT3 // P2.3

#define LCD_PIN_D7 BIT7 // P2.7 
#define LCD_PIN_D6 BIT6 // P2.6
#define LCD_PIN_D5 BIT5 // P2.5
#define LCD_PIN_D4 BIT4 // P2.4

#endif

#define C1    P1OUT_bit.P0  
#define L1    P1IN_bit.P1
#define L2    P1IN_bit.P2
#define C2    P1OUT_bit.P3 
#define L3    P1IN_bit.P4
#define C3    P1OUT_bit.P5
#define L4    P1IN_bit.P6
#define C4    P1OUT_bit.P7 

#define LED P2OUT_bit.P3

#define LCD_PIN_MASK ((LCD_PIN_RS | LCD_PIN_RW | LCD_PIN_EN | LCD_PIN_D7 | LCD_PIN_D6 | LCD_PIN_D5 | LCD_PIN_D4))

//-----variáveis globais-----

char control = 1;               	//variável de controle de teclado
//static int counter = 0;         	//variável auxiliar de contagem
int number1 = 0;                    //variável para armazenar o número pressionado no teclado
int number2 = 0;
int number3 = 0;
char str[16];   
 
// string para aparecer no LCD
typedef unsigned char BYTE;
typedef unsigned int WORD;
extern unsigned char cur;
int senha;
char flag = 0;
char aux_store = 0;
char compara = 0;
int tentativa = 0;
int digito;
//-----------------------------

//-----funções externas--------
extern void Idisp(void);                                // Inicializa display
extern void WRDISPC(unsigned char);                     // envia um comando
extern void WRDISPD(unsigned char);                     // envia um caracter
extern unsigned char RDDISPD(void);                     // Ler dados no display 
extern void Print(unsigned char end,  char * s);        // imprime uma string s no endereço end
extern void PrintStr(char * p);
extern void PrintDisp(unsigned char a);                 //Imprime com scroll
//--------------------------------

//-----protótipos das funções-----
void store(char value);
void store1(char value1);
void store2(char value2);
void numero();
void varre();
void SendByte(char , int );
void PrintStrg(char *);
void avaliar ();

//--------------------------------

//------LCD------

int putchar(int c) {
  PrintDisp(c); //SendByte(c, TRUE);
  return c;
}
//-----------------

//-----configurações iniciais-----
void main( void ){
  
  WDTCTL = WDTPW + WDTHOLD;
  
  BCSCTL1 = CALBC1_1MHZ;
  DCOCTL = CALDCO_1MHZ;
  
  P1REN = (BIT1 | BIT2 | BIT4 | BIT6);          // ligo o resistor de pull up
  P1OUT |= (BIT1 | BIT2 | BIT4 | BIT6);         //  'set' nas linhas
  P1DIR = 0xA9;									//(BIT0 | BIT3 | BIT5 | BIT7);   // coloco as colunas como sáida
  P2DIR = (BIT3);
  P2OUT =(BIT3);
  
  TA0CTL = TASSEL_2 | ID_3 | MC_1;              // SMCLK / 8 , Up mode. 
  TA0CCR0=31250-1;                              //  1Mhz/8/4Hz = 31250
  TA0CCTL0=CCIE;                                // Habilita interrupção no estouro
  

  LCD_DIR |= LCD_PIN_MASK;
  LCD_OUT &= ~(LCD_PIN_MASK);
  P2SEL = 0x00;                                 // todas portas IO  , no reset xin e xout são ativos
  
  __bis_SR_register(GIE);                       //HABILITA INTERRUPÇÃO GERAL
  
  Idisp();                                      //inicializa o LCD
  
//-----Mensagem de saudação------
  Print(0x80,"   BEM VINDO   ");
  Print(0xC0,"ACESSO POR SENHA");
  __delay_cycles(2000000);
  
  WRDISPC(0x01);

    while(1){
      Print(0x80,"DIGITE A SENHA:"); 
      varre(); 										// rotina de varredura  
      sprintf(str,"Senha:%d",senha);                
      Print(0xC0,  str);  
      
      sprintf(str,"Senha:%d",number1);                
      Print(0xC0,  str);                            // imprime o valor lido na varredura
      sprintf(str,"%d",number2);                
      Print(0xC7,  str); 
      sprintf(str,"%d",number3);                
      Print(0xC8,  str); 
      
	       if(compara == 1 ){
	       		WRDISPC(0x01); 
	       		while(digito == senha);
	       		while (senha ==0);
	        		if(senha==796){
	            		WRDISPC(0x01);
	             		__delay_cycles(1000000);
	            		LED = 1;
	            		Print(0x80," SENHA CORRETA ");
	            		Print(0xC0,"SISTEMA LIBERADO");
	            		__delay_cycles(100000000);
	            		WRDISPC(0x01);
	            		__delay_cycles(100);
	            		number1 = 0;
	            		number2 = 0;
	            		number3 = 0;
	            		compara =0;
	            		while(1);
	        		}else{
	            		WRDISPC(0x01);
	            		aux_store=0;
	            		compara = 0;
				            LED = 1;
				            __delay_cycles(1000000);
				             LED = 0;
				             __delay_cycles(1000000);
				             LED = 1;
				             __delay_cycles(1000000);
				             LED = 0;
				             __delay_cycles(1000000);
				             LED = 1;
				             __delay_cycles(1000000);
				             LED = 0;
				            Print(0x80,"SENHA INCORRETA");
				            __delay_cycles(2000000);
				            WRDISPC(0x01);
				            //number1 = 0;
				            //number2 = 0;
				            //number3 = 0;
	          		}
	      }
    }  
}
//----------------------------------------

//----rotina de interrupção----

#pragma vector=TIMER0_A0_VECTOR  
__interrupt void Timer1_A0 (void) {
  
}

//-----Varredura do Teclado matricial----
void varre(){
  if(C1 ==  1 ){ // COLUNA 1
		C1 = 0;
     	C2 = 1;
     	C3 = 1;
     	C4 = 1;
		__delay_cycles(100); 
              if(L1 == 0){
                store(1); 
              }
              if(L2 == 0){
                store(4);
              }
              if(L3 == 0){
                store(7); 
              }
  }
  if (C2 == 1){ // COLUNA 2
      	C1 = 1;
      	C2 = 0;
      	C3 = 1;
      	C4 = 1;
		__delay_cycles(100);
              if(L1 == 0){
                 store(2);
              }
              if(L2 == 0){
                store(5);
              }
              if(L3 == 0){
                store(8);
              }
              if(L4 == 0){
                store(0);                
              }
  }
  if(C3 ==  1 ){ 
     	C1 = 1;
     	C2 = 1;
     	C3 = 0;
     	C4 = 1;
		__delay_cycles(100); 
              if(L1 == 0){
                store(3);       
              }
              if(L2 == 0){
               store(6);
               }
              if(L3 == 0){
               store(9);
              }
 }
/* 
if (C4 == 1 ){ // COLUNA 4
   
     C1 = 1;
     C2 = 1;
     C3 = 1;
     C4 = 0;
__delay_cycles(10);
            if     (L1 == 0) store(11); 
            else if(L2 == 0) store(22); 
            else if(L3 == 0) store(33);
            else if(L4 == 0) store(44);
 }
 */
}
//-------------------------------------------------------------

//-----depois da varredura, vem parar aqui--------------------
void store (char value){
		__delay_cycles(100000)  ;
		aux_store ++;
  switch(aux_store){
	  case 0x01:
	    number1 = value;
	    __delay_cycles(100000)  ;
	    break;
	  case 0x02:
	    number2 = value;
	    __delay_cycles(100000)  ;
	    break;
	  case 0x03:
	    number3 = value;
	    __delay_cycles(100000)  ;
	    break;
   }

 if(aux_store==3){
     __delay_cycles(100)  ;
    aux_store=0;
    compara = 1;
    senha  = (int)(number1*100 + number2*10 + number3);
  }
  	Print(0xC0,"Senha:          ");
}
