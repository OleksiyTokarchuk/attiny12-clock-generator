/*
 * generator.S
 *
 * Created: 17.05.2020 10:25:11
 * Author : Tokarchuk Oleksiy
 */ 

.include "tn12def.inc"

.def TEMP = R16					;; to use as RAM
.def MASK = R17					;; to store bit MASK for pin invertion

.cseg
.org 0x00 rjmp RESET			        ;; Reset interrupt handler
.org 0x01 rjmp EXT_INT0				;; IRQ0 interrupt handler
.org 0x02 rjmp PIN_CHANGE			;; Pin change interrupt handler
.org 0x03 rjmp TIM0_OVF				;; Timer0 overflow interrupt handler
.org 0x04 rjmp EE_RDY				;; EEPROM Ready interrupt handler
.org 0x05 rjmp ANA_COMP				;; Analog Comparator interrupt handler

RESET:
	ldi MASK, 0b00000010			;; define bit mask for set/reset timer operation
	ldi TEMP, 0xFF 
	out DDRB, TEMP				;; port as output
	ldi TEMP, 0b00000100
	out TCCR0, TEMP				;; clock CK/256
	ldi TEMP, 0b00000010
	out TIMSK, TEMP				;;TOIE enable
	out TIFR, TEMP				;;TOV0 enable
	ldi TEMP, 163
	out TCNT0, TEMP				;; count from 163 to generate 42 KHz with duty 50%
	cbi 0x18, 0x01				;; PB1 initial 0V
	cbi 0x18, 0x00				;; PB0 initial 0V 
	sei							;; enable interrupts
	rjmp MAIN
EXT_INT0:
	rjmp MAIN
PIN_CHANGE:
	rjmp MAIN
TIM0_OVF:
	cli							
	ldi TEMP, 163				
	out TCNT0, TEMP				;; reload value to generate 42Hz 50% duty
	in R16, PORTB				;; read port register
	eor R16, MASK				;; perform xor with mask
	out PORTB, R16				;; out inverted bit
	sei
	reti
EE_RDY:
	rjmp MAIN
ANA_COMP:
	rjmp MAIN
MAIN:
	;;Software based Main Cycle Delays
	sbi 0x18, 0x00
	nop
	nop
	;;additional nop to precisious delay adjust start
	nop
	nop
	nop
	nop
	nop
	;;additional nop to precisious delay adjust end
	rcall DELAY
	cbi 0x18, 0x00
	;;additional nop to precisious delay adjust start
	nop
	nop
	nop
	nop
	nop
	;;additional nop to precisious delay adjust end
	rcall DELAY 
	rjmp MAIN
DELAY:							;;Software delay subroutine
    ldi  r18, 63
    ldi  r19, 50
L1: dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
	ret
