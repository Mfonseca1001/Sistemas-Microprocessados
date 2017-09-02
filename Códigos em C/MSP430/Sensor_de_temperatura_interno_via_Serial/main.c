/*
https://www.youtube.com/watch?v=2p8rZNAjUjk
http://dbindner.freeshell.org/msp430/adc_g2553.html#_analog_to_digital_conversions_against_a_2_5v_reference
http://coecsl.ece.illinois.edu/ge423/
*/

/* 
Sensor de Temperatura interno via serial
Desenvolvido por Marcele Fonseca
*/

#include "io430.h"
#include <math.h>
#include <string.h>
//#include "defines.h"
#include "stdarg.h"
#include <stdio.h>
#include <stdlib.h>

#define LED0       P1OUT_bit.P0  //LED vermelho ADC
#define LED1       P1OUT_bit.P6  //LED verde  PWM
#define ONOFF     (P1IN & BIT3)   //CHAVE na placa Liga desliga sistema 


#define MCU_CLOCK       1000000L

void Init_UART(unsigned long baudrate);
//float teta,teta2;

char FLAGS = 0;
//#define TICKCONTROL (FLAGS & BIT0)
//#define TICKCONTROL_CLEAR FLAGS &= ~BIT0
//#define TICKCONTROL_SET FLAGS |= BIT0
#define TICK (FLAGS & BIT1)
#define TICK_CLEAR FLAGS &= ~BIT1
#define TICK_SET FLAGS |= BIT1

// Serial variaveis
//char uuu[35]="X";
#define BUF_SIZE 52
//#define BUF_SIZE_P 40
__no_init char bufserial[BUF_SIZE];
__no_init char txbuff[64];
__no_init int contp;

//__no_init char bufout[64]; //="987654321";

char *ptr;
//char UART_flag = 0;
unsigned char nbytes = 0;
char txindex;
char recebeu = 0;
char stado = 0;
int timerrec;
char donesending = 1; //já enviado
int UpperCounter;

int getchar(void);
int putchar(int);

/*
#define K2 300000.0F      //  RPM = 60*f => 60/t ... t = N*TINT, K2 = 60/TINT, RPM = K2/N
#define K2 296400.0F   // 60/202,429us
Ttimer = 0,50607287us

extern WORD RevolutionTimeSave;
extern WORD RevolutionTime;
CAL_ADC_25T85 0x0010 word INCHx = 0x1010, REF2_5 = 1, TA = 85°C
CAL_ADC_25T30 0x000E word INCHx = 0x1010, REF2_5 = 1, TA = 30°C
CAL_ADC_15T85 0x000A word INCHx = 0x1010, REF2_5 = 0, TA = 85°C
CAL_ADC_15T30 0x0008 word INCHx = 0x1010, REF2_5 = 0, TA = 30°C

*/
__no_init unsigned short TLV_ADC_Gain_Factor @0x10DC;  
__no_init unsigned short TLV_ADC_Offset @0x10DE;
__no_init const unsigned short CALADC_25T30 @ 0x10E8u;  
__no_init const unsigned short CALADC_25T85 @ 0x10EAu;

__no_init const unsigned short CALADC_15T30 @ 0x10E2u;
__no_init const unsigned short CALADC_15T85 @ 0x10E4u;

__no_init volatile unsigned __READ char TLV_ADC10_1_LEN @ 0x10DB;

/*
char rdkeyboard(char *);
int putchar(int);
int getchar (void);

float coeficiente;
	float codetotempcore(int n) {
		return((n - (int)CAL_ADC_25T30) * ((float)(85-30)/(float)(CAL_ADC_25T85 - CAL_ADC_25T30)) + 30.0);
		uuu[2]=(char)n;
		return((n - (int)CALADC_25T30) * coeficiente + 30.0);
	}

char mens[50]="TESTE DA SERIAL LAUCHPAD\n";
*/


void main( void )
{
    P1DIR = (BIT0 | BIT6);
   // Stop watchdog timer to prevent time out reset
    int d;
    float f;
    int valor;
    float TempF;
    
    WDTCTL = WDTPW + WDTHOLD;
  	BCSCTL1 = CALBC1_1MHZ;
  	DCOCTL = CALDCO_1MHZ;
  
  	TA0CTL = TASSEL_2 | ID_3 | MC_1;
  	TA0CCR0 = 1250-1;
  	TA0CCTL0 = CCIE;
    
/*    
	BCSCTL1 = CALBC1_16MHZ;                    	//Set range
    DCOCTL = CALDCO_16MHZ;
 
    BCSCTL1 = CALBC1_1MHZ;                    	//Set range
    DCOCTL = CALDCO_1MHZ;

    TA0CTL  = TASSEL_2 + ID_0 + MC_1;    		//SMCLK/1 modo UP
    TA0CCR0 = 833-1;                    		//1200 * 16 Hz 
    TA0CCTL0 = CCIE;                     		//Habilita interrupção
  
  
    TA1CCTL0 = CCIE;                			//Habilita interrupção
    TA1CTL   = TASSEL_2 + ID_0 + MC_3 +  TAIE;  //SMCLK, up/dowm mode /1
    
 */   
    P1OUT = 0x00;                    			// Acende LED vermelho----Não inicializado no PUC
	//P1DIR   |= (BIT0 + BIT6);        			// P1.0 = Output LED vermelho P1.6 = output LED verde
    P1REN   |= (BIT3 + BIT4 + BIT7); 			// pull-up/pull-down  na chave e sensor de freio e sensor de velocidade
    P1OUT   |= (BIT3 + BIT7);        			// pull-up  na chave e sensor de freio, pull-down sensor de velocidade
   
    P2SEL = 0x00;   // todas portas IO  , no reset xin e xout são ativos

    Init_UART(9600);
//------------------------------------------------------------------------------
// Conversor AD
// Vamos usar P1.2 A1 | P1.3 A2 | 5Mhz 16/8 = 2Mhz tsample > (RS + 2 kOhms) × 7.625 × 27 pF
//------------------------------------------------------------------------------
/*  
   ADC10CTL0 = SREF_1 + ADC10SHT_3 + REF2_5V + REFON + ADC10ON ;  			//REF 2.5 V Sample Hold  32us = 0.5 * 64
   ADC10CTL1 =  INCH_10 + ADC10DIV_7 + ADC10SSEL_3 + CONSEQ_0;             // SMCLK 16Mhz / 8 = 2Mhz   0.5us  Tempo total 13 * 0.5 + 32us =  38,5us           
   ADC10AE0 = BIT4 + BIT5;  //USAR A4 e A5
*/  
   //__delay_cycles(1000);                  // Delay for reference start-up
   //__bis_SR_register(GIE); 
   printf("\nPressione a chave");
   while(ONOFF);
    
   printf("\x1b[2J");       //apaga a tela
   printf("\x1b[1;1H");     //Posiciona Cursor  
   printf("MEDIDOR DE TEMPERATURA DO LAB10\n\n");
   printf("\n");
/*   printf("1-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("2-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("3-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("4-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("5-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("6-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("7-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("8-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("9-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
   printf("Entre com a opção em float:");
   scanf("%f",&f);
   printf("\nA opção selecionada foi:%f\n",f);
   
   getchar();
*/  
   ADC10CTL1 = INCH_10 + ADC10DIV_1 + ADC10SSEL_3;                   // Temp Sensor ADC10CLK=SMCLK/2 500Khz
   ADC10CTL0 = SREF_1 + ADC10SHT_3 + /*REF2_5V + */REFON + ADC10ON;  // Sample Hold   64 * 2us = 128us REF 1.5 V 
   __delay_cycles(100); //100us
 
   while (1) {
     
     ADC10CTL0 |=   (ENC + ADC10SC);  //dispara conversão
     
     while (!(ADC10CTL0 & ADC10IFG));
     ADC10CTL0 &= ~ADC10IFG;
     
     valor = ADC10MEM;
     
     TempF = (float)(((long)valor - CALADC_15T30) * (85 - 30)); //
     TempF /= (CALADC_15T85 - CALADC_15T30);
     TempF += 30.0f;
     
     /*
     TempF = (float)(((long)valor - CALADC_25T30) * (85 - 30)); //
     TempF /= (CALADC_25T85 - CALADC_25T30);
     TempF += 30.0f;
     */
     
     /*
     temp = (int)(TempF);
     TempF = (((int)valor - CALADC_15T30) * (float)(85-30)/(CALADC_15T85 - CALADC_15T30) + 30);
     TempF = (valor - CAL_ADC_25T30) * ((float)(85-30)/(CAL_ADC_25T85 - CAL_ADC_25T30)) + 30.0;
     */
    printf("TEMPERATURA = %4.1foC ",TempF);
    if(TempF >=29.2 && TempF<30.7){
    LED0 =0;
    }
     if(TempF >= 30.7 && TempF <32.2){
     LED0 =1;
     __delay_cycles(5000000);
     printf("                                       TEMPERATURA OK" );
     }else if(TempF >= 32.2){
     LED0 = 0;
     __delay_cycles(5000000);
      printf("TEMPERATURA = %4.1foC ",TempF);
     }
     printf("ADC = %u \r",valor);
  }
}  
/*
int getkey(void) {
  int c; 
  while (!(IFG2&UCA0RXIFG));  // USCI_A0 requested RX interrupt (UCA0RXBUF is full)
  IFG2 &= ~UCA0RXIFG;
  c = UCA0RXBUF;
  return c;
}
*/
int getchar(void) {
  int c;
  static char flag = 0;
  if (flag == 1) { flag = 0; return 0x0a; }
  while (!(IFG2&UCA0RXIFG));  // USCI_A0 requested RX interrupt (UCA0RXBUF is full)
  IFG2 &= ~UCA0RXIFG;
  c = UCA0RXBUF;
  if (c==0x0d ) { putchar(0x0a); flag = 1; } else putchar(c);
  return c;
}

int putchar(int c) {
   while(!(IFG2&UCA0TXIFG));		// USCI_A0 requested TX interrupt
   IFG2 &= ~UCA0TXIFG;   // clear IFG
   UCA0TXBUF = c;
   if (c == 0x0a) {
     while(!(IFG2&UCA0TXIFG));		// USCI_A0 requested TX interrupt
     IFG2 &= ~UCA0TXIFG;   // clear IFG
     UCA0TXBUF = 0x0d;
   }
   return c;
}

/*
USCI_A Initialization - UART mode
Assumes SMCLK is running at 16MHz
Inputs: baud rate and os = 0 or 1 indicating whether to use oversampling mode
CLK   Baud Rate UCBRx UCBRSx UCBRFx
16Mhz 9600      1666  6      0
16MHz 9600      104   0      3  com oversample
*/
void Init_UART(unsigned long baudrate) {
  float n = 0;
  char BRFx = 0;
  int BRx = 0;
  n = (float)(MCU_CLOCK)/baudrate;
  UCA0CTL1 = UCSSEL_2 + UCSWRST;           // source SMCLK, hold module in reset
  BRx = (int)(n/16);										// Baud rate selection
  BRFx = (int)(((n/16)-BRx)*16 + 0.5);	// Modulator selection
  UCA0MCTL = UCOS16 + (BRFx<<4);
  UCA0BR0 = BRx % 256;
  UCA0BR1 = BRx / 256;
  UCA0CTL1 &= ~UCSWRST;                 // Release USCI module for operation
  //msp430G2553
  P1SEL |= 0x6;
  P1SEL2 |= 0x6;
  IFG2 |= (UCA0TXIFG);     // Clear pending interrupt flags
  IFG2 &= ~(UCA0RXIFG);     // Clear pending interrupt flags
  //  IE2 |= (UCA0TXIE + UCA0RXIE);         // Enable USCI_A0 TX interrupt  Enable USCI_A0 RX interrupt
}

