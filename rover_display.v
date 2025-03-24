`timescale 1ns / 1ps

module rover_display(
    input clock,
    input reset,
    input bit0,
    input bit1,
    input bit2,
    input auto_mode_switch,
    input object_detected, 
    output reg [3:0] Anode_Activate,
    output reg [6:0] LED_out
);

    always @(*) begin
        Anode_Activate = 4'b1110; // Activate only AN0 (active-low)
    
        if (auto_mode_switch) begin
            // Automated mode
            if (object_detected) begin
                LED_out = 7'b1001111; // 'o' for Object Detected
            end else begin
                LED_out = 7'b1111110; // '-' for no object detected
            end
        end else begin
            // Manual mode: Decode the three-bit input
            case ({~bit2, ~bit1, ~bit0})
                                    //(ABCDEFG)
                3'b000: LED_out = 7'b1111111; // Not Moving: All segments off
                3'b001: LED_out = 7'b0111000; // 'F' for Forward
                3'b010: LED_out = 7'b1100000; // 'B' for Backward
                3'b011: LED_out = 7'b1110001; // 'L' for Left
                3'b100: LED_out = 7'b1111010; // 'R' for Right
                default: LED_out = 7'b1111111; // Default: All segments off
            endcase
        end
    end
endmodule
