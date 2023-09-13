
module sound_engine (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    // Events that trigger a sound
    input logic collision,
    input logic explosion,
    input logic win,
    input logic lose,
    
    output logic enabled,
    output logic [3:0] divisor // Equivalent to a note, in some way
);

parameter logic [4:0] COUNTER_START = 5'h18;
logic [4:0] counter = COUNTER_START;

enum logic [7:0] {
    sm_idle,
    sm_win_1,
    sm_win_2,
    sm_win_3,
    sm_lose_1,
    sm_lose_2,
    sm_lose_3
} cur_state;

logic collision_cur = 1'b0;
logic collision_prev = 1'b0;
logic collision_up = 1'b0;
logic explosion_cur = 1'b0;
logic explosion_prev = 1'b0;
logic explosion_up = 1'b0;
logic lose_cur = 1'b0;
logic lose_prev = 1'b0;
logic lose_up = 1'b0;
logic win_cur = 1'b0;
logic win_prev = 1'b0;
logic win_up = 1'b0;

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        enabled <= 1'b0;
        divisor <= 1'b0;
    end else begin
        collision_cur <= collision;
        collision_prev <= collision_cur;
        explosion_cur <= explosion;
        explosion_prev <= explosion_cur;
        win_cur <= win;
        win_prev <= win_cur;
        lose_cur <= lose;
        lose_prev <= lose_cur;

        if (win_up) begin
            cur_state <= sm_win_1;
            counter <= COUNTER_START;
        end else if (lose_up) begin
            cur_state <= sm_lose_1;
            counter <= COUNTER_START;
        end else if (explosion_up) begin
            cur_state <= sm_lose_3;
            counter <= COUNTER_START;
        end else if (collision_up) begin
            cur_state <= sm_win_3;
            counter <= COUNTER_START;
        end else begin
            counter <= counter - 5'h01;

            case (cur_state)
                sm_win_1: begin
                    divisor <= 4'h8;
                    if (counter > 0) begin
                        cur_state <= sm_win_1;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_win_2;
                    end
                end
                sm_win_2: begin
                    divisor <= 4'h4;
                    if (counter > 0) begin
                        cur_state <= sm_win_2;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_win_3;
                    end
                end
                sm_win_3: begin
                    divisor <= 4'h8;
                    if (counter > 0) begin
                        cur_state <= sm_win_3;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_idle;
                    end
                end
                sm_lose_1: begin
                    divisor <= 4'h8;
                    if (counter > 0) begin
                        cur_state <= sm_lose_1;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_lose_2;
                    end
                end
                sm_lose_2: begin
                    divisor <= 4'h4;
                    if (counter > 0) begin
                        cur_state <= sm_lose_2;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_lose_3;
                    end
                end
                sm_lose_3: begin
                    divisor <= 4'h8;
                    if (counter > 0) begin
                        cur_state <= sm_lose_3;
                    end else begin
                        counter <= COUNTER_START;
                        cur_state <= sm_idle;
                    end
                end
                sm_idle: begin
                    cur_state <= sm_idle;
                    counter <= 5'h0;
                    divisor <= 4'h0;
                    enabled <= 1'b0;
                end
            endcase
        end
    end
end

always_comb begin
    enabled = counter > 0;
    collision_up = collision_cur & (~collision_prev);
    explosion_up = explosion_cur & (~explosion_prev);
    win_up = win_cur & (~win_prev);
    lose_up = lose_cur & (~lose_prev);
end

endmodule : sound_engine
