
module mine_placer (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input logic [3:0] row,
    input logic [4:0] col,
    
    output logic [10:0] pixel_x,
    output logic [10:0] pixel_y
);

assign pixel_x = (3 + row) << 5;
assign pixel_y = (1 + col) << 5;

endmodule : mine_placer
