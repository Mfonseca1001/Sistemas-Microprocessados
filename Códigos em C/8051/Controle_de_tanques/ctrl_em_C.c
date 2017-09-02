/**********************************************
Controle de tanques na linguegem C
Desenvolvido por Marcele
dia: 02/08/2016
***********************************************/
sfr	P1 = 0X90;
sfr	P3 = 0XB0;
//Define as varíaveis

sbit	SPS=P3^0	;	//sensor de pressão	
sbit	STS=P3^1	;	//sensor de tanque seco		
sbit	STV=P3^2	;	//sensor de tanque vazio inferior
sbit	STC=P3^3	;	//sensor de tanque cheio inferior
sbit	STCV=P3^4	;	//sensor de tanque vazio superior
sbit	STCC=P3^5	;	//sensor de tanque cheio superior	
sbit	CHUV=P3^6	;	//chuveiro/válvula do vizinho
sbit	CHUS =P3^7	;	//chuveiro/válvula do síndico
sbit	V1 =P1^0	;
sbit	BM =P1^1	;
sbit	ALMV =P1^2	;
sbit	ALMS =P1^3	;
sbit	LED =P1^4	;

	


void falha(void){
	V1 = 1;				//desliga a valvula		
	BM = 1;				//desliga a bomba
	ALMV = 1;			//desliga o alarme do vizinho
	ALMS= 1;			//desliga o alarme do síndico	
	LED = 0;			//indicação visual
	while(1);
}

void main(void){
   V1 = 1;				//DESLIGA OS ATUADORES
   BM = 1	;
   ALMV = 1;
   ALMV = 1 ;
   	
 while(1){
 	
	  if(SPS==0){
	    	if(STV==0){
	      		if(STC==0){
	        		if(STV==0){
	           			V1 = 1;
	        		}else{
	          			falha();
					 } 
	      		}		
	    	}else{
	     		V1 = 0;
	    	 }
	  }else{
	    V1 = 1;
	   }
	  if(STS==0){
	    	if(STCC==0){
	      		if(STCV==0){
	        		BM = 1;
	      		}else{
	         		falha();
	      		 }
	    	}else{
	      		if(STCV==0){
	      	 	}else{
	        		BM = 0;
	      	  	 }	
	    	 }
	  }else{
	     BM = 1;
	   }
	  if(STS==0){
	     ALMS = 1;
	     ALMV = 1;
	  }else{
	     if(CHUV==0){
	        ALMS = 0;
	        ALMV = 0;
	     }else{
	        ALMV = 1;
	         if(CHUS==0){
	         	  ALMS = 0;
	         }else{
	          	ALMS = 1;
	          }
	      }	
	   }
	}
}
