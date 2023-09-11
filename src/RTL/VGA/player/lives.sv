module lives (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input explosion,
    input game_over,

    output [2:0] lives_left
);

parameter logic [2:0] MAX_LIVES = 3;

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        lives_left <= MAX_LIVES;
    end else begin
        if (game_over) begin
            lives_left <= 0;
        end else if (lives_left > 0 && explosion) begin
            lives_left <= lives_left - 1;
        end
    end
end

endmodule : lives
