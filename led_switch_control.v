`timescale 1ns / 1ps

module led_switch_control(
    input wire switch,  // Input from Switch 
    output wire led       // Output to LED
);

// Assign the state of the LED based on the switch
assign led = switch;

endmodule