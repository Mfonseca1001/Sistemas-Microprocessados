#include "io430.h"
#include <string.h>
//#include <intrins.h>
typedef unsigned char BYTE;
typedef unsigned int WORD;
unsigned char cur=0x80;

#define BUSDISPOUT	P2OUT    // porta onde está conectado o display
#define BUSDISPIN	P2IN    // porta onde está conectado o display
#define BUSDDIR	P2DIR    // porta onde está conectado o display
#define CLS	0x01
#define FS	0x00
#define LF 0x0A
#define FF 0x0C
#define CR 0x0D
#define _nop_() __no_operation()

// ***** Pinos do display de LCD & LEDS*****

// Define symbolic LCD
//
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

#define RS    P2OUT_bit.P0
#define RW    P2OUT_bit.P1
#define EN    P2OUT_bit.P2

#else

#define LCD_PIN_RW BIT2 // P2.2
#define LCD_PIN_RS BIT1 // P2.1
#define LCD_PIN_EN BIT3 // P2.3

#define LCD_PIN_D7 BIT7 // P2.7
#define LCD_PIN_D6 BIT6 // P2.6
#define LCD_PIN_D5 BIT5 // P2.5
#define LCD_PIN_D4 BIT4 // P2.4

#define RS    P2OUT_bit.P1
#define RW    P2OUT_bit.P2
#define EN    P2OUT_bit.P3

#endif


#define DSP_PIN_MASK ((LCD_PIN_D7 | LCD_PIN_D6 | LCD_PIN_D5 | LCD_PIN_D4))


//**** FUNÇÕES DE ACESSO AO DISPLAY DE LCD ***
void Idisp(void);               // Inicializa display
void WRDISPC(unsigned char);    // envia um comando
void WRDISPD(unsigned char);    // envia um caracter
unsigned char RDDISPD(void);    // Ler dados no display 
void Print(unsigned char end,  char * s);  // imprime uma string s no endereço end
void PrintStr( char * p);
void PrintDisp(unsigned char a);  //Imprime com scroll
#define delay(c) __delay_cycles(c)   // rotina de atraso


// 62.5ns 
#define DELAY15 delay(240000) // ;1 DELAY DE 15ms	  
#define DELAY1 delay(65600)  //4,1ms	 
#define DELAY100 delay(1600)  //100us	 


void Idisp(void) {	  //Interface 4 bits

 unsigned char i;
 const unsigned char  getd[] = { 0x28 //|0|0|1|DL|N  |F  |0  |0| 4 bits 2 linhas 5x8//|0|0|0|1 |S/C|R/L|0  |0| Display não desloca  Right/Left não usado  
,0x06//|0|0|0|0 |0  |1  |I/D|S| Cursor incrementa e não acompanha deslocamento
,0x0C //|0|0|0|0 |1  |D  |C  |B| Display ON, Cursor ON Blink OK
,0x01 //|0|0|0|0 |0  |0  |0  |1| Limpa dsiplay
 };

 RW = 0;
 EN = 0;
 RS = 0;
 DELAY15;  //15ms
 BUSDISPOUT = 0x30;
 EN = 1;
 _nop_();
 _nop_();
 _nop_();
 EN = 0;
 DELAY15;  // 6ms		
 BUSDISPOUT = 0x30;
 EN = 1;
 _nop_();
 _nop_();
 _nop_();
 EN = 0;
 DELAY100; // 100us			
 BUSDISPOUT = 0x30;
 EN = 1;
 _nop_();
 _nop_();
 _nop_();
 EN = 0;
 DELAY100; // 100us			
 BUSDISPOUT = 0x20;
 EN = 1;
 _nop_();
 _nop_();
 _nop_();
 EN = 0;
 DELAY100; // 100us		


 RS = 0;   // PREPARA DISPLAY PARA COMANDO
 for (i=0;i<4;i++) {
   
   WRDISPC(getd[i]);
   /*
   BUSDISP = getd[i] | 0x0f;
   EN = 1;
   _nop_();		
   _nop_();
   EN = 0;
   _nop_();		
   _nop_();
   BUSDISP = (getd[i] << 4) | 0x0f;
   EN = 1;
   _nop_();		
   _nop_();
   EN = 0;
   DELAY100; // 100s
   */
 }  		
}


//-----------------------------------------------------------

void Print(unsigned char e, char * p) {
	
  cur = e;
  WRDISPC(e); // Primeira linha ;ENVIA AO DISPLAY
  while(*p != 0) {
    PrintDisp(*p);
	p++;
  }
/*
  while(*p != 0) {
    WRDISPD(*p);
	p++;
  }
*/  
}


void PrintStr(char * p) {
	
  while(*p != 0) {
    PrintDisp(*p);
	p++;
  }
}

//-----------------------------------------------------------


void WRDISPC(unsigned char a) {
   
   register char d;
   BUSDDIR &= ~DSP_PIN_MASK;  //Coloca como entradas
   RW = 1;
   RS = 0;
   _nop_();
   _nop_();
   do {
     EN = 1;
     _nop_();
     _nop_();
     d =  BUSDISPIN;
     EN = 0;
     _nop_();		
     _nop_();
     _nop_();
     EN = 1;
     _nop_();		
     _nop_();
     _nop_();
     EN = 0;
     _nop_();
     _nop_();
   } while (d & 0x80);

   BUSDDIR |= DSP_PIN_MASK;  //Coloca como saida
   //   Pronto();
   RW = 0;
   RS = 0;
   _nop_();
   BUSDISPOUT &= ~DSP_PIN_MASK;  //Zera bits d7-d4
   BUSDISPOUT |= (a & 0xf0); //LCD_OUT |= (ByteToSend & 0xF0);
   EN = 1;
   _nop_();		
   _nop_();
   _nop_();
   EN = 0;
   _nop_();		
   _nop_();
   _nop_();
   BUSDISPOUT &= ~DSP_PIN_MASK;  //Zera bits d7-d4
   BUSDISPOUT |= ((a & 0x0f)<< 4); //LCD_OUT |= ((ByteToSend & 0x0F) << 4);
   EN = 1;
   _nop_();		
   _nop_();
   _nop_();
   EN = 0;
   //DELAY100; // 100us		
}

//-----------------------------------------------------------

void WRDISPD(unsigned char a) {

   register char d; 
   BUSDDIR &= ~DSP_PIN_MASK;  //Coloca como entradas
   RW = 1;
   RS = 0;
   _nop_();
   _nop_();
   do {
     EN = 1;
     _nop_();
     _nop_();
     d =  BUSDISPIN;
     EN = 0;
     _nop_();
     _nop_();		
     _nop_();
     EN = 1;
     _nop_();
     _nop_();		
     _nop_();
     EN = 0;
     _nop_();
     _nop_();
   } while (d & 0x80);

   BUSDDIR |= DSP_PIN_MASK;  //Coloca como saida
   RW = 0;
   RS = 1;
   _nop_();
   BUSDISPOUT &= ~DSP_PIN_MASK;  //Zera bits d7-d4
   BUSDISPOUT |= (a & 0xf0); //LCD_OUT |= (ByteToSend & 0xF0);
   EN = 1;
   _nop_();		
   _nop_();		
   _nop_();
   EN = 0;
   _nop_();		
   _nop_();		
   _nop_();
   BUSDISPOUT &= ~DSP_PIN_MASK;  //Zera bits d7-d4
   BUSDISPOUT |= ((a & 0x0f)<< 4); //LCD_OUT |= ((ByteToSend & 0x0F) << 4);
   EN = 1;
   _nop_();		
   _nop_();		
   _nop_();
   EN = 0;
   //DELAY100; // 100us		
}

unsigned char RDDISPD(void) {

   register char d; 
   BUSDDIR &= ~DSP_PIN_MASK;  //Coloca como entradas
   RW = 1;
   RS = 0;
   _nop_();
   _nop_();
   do {
     EN = 1;
     _nop_();
     _nop_();
     d =  BUSDISPIN;
     EN = 0;
     _nop_();		
     _nop_();
     _nop_();
     EN = 1;
     _nop_();		
     _nop_();
     _nop_();
     EN = 0;
     _nop_();
     _nop_();
   } while (d & 0x80);

   RW = 1;
   RS = 1;
   _nop_();		
   _nop_();
   EN = 1;
   _nop_();		
   _nop_();
   d =  BUSDISPIN & 0xf0; // pega o mais
   EN = 0;
   _nop_();		
   _nop_();
   EN = 1;
   _nop_();		
   _nop_();
   d |=  ((BUSDISPIN>>4) & 0x0f);
   EN = 0;
   BUSDDIR |= DSP_PIN_MASK;  //Coloca como saida
   return d;
   //DELAY100; // 100us		
}


void PrintDisp(unsigned char a) {
  char i,c;
  if (a==LF) {
      if (cur & 0x40){
      } else {
        cur = 0xC0;
        WRDISPC(0xC0);
        return;
      } 
      cur = 0xc0;
      for(i=0;i<16;i++) {
        WRDISPC(cur);
        c = RDDISPD();
        WRDISPC(cur & 0xBF);
        WRDISPD(c);
        WRDISPC(cur);
        WRDISPD(0x20);
       cur++;
      }
      cur = 0xc0;
      WRDISPC(0xC0);
  } else if (a==FF){
    WRDISPC(0x01);	  //apaga
    cur=0x80;
  } else if (a == CR) {
    cur &=0xC0;
    WRDISPC(cur);
  } else {
    if(cur==0x90) {
      cur = 0xc0;
      WRDISPC(0xC0);
      WRDISPD(a);
      cur++;
    } else if(cur==0xd0) {
      cur = 0xc0;
      for(i=0;i<16;i++) {
        WRDISPC(cur);
        c = RDDISPD();
        WRDISPC(cur & 0xBF);
        WRDISPD(c);
        WRDISPC(cur);
        WRDISPD(0x20);
       cur++;
      }
      cur = 0xc0;
      WRDISPC(0xC0);
      WRDISPD(a);
      cur++;
    } else {
      WRDISPD(a);
      cur++;
    }
  }

}

