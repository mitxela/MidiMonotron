.include "tn85def.inc" 
rjmp init


.org $000A
	clr r16
	out TCNT0,r16

	tst XL
	breq intEnd


	;sub ZL,r5
	;sbci ZH,0
	
	dec r7
	brne arpeg0
	mov r7,r8
	
	subi r22,1
	brcc mod1
	ldi r22,31
mod1:
	
	ldi ZH, HIGH(modLookup*2)
	ldi ZL,  LOW(modLookup*2)
	
	add ZL, r6
	add ZL, r22
	lpm r5,Z
	

	
	mov r18,r3
	add r18,r5
	out OCR1B,r18


arpeg0:
	

	inc r9
	cp r9,r4
	brcs intEnd
	clr r9




	cp XL,YL
	brne arpeg1
	clr YL
arpeg1:
	ld r19, Y+

cpi XL,1
breq intEnd


	rcall setNote


intEnd:
	reti




init:
	ldi r16, 0;0b00001010
	out DDRB,r16

	ldi r16,0b00000100
	out PORTB,r16



	; Stack Pointer Setup Code 
	;ldi r16,HIGH(RAMEND)
	;out SPH,r16
	;ldi r16, LOW(RAMEND)
	;out SPL,r16





	ldi r16,0
	out TCNT0,r16
	ldi r16, (1<<CS02|1<<CS00)	;clk/1024
	out TCCR0B, r16
	ldi r16, 8
	out OCR0A,r16
	ldi r16, (1<<OCIE0A)
	out TIMSK,r16


	ldi r16,(1<<PLLE|1<<PCKE)
	out PLLCSR,r16

	ldi r16, (1<<PWM1A|1<<COM1A1|1<<CS10)
	out TCCR1,r16
	ldi r16,(1<<PWM1B|1<<COM1B1)
	out GTCCR,r16

	ldi r20,0
	out OCR1A,r20
	ldi r16,128
	out OCR1B,r20
	ldi r16,255
	out OCR1C,r16


	ldi XH,1
	ldi XL,0
	ldi YH,1
	ldi YL,0

	clr r20
	clr r22
	sbiw Y,1
	st Y+,r20

	
	
	ldi r16,45
	mov r4,r16

	ldi r16, 0
	mov r6,r16
	mov r3,r16

	ldi r16,127
	mov r5,r16
	mov r14,r16

	ldi r16,4
	mov r8,r16
	
main:
	sei

	rcall receiveByte

	cpi r20,0b10010000
	breq noteon

	cpi r20,0b10000000
	breq noteoff

	cpi r20,0b10110000
	breq midiCC

	cpi r20,0b11100000
	breq pitchBend

	cpi r20,0b11010000
	breq afterTouch
	
	rjmp main
	

noteon:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte

	cpi r18,0
	breq noteoffb

	movw Y,X
	st X+, r19

	rcall setNote
	rjmp main




noteoff:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte
noteoffb:

	movw Y,X

noteOffLook:
	ld r16,-Y
	cp r19,r16
	brne noteOffLook
	
	

noteOffMove:
	ldd r16,Y+1
	st Y+,r16
	cp YL,XL
	brne noteOffMove

	sbiw X,1
	sbiw Y,1
	
	ld r19,-Y
	rcall setNote

	rjmp main



midiCC:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte
	
	cpi r19,7
	breq setArpegSpeed


	cpi r19,1
	breq setModDepth
	
	cpi r19,5
	breq setModSpeed

	cpi r19,65
	breq setTrigger


	rjmp main


pitchBend:
	sbrc r18,7
	rcall receiveByte
	;mov r19,r18
	rcall receiveByte

	;lsl r19
	;lsl r19
	;rol r18
	subi r18,64
	mov r3,r18	
	add r18,r5
	out OCR1B,r18


;	sub ZL,r3
;	sbci ZH,0
;	mov r3,r18
;	;clr r17 ; cleared by receiveByte
;	add ZL, r3
;	adc ZH, r17
;	rcall setNoteLoadb



	rjmp main


afterTouch:
	sbrc r18,7
	rcall receiveByte


setModDepth:
	lsl r18
	andi r18,0b11100000
	mov r6,r18
	rjmp main


setArpegSpeed:
	subi r18,-3
	mov r4,r18
	rjmp main

setModSpeed:
	swap r18
	andi r18,0b00000111
	inc r18
	mov r8,r18
	
	rjmp main

setTrigger:
	mov r14,r18
	rjmp main



receiveByte:
	
;	ret

	sbic PINB, 2
	rjmp receiveByte
	cli

	ldi r16,32
rbWait1:
	nop
	dec r16
	brne rbWait1

	ldi r17,8
	ldi r18,0

rbBit:
	ldi r16,62
rbWait2:
	clc
	dec r16
	brne rbWait2
	

	nop
	nop

	sbic PINB, 2
	sec
	ror r18
	
	dec r17
	brne rbBit

rbEnd:
	sbis PINB, 2
	rjmp rbEnd

	sbrc r18,7
	mov r20,r18

	ret



	




setNote:
	cpi r19,13
	brcs outputOff

	;cbi PORTB,3	

	subi r19,32
	lsl r19
	lsl r19

	in r16,OCR1A
	cp r16,r19
	breq setNoteEnd

;	clr r16
;	out OCR1A,r16



	ldi r16, 0b00011011
	out DDRB,r16

	sbrc r14,6
	sbi PORTB,0

	sbi PORTB,3



	out OCR1A,r19
	
	cbi PORTB,0


/*

	ldi ZH, HIGH(noteLookup*2-127+7)
	ldi ZL,  LOW(noteLookup*2-127+7)
	swap r19
	clr r16
	lsl r19
	adc ZH,r16

	add ZL, r19
	adc ZH,r16

	;out TCCR1,r17

	add ZL, r3
	adc ZH, r16

	add ZL, r5
	adc ZH, r16
*/
setNoteLoadb:
;	lpm r19,Z

	
;	out OCR1C,r19

;	in r16,TCNT1

;	cp r19,r16
;	brcc setNoteEnd
	
	
	;dec r19
;	ldi r19,(1<<PSR1)
;	out GTCCR,r19
	
	
;	clr r19
;	out TCNT1,r19

setNoteEnd:
	ret


outputOff:
	clr r16
	out OCR1A,r16

	cbi PORTB,3
	cbi PORTB,0
	ldi r16, 0b00000000
	out DDRB,r16

	ret





.org 1280
modLookup:
.db 127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127
.db 127,127,127,128,128,128,128,128,128,128,128,128,128,128,127,127,127,127,127,126,126,126,126,126,126,126,126,126,126,126,127,127
.db 127,127,128,128,128,129,129,129,129,129,129,129,128,128,128,127,127,127,126,126,126,125,125,125,125,125,125,125,126,126,126,127
.db 127,128,128,129,129,129,130,130,130,130,130,129,129,129,128,128,127,126,126,125,125,125,124,124,124,124,124,125,125,125,126,126
.db 127,128,129,129,130,130,131,131,131,131,131,130,130,129,129,128,127,126,125,125,124,124,123,123,123,123,123,124,124,125,125,126
.db 127,128,129,130,131,131,132,132,132,132,132,131,131,130,129,128,127,126,125,124,123,123,122,122,122,122,122,123,123,124,125,126
.db 127,128,129,130,131,132,133,133,133,133,133,132,131,130,129,128,127,126,125,124,123,122,121,121,121,121,121,122,123,124,125,126
.db 127,128,130,131,132,133,133,134,134,134,133,133,132,131,130,128,127,126,124,123,122,121,121,120,120,120,121,121,122,123,124,126
