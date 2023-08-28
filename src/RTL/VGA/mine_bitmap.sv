
module mine_bitmap (
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low

    input logic [10:0] offset_x,
    input logic [10:0] offset_y,
    input logic inside_rectangle,

    output logic drawing_request,
    output logic [7:0] rgb_out
);


localparam int OBJECT_NUMBER_OF_Y_BITS = 5;
localparam int OBJECT_NUMBER_OF_X_BITS = 5;

localparam int OBJECT_HEIGHT_Y = 1 << OBJECT_NUMBER_OF_Y_BITS; // => height = 32-bits
localparam int OBJECT_WIDTH_X = 1 << OBJECT_NUMBER_OF_X_BITS; // => width = 32-bits

// BMP data for the mine.

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hda,8'hda,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hcd,8'hcd,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hda,8'hda,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hcd,8'hcd,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'h6d,8'h6d,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'h6d,8'h6d,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'h00,8'h00,8'h6d,8'h6d,8'hda,8'hda,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'hf1,8'hf1,8'h00,8'h00,8'hf1,8'hf1,8'hf1,8'hf1,8'h6d,8'h6d,8'h00,8'h00,8'h6d,8'h6d,8'hda,8'hda,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'h00,8'h00,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h6d,8'h6d,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'h6d,8'h6d,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h6d,8'h6d,8'h6d,8'h6d,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hcd,8'hcd,8'hcd,8'hcd,8'h6d,8'h6d,8'h6d,8'h6d,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hda,8'hda,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hda,8'hda,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
    {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rgb_out <= 8'h00;
    end else begin
        rgb_out <= object_colors[offset_y][offset_x];
    end
end

// Only draw if not transparent.
assign drawing_request = (rgb_out != TRANSPARENT_ENCODING) ? 1'b1 : 1'b0;

endmodule : mine_bitmap
