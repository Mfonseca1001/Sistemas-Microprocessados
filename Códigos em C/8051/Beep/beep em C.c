/*
Programa de BEEP em C
Desenvolvido por Marcele Fonseca
Saída do Som, porta p1.0
*/


#include <regx52.H>
sbit      som=P1^0;

void main(void){
 unsigned char cont=0;
 TMOD=0x20;
 TH0= (256-233);
 TH1= (256-99);
 cont =0;
 TR0=1;

while(1){
          if (TF0==1){
             TF0=0;
             TH0= (256-233);
             cont ++;
             if(cont==12){
                cont=0;
                TR1=~TR1;
             }           
          
          }else{
             if(TF1==1){
                TF1=0;
                som=~ som;

             }
           }      


  }
}


