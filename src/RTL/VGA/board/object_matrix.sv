
module object_matrix (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input logic [10:0] pixel_x,
    input logic [10:0] pixel_y,
    input logic collision, // indicates if there is a collision with the player on the current pixel

    output logic [10:0] tile_x, // top-left pixel of selected tile
    output logic [10:0] tile_y,
    output logic [2:0] object // indicator for object in selected tile
);

parameter logic [7:0] TRANSPARENT_COLOUR = 8'hFF;

parameter logic [10:0] X_MATRIX = 11'h020; // Distance from screen left.
parameter logic [10:0] Y_MATRIX = 11'h060; // Distance from screen top.

parameter logic [3:0] tile_order = 5; // Tile size = 2**order

/* Different values for different objects:
    0: Background
    1: Persistent wall
    2: Sturdy wall
    3: Brittle wall
    4: Mine
*/

localparam [4:0] ROWS = 11;
localparam [4:0] COLUMNS = 17;

logic [0:ROWS - 1][0:COLUMNS - 1] [2:0] objects = {
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
    {3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0},
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0},
    {3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h0},
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
    {3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0},
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
    {3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0},
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
    {3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0},
    {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
};

logic collision_prev = 1'b0;
logic collision_up = 1'b0;

always_ff @(posedge clk) begin
    collision_prev <= collision;

    if (collision_up) begin
        case (object)
            3'h2: objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h3;
            3'h3: objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h0;
        endcase
    end
end

always_comb begin
    collision_up = (~collision_prev) & collision;

    if (pixel_x < X_MATRIX ||
        pixel_y < Y_MATRIX ||
        pixel_x > X_MATRIX + (COLUMNS + 1) << tile_order ||
        pixel_x > Y_MATRIX + (ROWS + 1) << tile_order) begin
        tile_x = 11'h0;
        tile_y = 11'h0;
        object = 3'h0;
    end
    else begin
        tile_x = pixel_x & 11'h7E0;
        tile_y = pixel_y & 11'h7E0;

        object = objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order];
    end
end


endmodule : object_matrix
