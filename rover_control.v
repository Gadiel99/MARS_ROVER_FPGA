module rover_control(
    input clock,               // Clock
    input reset,               // Active-high reset signal
    input bit0,                // Active-low: Direction Bit 0
    input bit1,                // Active-low: Direction Bit 1
    input bit2,                // Active-low: Direction Bit 2
    input bit3,                // Active-low: Increase Speed (Left Bumper)
    input bit4,                // Active-low: Decrease Speed (Right Bumper)
    output reg ENA,            // Active-low: Enable Motor A (PWM Control)
    output reg ENB,            // Active-low: Enable Motor B (PWM Control)
    output reg IN1,            // Active-low: Motor A Forward
    output reg IN2,            // Active-low: Motor A Backward
    output reg IN3,            // Active-low: Motor B Forward
    output reg IN4             // Active-low: Motor B Backward
);

    // Internal Registers
    reg [7:0] counter;          // 8-bit counter for PWM generation
    reg [7:0] duty_cycle;       // Current duty cycle (0-255)
    reg last_bit3, last_bit4;   // Stores the previous state of bit3 and bit4
    reg adjust_speed;           // Flag to track if the speed was recently adjusted

    // Parameters for Duty Cycle Limits
    localparam MAX_DUTY = 8'd200; // Maximum duty cycle
    localparam MIN_DUTY = 8'd50;  // Minimum duty cycle
    localparam DUTY_STEP = 8'd10; // Step size for duty cycle adjustments

    // Initial Duty Cycle
    initial begin
        duty_cycle = 8'd150; // Starting with a moderate duty cycle
        last_bit3 = 1'b1;    // Assume no press (active-low signals are HIGH)
        last_bit4 = 1'b1;
        adjust_speed = 1'b0;
    end

    // PWM Generation and Duty Cycle Adjustment
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset all outputs and internal registers
            counter <= 8'b0;
            duty_cycle <= 8'd150;
            ENA <= 1'b1; 
            ENB <= 1'b1; 
            IN1 <= 1'b1; 
            IN2 <= 1'b1; 
            IN3 <= 1'b1;
            IN4 <= 1'b1; 
            last_bit3 <= 1'b1;
            last_bit4 <= 1'b1;
            adjust_speed <= 1'b0;
            
        end else begin
            // Increment the counter for PWM
            if (counter < 8'd255) begin
                counter <= counter + 8'd1;
            end else begin
                counter <= 8'b0;
            end

            // Compare counter with duty cycle
            //  PWM is active when counter < duty_cycle
            if (counter < duty_cycle) begin
                //Enable Motors
                ENA <= 1'b0; 
                ENB <= 1'b0; 
            end else begin
                //Disable Motors
                ENA <= 1'b1; 
                ENB <= 1'b1; 
            end

            // Direction Control Logic
            // Active-Low logic
            case ({~bit2, ~bit1, ~bit0})
                // Not Moving
                3'b000: begin 
                    IN1 <= 1'b1; 
                    IN2 <= 1'b1; 
                    IN3 <= 1'b1; 
                    IN4 <= 1'b1; 
                end
                // Forward
                3'b001: begin 
                    IN1 <= 1'b0; 
                    IN2 <= 1'b1; 
                    IN3 <= 1'b0; 
                    IN4 <= 1'b1; 
                end
                // Backward
                3'b010: begin 
                    IN1 <= 1'b1; 
                    IN2 <= 1'b0; 
                    IN3 <= 1'b1; 
                    IN4 <= 1'b0; 
                end
                // Left
                3'b011: begin  
                    IN1 <= 1'b1; 
                    IN2 <= 1'b0; 
                    IN3 <= 1'b0; 
                    IN4 <= 1'b1; 
                end
                // Right Turn 
                3'b100: begin 
                    IN1 <= 1'b0; 
                    IN2 <= 1'b1; 
                    IN3 <= 1'b1; 
                    IN4 <= 1'b0; 
                end
                default: begin 
                    IN1 <= 1'b1;
                    IN2 <= 1'b1;
                    IN3 <= 1'b1;
                    IN4 <= 1'b1;
                end
            endcase

            // Duty Cycle Adjustment Logic
            if (!bit3 && last_bit3) begin // Detect falling edge of bit3
                if (duty_cycle + DUTY_STEP <= MAX_DUTY) begin
                    duty_cycle <= duty_cycle + DUTY_STEP;
                end else begin
                    duty_cycle <= MAX_DUTY;
                end
                adjust_speed <= 1'b1;
                
            end else if (!bit4 && last_bit4) begin // Detect falling edge of bit4
                if (duty_cycle - DUTY_STEP >= MIN_DUTY) begin
                    duty_cycle <= duty_cycle - DUTY_STEP;
                end else begin
                    duty_cycle <= MIN_DUTY;
                end
                adjust_speed <= 1'b1;
                
            end else begin
                adjust_speed <= 1'b0;
            end

            // Store the previous state of bit3 and bit4
            last_bit3 <= bit3;
            last_bit4 <= bit4;
        end
    end
endmodule