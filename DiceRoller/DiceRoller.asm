; Author : An0n9m

.include <m324pdef.inc>

.def SlopReg = R16
.def TempReg = R18 ; Temporary register for calculations
.def Counter = R19 ; Counter for calculations
.def DiceRoll = R20 ; Store dice roll value
.def Tmp = R21
.EQU	one =   0b00001000
.EQU	two =   0b00010100
.EQU	three = 0b00011100
.EQU	four =  0b01100011
.EQU	five =  0b01101011
.EQU	six =   0b01110111

.org 0x0
 rjmp Init

.org INT0Addr ; External Interrupt 0 vector
 rjmp INT0_ButtonPressed

Init:
  ; Initialize Ports
  ldi Tmp, HIGH(RAMEND) ; Init MSB stack
  out SPH,Tmp
  ldi Tmp, LOW(RAMEND) ; Init LSB stack
  out SPL,Tmp
  ldi SlopReg, 0b11111111 ; Set PORTB pins as output
  out DDRB, SlopReg ; Set DDRB

  ldi r16, 0x00
  out DDRD, r16
  ldi r16, 0b00000100
  out PortD, r16

  
  ldi SlopReg, 0b00000000 ; Clear PORTB initially
  out PortB, SlopReg ; Clear PORTB

  ldi r16, 0x2 ; 0x2 so trigger on falling edge
  sts EICRA, r16 ; Store the value from r16 into the EICRA register to configure INT0  

  ldi r16, 1<<INT0               ; Enable INT0 interrupt
  out EIMSK, r16                   ; Enable INT0 interrupt

  sei ; Enable global interrupts
 
  rjmp count

  INT0_ButtonPressed:
  inc Counter

  ldi Tmp, 0x1 ; Comparison
  cp Counter, Tmp
  breq isOne

  ldi Tmp, 0x2
  cp Counter, Tmp
  breq isTwo

  ldi Tmp, 0x3
  cp Counter, Tmp
  breq isThree
    
  ldi Tmp, 0x4
  cp Counter, Tmp
  breq isFour
    
  ldi Tmp, 0x5
  cp Counter, Tmp
  breq isFive
    
  ldi Tmp, 0x6
  cp Counter, Tmp
  breq isSix

  isOne: ; Setup DiceRoll to output correctly
  ldi DiceRoll, one
  rjmp output
  isTwo:
  ldi DiceRoll, two
  rjmp output
  isThree:
  ldi DiceRoll, three
  rjmp output
  isFour:
  ldi DiceRoll, four
  rjmp output
  isFive:
  ldi DiceRoll, five
  rjmp output
  isSix:
  ldi DiceRoll, six
  rjmp output

  output:
  out PortB, DiceRoll ; Light up LEDs based on DiceRoll
  sei ; Enable global interrupts
  rjmp count ; Endless loop

count:
  ldi Counter, 5    ; Load Counter with 5
loop:
  dec Counter        ; Decrement Counter
  brne loop          ; Branch to loop if Counter is not zero
  ldi Counter, 5     ; Load Counter with 5 again
  rjmp loop          ; Jump back to the beginning of the loop