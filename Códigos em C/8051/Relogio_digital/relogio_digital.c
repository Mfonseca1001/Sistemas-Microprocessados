/******************************************************
Relógio Digital em C
Desenvolvido por Marcele   
Dia: 16/08/2016
******************************************************/

sfr P0=0x80;    //definição de portas
sfr P1=0x90;
sfr P2=0xA0;
sfr P3=0XB0;

sbit dsp0=P2^0;  //definicação de variáveis
sbit dsp1=P2^1;
sbit dsp2=P2^2;
sbit dsp3=P2^3;
sbit dsp4=P2^4;
sbit dsp5=P2^5;
sbit dsp6=P2^6;
sbit dsp7=P2^7;
sbit chv1=P1^0;
sbit chv2=P1^1;

bit  flg;
bit  flg_DP0;
bit  flg_DP1;
bit  flg_DP2;
bit  flg_DP3;
bit  flg_DP4;
bit  flg_DP5;
bit  flg_DP6;
bit  flg_DP7;


void main(void){

unsigned char seg=0;   //variáveis char, de 0-255, tudo inteiro
unsigned char min=0;
unsigned char hor=0;
unsigned char dia=16;
unsigned char mes=8;
unsigned char ano=16;
unsigned char cod0;
unsigned char cod1;
unsigned char cod2;
unsigned char cod3;
unsigned char cod4;
unsigned char cod5;
unsigned char cod6;
unsigned char cod7;
unsigned char tabela[]= {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xD8, 0x80, 0x90};
unsigned char cont;
int i;

flg_DP0=1;

while(1){
   if(flg_DP0==1){
      dsp0=1;
      P0=cod1; 
	  dsp1=0;
	  flg_DP0=0;
      flg_DP1=1;
     
   }else{ 
      if(flg_DP1==1){
         dsp1=1;
      	 P0=cod2; 
	  	 dsp2=0;
	 	 flg_DP1=0;
         flg_DP2=1;
       }else{
           if(flg_DP2==1){
              dsp2=1;
      		  P0=cod3; 
	          dsp3=0;
	          flg_DP2=0;
              flg_DP3=1;
           }else{
               if(flg_DP3==1){
                  dsp3=1;
      			  P0=cod4; 
             	  dsp4=0;
	              flg_DP3=0;
                  flg_DP4=1;
               }else{
                  if(flg_DP4==1){
                     dsp4=1;
      				 P0=cod5; 
	                 dsp5=0;
	                 flg_DP4=0;
                     flg_DP5=1;
                  }else{
                     if(flg_DP5==1){
                   	    dsp5=1;
      				    P0=cod6; 
	  				    dsp6=0;
	  			     	flg_DP5=0;
      				    flg_DP6=1;
                     }else{
                        if(flg_DP6==1){
                           dsp6=1;
     					   P0=cod7; 
	                       dsp7=0;
	                       flg_DP6=0;
                           flg_DP7=1;
                        }else{
                           if(flg_DP7==1){
                              dsp7=1;
     						  P0=cod0; 
	 					      dsp0=0;
	  						  flg_DP7=0;
   						      flg_DP0=1;
                           }
                    	}	
                	 }
              	   }
            }
          }
        }
      }
//delay
      for(i=0;i<350;i++){}
         cont++;
            if(cont==4){
               cont=0;
               if(chv1==0){
                  flg=0;
               }else{
                 if(chv2==0){
                    flg=1;
                 }
               }
               if(flg==1){
                  cod1=tabela[ano/10];
                  cod0=tabela[ano%10];
                  cod2=0xBF;
                  cod4=tabela[mes/10];
                  cod3=tabela[mes%10];
                  cod5=0xBF;
                  cod7=tabela[dia/10];
                  cod6=tabela[dia%10]; 
               }else{
                  cod1=tabela[seg/10]; //dezena
                  cod0=tabela[seg%10]; //unidade
                  cod2=0xBF;
                  cod4=tabela[min/10];
                  cod3=tabela[min%10];
                  cod5=0xBF;
                  cod7=tabela[hor/10];
                  cod6=tabela[hor%10];
               }
                    
            }
      seg++;
      if(seg>=60){
         seg=0;
         min++;
            if(min>=60){
               min=0;
               hor++;
                  if(hor>=24){
                     hor=0;
                     dia++;
                     if(mes==1||mes==3||mes==4||mes==7||mes==8||mes==10){
                           if(dia>31){
                              dia=1;
                              mes++;
                           }
                       }else{
                           if(mes==5||mes==6||mes==9||mes==11){
                              if(dia>30){
                                 dia=1;
                                 mes++;
                              }
                           }else{
                              if(mes==12){
                                if(dia==31){
                                   dia=1;
                                   mes=1;
                                   ano++;
                                   if(ano>99){
                                      ano=0;
                                   }
                                }
                                }else {
                                  if(mes==2){
                                    if(ano%4==0){
                                         if(dia>29){
                                          dia=1;
                                          mes=3;
                                         }
                                    }else{
                                      if(dia>28){
                                         dia=1;
                                         mes=3;
                                      }
                                    }
                                  }
                                 }
                           }
                       }

                  }
            }
      }
   }
}

