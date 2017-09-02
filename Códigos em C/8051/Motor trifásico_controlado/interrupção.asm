; USAR INTERRUPÇÃO DO TIMER 0 NO MODO 0
; CRISTAL DE 16,5 MHz


dseg	at	8
cont:	ds	1
cont2:	ds	1


extrn code (task1, task2)
      cseg  at  000BH
      mov   TH0, #(256-16)
      call  task1
      inc	  cont
      mov	  a,cont
      cjne  a,#67,fim
      mov   cont,#0
      inc   cont2
      mov   a,cont2
      cjne  a,#8,fim
      call  task2
      mov   cont2,#0
fim:     
      reti

      end