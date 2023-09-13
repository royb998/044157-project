
module endgame_selector (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input logic [1:0] input_requests,
    input logic [1:0][7:0] input_rgb,
    input logic is_win,
    input logic is_loss,

    output logic drawing_request,
    output logic [7:0] rgb
);

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        drawing_request <= 1'b0;
        rgb <= 8'h00;
    end else begin
        drawing_request <= 1'b0;
        rgb <= 8'h00;

        if (is_win) begin
            drawing_request <= input_requests[0];
            rgb <= input_rgb[0];
        end else if (is_loss) begin
            drawing_request <= input_requests[1];
            rgb <= input_rgb[1];
        end
    end
end

endmodule : endgame_selector
