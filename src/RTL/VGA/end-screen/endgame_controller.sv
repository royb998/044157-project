
module endgame_controller (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input logic win,
	 input logic lose,
    input logic [2:0] lives,

    output logic is_ended,
    output logic is_loss
);

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        is_ended <= 1'b0;
        is_loss <= 1'b0;
    end else begin
        if (~is_ended) begin
            if (win) begin
                is_ended <= 1'b1;
            end else if (lose || (lives == 3'h0)) begin
                is_ended <= 1'b1;
                is_loss <= 1'b1;
            end
        end
    end
end

endmodule : endgame_controller
