`timescale 1ns / 1ps

module debounce(
    input clock,
    input reset,
    input noisy_signal,
    output reg clean_signal
);

reg [2:0] sync_reg;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        sync_reg <= 3'b111; // Default high
        clean_signal <= 1'b1;
    end else begin
        sync_reg <= {sync_reg[1:0], noisy_signal};
        if (sync_reg == 3'b111)
            clean_signal <= 1'b1;
        else if (sync_reg == 3'b000)
            clean_signal <= 1'b0;
    end
end

endmodule

