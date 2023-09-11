
module object_matrix (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input logic [10:0] pixel_x,
    input logic [10:0] pixel_y,
    input logic collision, // indicates if there is a collision with the player on the current pixel
    input logic explosion, // Indicates if there is an explosion in the current pixel
    input logic add_mine,

    output logic [10:0] tile_x, // top-left pixel of selected tile
    output logic [10:0] tile_y,
    output logic mine_exploded,
    output logic [2:0] object, // indicator for object in selected tile
    output reg [3:0] mine_count
);

parameter logic [7:0] TRANSPARENT_COLOUR = 8'hFF;

parameter logic [10:0] X_MATRIX = 11'h020; // Distance from screen left.
parameter logic [10:0] Y_MATRIX = 11'h060; // Distance from screen top.

parameter logic [3:0] tile_order = 5; // Tile size = 2**order

parameter logic [3:0] max_mines = 10;

/* Different values for different objects:
    0: Background
    1: Persistent wall
    2: Sturdy wall
    3: Brittle wall
    4: Mine
*/

localparam [4:0] ROWS = 11;
localparam [4:0] COLUMNS = 17;

logic [0:ROWS - 1][0:COLUMNS - 1] [2:0] objects;

logic collision_prev = 1'b0;
logic collision_cur = 1'b0;
logic collision_up = 1'b0;
logic explosion_prev = 1'b0;
logic explosion_cur = 1'b0;
logic explosion_up = 1'b0;
logic add_mine_prev = 1'b0;
logic add_mine_cur = 1'b0;
logic add_mine_up = 1'b0;

logic on_board;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mine_exploded <= 1'b0;

        collision_prev <= 1'b0;
        explosion_prev <= 1'b0;
        mine_count <= 4'h1;

        objects <= {
            {3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
            {3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0},
            {3'h0, 3'h2, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0},
            {3'h0, 3'h1, 3'h3, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h0},
            {3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h3, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
            {3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0},
            {3'h0, 3'h0, 3'h2, 3'h3, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h2, 3'h0, 3'h0, 3'h0, 3'h2, 3'h3, 3'h3, 3'h0},
            {3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0},
            {3'h0, 3'h0, 3'h4, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h3, 3'h0, 3'h0, 3'h0},
            {3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h0, 3'h1, 3'h2, 3'h1, 3'h2, 3'h1, 3'h0},
            {3'h0, 3'h0, 3'h0, 3'h2, 3'h3, 3'h2, 3'h2, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0},
        };
    end
    else begin
        if (on_board) begin
            case (objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order])
                3'h0: if (add_mine_up && (mine_count < max_mines)) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h4;
                        mine_count <= mine_count + 1;
                end
                3'h2: if (explosion_up) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h3;
                end
                3'h3: if (explosion_up) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h0;
                end
                3'h4: if (collision_up) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 3'h0;
                        mine_count <= mine_count - 1;
                        mine_exploded = 1'b1;
                end
            endcase
        end

        collision_cur <= collision;
        collision_prev <= collision_cur;
        explosion_cur <= explosion;
        explosion_prev <= explosion_cur;
        add_mine_cur <= add_mine;
        add_mine_prev <= add_mine_cur;
    end
end

always_comb begin
    collision_up <= (~collision_prev) & collision_cur;
    explosion_up <= (~explosion_prev) & explosion_cur;
    add_mine_up <= (~add_mine_prev) & add_mine_cur;

    on_board = (pixel_x >= X_MATRIX) && (pixel_y >= Y_MATRIX) &&
               (pixel_x < X_MATRIX + (COLUMNS << tile_order)) &&
               (pixel_y < Y_MATRIX + (ROWS << tile_order));

    if (!on_board) begin
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
