`timescale 1ns / 1ps

module rover_top(
    input clock,                   // Clock
    input reset,                   // Active-high reset signal
    input bit0,                    // Active-low: Direction Bit 0
    input bit1,                    // Active-low: Direction Bit 1
    input bit2,                    // Active-low: Direction Bit 2
    input bit3,                    // Active-low: Increase Speed (Left Bumper)
    input bit4,                    // Active-low: Decrease Speed (Right Bumper)
    input auto_mode_switch,        // Active-high: Switch to Automated Mode
    input object_detected,         // Input from ESP32 (HIGH when an object is detected)
    output [3:0] Anode_Activate,   // 7-segment display anodes
    output [6:0] LED_out,          // 7-segment display cathodes
    output reg ENA,                // Active-low: Enable Motor A (PWM Control)
    output reg ENB,                // Active-low: Enable Motor B (PWM Control)
    output reg IN1,                // Active-low: Motor A Forward
    output reg IN2,                // Active-low: Motor A Backward
    output reg IN3,                // Active-low: Motor B Forward
    output reg IN4,                // Active-low: Motor B Backward
    output led                     // LED indicating the current mode
);

    // Internal wires for connections between modules
    wire ENA_manual, ENB_manual, IN1_manual, IN2_manual, IN3_manual, IN4_manual;
    wire ENA_auto, ENB_auto, IN1_auto, IN2_auto, IN3_auto, IN4_auto;
    
    //Clock divider internal signal
    wire clock_50Mhz;
   
   //Internal wire for debounce bits
     wire debounced_bit0, debounced_bit1, debounced_bit2, debounced_bit3, debounced_bit4;
  
   //Clock divider instance
    clock_divider clk_div (
        .clk_in(clock),
        .clk_out(clock_50Mhz)
    );
   
   //Debounce for each bit instance
    debounce db_bit0 (
        .clock(clock_50Mhz),
        .reset(reset),
        .noisy_signal(bit1),
        .clean_signal(debounced_bit0)
    );
    
     debounce db_bit1 (
        .clock(clock_50Mhz),
        .reset(reset),
        .noisy_signal(bit1),
        .clean_signal(debounced_bit1)
    );

    debounce db_bit2 (
        .clock(clock_50Mhz),
        .reset(reset),
        .noisy_signal(bit2),
        .clean_signal(debounced_bit2)
    );

    debounce db_bit3 (
        .clock(clock_50Mhz),
        .reset(reset),
        .noisy_signal(bit3),
        .clean_signal(debounced_bit3)
    );

    debounce db_bit4 (
        .clock(clock_50Mhz),
        .reset(reset),
        .noisy_signal(bit4),
        .clean_signal(debounced_bit4)
    );


    // Manual control instance
    rover_control manual_ctrl (
        .clock(clock_50Mhz),
        .reset(reset),
        .bit0(debounced_bit0),
        .bit1(debounced_bit1),
        .bit2(debounced_bit2),
        .bit3(debounced_bit3),
        .bit4(debounced_bit4),
        .ENA(ENA_manual),
        .ENB(ENB_manual),
        .IN1(IN1_manual),
        .IN2(IN2_manual),
        .IN3(IN3_manual),
        .IN4(IN4_manual)
    );

    // Automated control instance
    rover_auto_control auto_ctrl (
        .clock(clock_50Mhz),
        .reset(reset),
        .object_detected(object_detected),
        .ENA(ENA_auto),
        .ENB(ENB_auto),
        .IN1(IN1_auto),
        .IN2(IN2_auto),
        .IN3(IN3_auto),
        .IN4(IN4_auto)
    );

    // 7-segment display instance
    rover_display rd (
        .clock(clock_50Mhz),
        .reset(reset),
        .bit0(debounced_bit0),
        .bit1(debounced_bit1),
        .bit2(debounced_bit2),
        .auto_mode_switch(auto_mode_switch),
        .object_detected(object_detected),
        .Anode_Activate(Anode_Activate),
        .LED_out(LED_out)
    );

    // LED indicating mode
    led_switch_control led_ctrl (
        .switch(auto_mode_switch),
        .led(led)
    );

    // Mode Selector
    always @(*) begin
        if (auto_mode_switch) begin
            // Automated Mode
            ENA = ENA_auto;
            ENB = ENB_auto;
            IN1 = IN1_auto;
            IN2 = IN2_auto;
            IN3 = IN3_auto;
            IN4 = IN4_auto;
        end else begin
            // Manual Mode
            ENA = ENA_manual;
            ENB = ENB_manual;
            IN1 = IN1_manual;
            IN2 = IN2_manual;
            IN3 = IN3_manual;
            IN4 = IN4_manual;
        end
    end

endmodule
