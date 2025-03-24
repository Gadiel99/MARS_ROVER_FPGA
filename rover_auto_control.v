module rover_auto_control(
    input clock,                      // Clock
    input reset,                      // Reset signal
    input object_detected,            // Ultrasonic sensor signal (1 when obstacle detected)
    output reg ENA,                   // Active-low: Enable Motor A (PWM Control)
    output reg ENB,                   // Active-low: Enable Motor B (PWM Control)
    output reg IN1,                   // Active-low: Motor A Forward
    output reg IN2,                   // Active-low: Motor A Backward
    output reg IN3,                   // Active-low: Motor B Forward
    output reg IN4                    // Active-low: Motor B Backward
);

    // Parameters
    parameter MIN_DUTY = 8'd100;      // Minimum duty cycle
    parameter DEFAULT_DUTY = 8'd150; // Default duty cycle for auto mode
    parameter PWM_MAX = 8'd200;      // Maximum PWM cycle count
    parameter TURN_DELAY = 28'd150_000_000; // 3 seconds delay at 50 MHz

    // Internal registers
    reg [7:0] pwm_counter;              // PWM counter
    reg [7:0] duty_cycle;               // Duty cycle for PWM
    reg [1:0] state;                    // State machine for movement
    reg turn_state;                     // Direction for turning (0: right, 1: left)
    reg [27:0] turn_delay_counter;      // Delay counter for turn duration

    // State definitions
    parameter FORWARD = 2'b00;
    parameter TURN_LEFT = 2'b01;
    parameter TURN_RIGHT = 2'b10;

    // PWM generation
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pwm_counter <= 8'd0;
            duty_cycle <= DEFAULT_DUTY; 
            ENA <= 1'b1;
            ENB <= 1'b1;
        end else begin
            if (pwm_counter < PWM_MAX - 1)
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 8'd0;
            
            //Manage PWM logic
            ENA <= (pwm_counter < duty_cycle) ? 1'b0 : 1'b1; 
            ENB <= (pwm_counter < duty_cycle) ? 1'b0 : 1'b1; 
        end
    end

    // State machine logic
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= FORWARD;
            turn_state <= 1'b0; // Start with turning right
            turn_delay_counter <= 28'd0;
            IN1 <= 1'b1; IN2 <= 1'b1;
            IN3 <= 1'b1; IN4 <= 1'b1;
        end else begin
            case (state)
                FORWARD: begin
                    if (object_detected) begin
                        // If object detected, initiate turn
                        state <= turn_state ? TURN_LEFT : TURN_RIGHT;
                        turn_state <= ~turn_state; // Alternate turn direction
                        turn_delay_counter <= 28'd0; // Reset delay counter
                    end else begin
                        // Forward motion
                        IN1 <= 1'b0; IN2 <= 1'b1; 
                        IN3 <= 1'b0; IN4 <= 1'b1; 
                    end
                end

                TURN_LEFT: begin
                    if (turn_delay_counter >= TURN_DELAY && !object_detected) begin
                        // Finish turn, go back to forward
                        state <= FORWARD;
                    end else begin
                        // Continue turning left
                        turn_delay_counter <= turn_delay_counter + 1;
                        IN1 <= 1'b0; IN2 <= 1'b1; 
                        IN3 <= 1'b1; IN4 <= 1'b0; 
                    end
                end

                TURN_RIGHT: begin
                    if (turn_delay_counter >= TURN_DELAY && !object_detected) begin
                        // Finish turn, go back to forward
                        state <= FORWARD;
                    end else begin
                        // Continue turning right
                        turn_delay_counter <= turn_delay_counter + 1;
                        IN1 <= 1'b1; IN2 <= 1'b0; 
                        IN3 <= 1'b0; IN4 <= 1'b1; 
                    end
                end

                default: state <= FORWARD; // Default to forward state
            endcase
        end
    end
endmodule
