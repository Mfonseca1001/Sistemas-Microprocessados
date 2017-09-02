/*
Sensor de Temperatura com LM35
Desenvolvido por Marcele Fonseca
*/


#include "io430.h"
//#include "stdio.h"  //usado por causa do printf

#define LEDVM      P1OUT_bit.P0  //LED vermelho ADC
#define LEDVD      P1OUT_bit.P6  //LED verde  PWM
#define ONOFF     (P1IN & BIT3)   //CHAVE na placa Liga desliga sistema

#define SAIDA P2OUT

#define DSP0  P1OUT_bit.P7
#define DSP1  P1OUT_bit.P5
#define DSP2  P1OUT_bit.P4

#define FATOR (100.0/682.0)

char tabela[10]={0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90};
char CODVET[3];

int valor;
int r,r1, r2, r3;

float t;
int t1;
char flagdisparo = 0;
int main( void )
{
  // Stop watchdog timer to prevent time out reset
   WDTCTL = WDTPW + WDTHOLD;
   
   BCSCTL1 = CALBC1_1MHZ;   							// Set 1Mhz
   DCOCTL = CALDCO_1MHZ;
   P1OUT = 0xB0;
   P1DIR = (BIT0 + BIT6 + BIT4 + BIT5 + BIT7); 			//P1.0 = Output LED vermelho P1.6 = output LED verde
   P1REN = BIT3 ;       								//pull-up/pull-down  na chave e sensor de freio e sensor de velocidade
   P1OUT |= (BIT3 );        							//pull-up  na chave e sensor de freio, pull-down sensor de velocidade
   P2SEL = 0x00;   										//todas portas IO  , no reset xin e xout são ativos
   P2DIR = 0xFF;
    
   TA0CTL  = TASSEL_2 | ID_3 | MC_1;    				// SMCLK/8 modo UP
   TA0CCR0 = 694-1;                    					//1000000/8/25000 = 5Hz 
   TA0CCTL0 = CCIE;                     				//Habilita interrupção
   
   ADC10CTL1 = INCH_1 + ADC10DIV_1 + ADC10SSEL_3;      	//entrada A1 ADC10CLK=SMCLK/2 500Khz
   ADC10CTL0 = SREF_1 + ADC10SHT_3 + REFON + ADC10ON;  	//Sample Hold   64 * 2us = 128us REF 1.5 V 
   __delay_cycles(100); 								//100us
   __bis_SR_register(GIE);              				//Habilita geral
   
   ADC10AE0 = BIT1;  									//USAR A1

   while(1) {
     if (flagdisparo == 1) {
       flagdisparo = 0;
       ADC10CTL0 |=   (ENC + ADC10SC);  				//dispara conversão
       while (!(ADC10CTL0 & ADC10IFG)); 				//aguarda o fim da conversão
       valor = ADC10MEM;                				//Ler valor convertido
       t =(valor*FATOR);
       t1 = (t*10);
       r =(t1/100);
       CODVET[2] = tabela[r]; 							// dezena
       r1 = (t1%100);
       r2 = (r1/10);
       CODVET[1] = tabela[r2]; 							// unidade
       r3 = (r1%10);
       CODVET[0] = tabela[r3]; 							// decimal            
     }  
   }
}

#pragma vector=TIMER0_A0_VECTOR  						//0xFFFA Timer1_A CC0 
__interrupt void macacolouco (void) {  					//180Hz
  static char cont = 0;
  static char stado = 0;
  switch(stado) {
  case 0:
    DSP0 = 1;
    SAIDA = CODVET[1];
    SAIDA &= ~BIT7;
    DSP1 = 0;
    stado = 1;
    break;
  case 1:
    DSP1 = 1;
    SAIDA = CODVET[2];
    DSP2 = 0;
    stado = 2;
    break;
  case 2:
    DSP2 = 1;
    SAIDA = CODVET[0];
    DSP0 = 0;
    stado = 0;
    break;
  }
  
   cont++;
 if (cont >= 180) {
   
    LEDVM = ~LEDVM;
    flagdisparo = 1;
   // ADC10CTL0 |=   (ENC + ADC10SC);  //dispara conversão
    cont= 0;
  }  
}
