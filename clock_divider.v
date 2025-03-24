module clock_divider(
    input clk_in,      // Input clock (100 MHz)
    output clk_out     // Output clock (50 MHz)
);

    reg [27:0] counter = 28'd0;
    parameter DIVISOR = 28'd2;

    reg clk_div; // Internal clock signal

    always @(posedge clk_in) begin
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        else
            counter <= counter + 28'd1;

        clk_div <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
    end

    // Route the divided clock through a global clock buffer
    BUFG clk_buffer (
        .I(clk_div),
        .O(clk_out)
    );

endmodule


