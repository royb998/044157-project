module lives (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input explosion,
    input game_over,

    output [2:0] lives_left
);

parameter logic [2:0] MAX_LIVES = 3'h3;

logic explosion_cur;
logic explosion_prev;
logic explosion_up;

always_comb begin
    explosion_up = explosion_cur & ~explosion_prev;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        lives_left <= MAX_LIVES;
        explosion_prev <= 1'b0;
    end else begin
        explosion_prev <= explosion_cur;
        explosion_cur <= explosion;

        if (game_over) begin
            lives_left <= 3'h0;
        end else if (lives_left > 0 && explosion_up) begin
            lives_left <= lives_left - 3'h1;
        end
    end
end

endmodule : lives
