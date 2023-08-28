
module mine_placer (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input logic [1:0] row,
    input logic [1:0] col,
    
    output logic valid,
    output logic [10:0] pixel_x,
    output logic [10:0] pixel_y
);

assign valid = ~(row[1] & row[0]);

assign pixel_x = 11'h70 + (11'h30 * row);
assign pixel_y = 11'h80 + (11'h60 * col);

endmodule : mine_placer
