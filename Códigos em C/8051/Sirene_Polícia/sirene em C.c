
/*

sirene da polica em C
Desenvolvido por Marcele Fonseca
______________________________

timer 0 som modo 0
timer inter modo 1
N=24Mhz/12*256*1/intervalinho
f1:450Hz e f2:1250Hz
Nf1=31250/450=69
Nf2=31250/1250=25
intervalinho=44
Tintervalo=200ms/44=4,545ms
Nint=7812,5/1/4,545=35,5 aproximadamente 36
*/

#include <regx52.H>
sbit      som=P1^0;
sbit      ch1=P3^7;
bit       flag;

void main(void){
 unsigned char var ;
 unsigned char fdiv;
 TMOD=0x10;
 TH0= (256-69);
 TH1= (256-25);
 var =(256-69);
 fdiv=69;
 TR0=1;
 TR1=1;


   while(1){
		if(TF0==1){
             TF0=0;
             TH0=var;
             som=~ som;
                    if(ch1==0){
                     	while(1);
                    }    
          }else{
	            if(TF1==1){
	               TF1=0;
	               TH1=(256-25);
	               if(flag==1){
	                  fdiv ++;
	                  if(fdiv==60){
	                     flag=~ flag;
	                     var=(0-fdiv);
	                     if(ch1==0){
	                     	while(1);
	                     }
	                   }else{
		                	var=(0-fdiv);
		                    if(ch1==0){
		                    	while(1);
		                    }
	                  	}
	               }else{
		                fdiv--;
		                if(fdiv==25){
		                   flag=~ flag;
		                    var=(0-fdiv);
		                     if(ch1==0){
		                     while(1);
		                    }
		                 }else{
		                    var=(0-fdiv);
		                    if(ch1==0){
		                    	while(1);
		                    }
		                  }
	                }
	            }else{
	             	if(ch1==0){
	                     while(1);
	                }
	             }
           }
   }
}
