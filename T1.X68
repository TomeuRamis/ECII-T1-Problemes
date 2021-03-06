*-----------------------------------------------------------
* Title      :Problemes T1                  
* Written by :Bartomeu Ramis                
* Date       :11/11/18
*-----------------------------------------------------------


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
   
*------------------------------------------------------------------------------
*MAIN PROGRAM
*------------------------------------------------------------------------------
START:      BSR SHOWHWIN
            LEA DISADDR,A0
            BSR GTHWADDR
            MOVE.L (DISADDR), A0
            MOVE.B #3,D0 ; Set the 7-seg display that will show a number
            SWAP D0
            MOVE.B #5,D0 ; Set the number that will be displayed
            BSR WRTSEGM
            
            MOVE.L  (LEDADDR), A0
            MOVE.L  (SWTADDR), A1
.LOOP       MOVE.W  (A1),D0
            NOT.B   D0
            MOVE.W  D0,(A0)
            BRA     .LOOP
            

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
