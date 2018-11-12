*-----------------------------------------------------------
* Title      :Problemes T1: 6
* Written by :BARTOMEU RAMIS TARRAGÓ
*-----------------------------------------------------------
    ORG    $1000
    
; -----------------------------------------------------------------------------
SHOWHWIN
; Shows the hardware window
; Input - None
; Output - None
; Modifies - Nothing
; -----------------------------------------------------------------------------
            MOVEM.W D0/D1,-(A7); guardam registres
              
            MOVE.B #32,D0
            CLR.B D1
            TRAP #15
            
            MOVEM.W (A7)+,D0/D1; restauram registres
            RTS
            
; -----------------------------------------------------------------------------
GTHWADDR
; Saves @ (A0) the memory positions where "seven-segment display", "leds", 
; "switches" and "buttons" are mapped 
; Input - A0: pointer to vector
; Output - A0 with memory positions of the above
; Modifies - none
; -----------------------------------------------------------------------------   
            MOVEM.L D0/D1/A0/A1,-(A7); guardam registres
            MOVE.B #32,D0
            LEA     .DATA,A1
.LOOP       MOVE.B (A1)+,D1
            BEQ .END
            TRAP #15
            MOVE.L D1,(A0)+
            BRA     .LOOP
.END        MOVEM.L (A7)+,D0/D1/A0/A1; restauram registres
            RTS
            
.DATA       DC.B    1,2,3,7,0
            DS.W    0            
    
; -----------------------------------------------------------------------------
WRTSEGM
; Shows the content of D0.B on the most-right 7-segment display
; Input - A0: pointer to the addres of 7-segment display 
;       - D0: High bits: Number of display; Low bits: Number that will be shown 
; Output - none
; Modifies - none
; -----------------------------------------------------------------------------
            MOVEM.L D0/D1/D2/A0/A1,-(A7); guardam registres
            SWAP D0
            MOVE.B #0,D1
.LOOP       MOVE.B D0,D2
            SUB.B D1,D2
            BEQ .GOTDISP
            ADDQ.B #1,D1
            ADD.W #0,(A0)+ ;to switc to the next 7-s. disp (It works OK?!)
            BRA .LOOP
            
.GOTDISP    SWAP D0
            LEA.L DIGITS,A1
            MOVE.B #0,D1
.CHECKVALUE MOVE.B D0,D2
            SUB.B D1,D2           
            BEQ .END
            ADDQ.B #1,D1
            ADD.W #0,(A1)+ ;to increase value of pointer (I hate myself...)
            BRA .CHECKVALUE          
            
.END        MOVE.W (A1),(A0)
            MOVEM.L (A7)+,D0/D1/D2/A0/A1; restauram registres
            RTS
DIGITS      DC.W $3F00,$0600,$5B00,$4F00,$6600,$6D00,$7D00,$0700,$7F00,$6F00,$0000,$4000
   
 
; -----------------------------------------------------------------------------
CNTSWTCH
;Returns pressed switches in D0.B (each bit represents a switch) 
; Input - A0: adress to switches 
; Output - D0.B: switches pressed (bits will be 1)
; Modifies - none
; -----------------------------------------------------------------------------
            MOVEM.L D1/D2/A0/A1,-(A7); guardam registres
            MOVE.B (A0),D0
            MOVEM.L (A7)+,D1/D2/A0/A1; restauram registres
            RTS

*------------------------------------------------------------------------------
*MAIN PROGRAM
*------------------------------------------------------------------------------
 
START:      BSR SHOWHWIN
            LEA DISADDR,A0
            BSR GTHWADDR
            MOVE.B #7,D0 ;Indicam a quin 7-s disp volem mostrar el nombre
            SWAP D0
.LOOP       MOVE.L (SWTADDR), A0
            BSR CNTSWTCH
            MOVE.B D0,D3
            MOVE.B #0,D2
            MOVE.W #7,D1
.COUNTLOOP  AND.B #$01,D3
            BEQ .IS0
            ADDQ.B #1,D2           
.IS0        LSR.B #1,D0
            MOVE.B D0,D3
            DBRA D1,.COUNTLOOP
 
            MOVE.B D2,D0
            MOVE.L (DISADDR), A0
            BSR WRTSEGM
            BRA .LOOP
    SIMHALT             ; halt simulator
    
DISADDR     DS.L    1
LEDADDR     DS.L    1
SWTADDR     DS.L    1
BUTADDR     DS.L    1

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
