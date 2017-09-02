/*
Sirene do Bombeiro em C
Desenvolvido por Marcele Fonseca
*/

#include <regx52.H>
sbit      som=P1^0;
bit       flag;

void main(void){
 unsigned char cont=0;
 TMOD=0x20;
 TH0= (256-233);
 TH1= (256-124);
 cont =0;
 TR0=1;
 TR1=1;

while(1){
          if (TF0==1){
             TF0=0;
             TH0= (256-233);
             cont ++;
             if(cont==12){
                cont=0;
                if(flag==1){
                   TH1= (256-124);
                   flag =~ flag; 
                }else{
                   TH1= (256-233);
                   flag =~flag;
                }
                
             }           
          
          }else{
             if(TF1==1){
                TF1=0;
                som=~ som;

             }
           }      


  }
}
