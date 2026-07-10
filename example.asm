	.ORG $fff0  ; Directives are case-insensitive
vectors:        ; Labels are case-sensitive
	.WORD $8000 ; Stored in little-endian

	.org $8000 ; Set code origin
start:
	CLC        ; Mnemonics are case-insensitive
	ADC IX     ; Operands are case-insensitive
	adc [iY]
	LD #$0a    ; This should be translated to: LDI #$0a
	LD -%10_10
	LD 42
	JMP $1234
	JMP :start
	BNE :END   ; This is stored as a signed 8-bit in 2's complement

Data:
	.BYTE $55, %1010_1010, 1_0_00, '99' ; Numbers can have _ to separate values
	.WOrd $aa_55, -42                   ; Numbers can be signed(stored in 2's complement)
	.TEXT "\tHello", $0A, "World\n", 0  ; All texts are ASCII and support escape-sequences

END:
	HLT

; There should be an EOF here ->
