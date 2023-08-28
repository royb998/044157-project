
module mif_draw (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input logic [7:0] rgb_mif,

	output logic mif_draw_request
);

parameter bg_rgb = 8'hFF;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mif_draw_request <= 0;
	end else if(rgb_mif != bg_rgb) begin
		mif_draw_request <= 1;
	end
end

endmodule