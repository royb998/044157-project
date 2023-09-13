
module object_matrix (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input logic [10:0] pixel_x,
    input logic [10:0] pixel_y,
    input logic collision, // indicates if there is a collision with the player on the current pixel
    input logic explosion, // Indicates explosion direction
    input logic one_sec,
    input logic add_user_bomb,
    input logic is_player_location,

    output logic [10:0] tile_x, // top-left pixel of selected tile
    output logic [10:0] tile_y,
    output logic mine_exploded,
	 output logic game_won,
    output logic [3:0] object, // indicator for object in selected tile
    output reg [3:0] mine_count,
	 output logic pause_time
);

parameter logic [7:0] TRANSPARENT_COLOUR = 8'hFF;

parameter logic [10:0] X_MATRIX = 11'h020; // Distance from screen left.
parameter logic [10:0] Y_MATRIX = 11'h060; // Distance from screen top.
localparam [4:0] ROWS = 11;
localparam [4:0] COLUMNS = 17;
parameter logic [3:0] tile_order = 5; // Tile size = 2**order

/* Different values for different objects:
    0: Background
    1: Persistent wall
    2: Sturdy wall
    3: Brittle wall
    4: Added mine
    5: Static mine
    6: Time bomb
    7: Time booster
    8: User bomb
    9: Sturdy explosion
    a: Brittle explosion
*/
logic [0:ROWS - 1][0:COLUMNS - 1] [3:0] objects;

parameter logic [3:0] max_mines = 10;
parameter logic [3:0] max_bombs = 1;

logic [3:0] bomb_count = 4'h0;

logic collision_prev = 1'b0;
logic collision_cur = 1'b0;
logic collision_up = 1'b0;
logic explosion_prev = 1'b0;
logic explosion_cur = 1'b0;
logic explosion_up = 1'b0;
logic add_mine_prev = 1'b0;
logic add_mine_cur = 1'b0;
logic add_mine_up = 1'b0;
logic splitter = 1'b0;
logic mine_time_toggle = 1'b0;
logic bomb_time_toggle = 1'b0;

logic mine_time_toggle_off = 1'b0;
logic bomb_time_toggle_off = 1'b0;
logic on_board;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mine_exploded <= 1'b0;
        game_won <= 1'b0;

        collision_prev <= 1'b0;
        explosion_prev <= 1'b0;
        bomb_count <= 4'h0;
        mine_count <= 4'h0;

        objects <= {
            {4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h2, 4'h3, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h5, 4'h3, 4'h0, 4'h0, 4'h7},
            {4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h2, 4'h1, 4'h2, 4'h1, 4'h0},
            {4'h0, 4'h2, 4'h2, 4'h5, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h2, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h2, 4'h0},
            {4'h0, 4'h1, 4'h3, 4'h1, 4'h0, 4'h1, 4'h2, 4'h1, 4'h2, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h2, 4'h1, 4'h0},
            {4'h0, 4'h0, 4'h0, 4'h5, 4'h0, 4'h3, 4'h0, 4'h0, 4'h0, 4'h2, 4'h0, 4'h3, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0},
            {4'h0, 4'h1, 4'h2, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h2, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0},
            {4'h0, 4'h0, 4'h2, 4'h3, 4'h0, 4'h9, 4'h0, 4'h0, 4'h0, 4'h2, 4'h0, 4'h0, 4'h0, 4'h2, 4'h3, 4'h3, 4'h0},
            {4'h0, 4'h1, 4'h2, 4'h1, 4'h2, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0},
            {4'h0, 4'h0, 4'h5, 4'h2, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h3, 4'h3},
            {4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h0, 4'h1, 4'h2, 4'h1, 4'h3, 4'h1, 4'h2},
            {4'h7, 4'h0, 4'h0, 4'h2, 4'h3, 4'h2, 4'h2, 4'h0, 4'h0, 4'h0, 4'h3, 4'h0, 4'h0, 4'h0, 4'h3, 4'h2, 4'h6},
        };
    end
    else begin
        mine_exploded <= 1'b0;

        if(one_sec) begin
            if(splitter) begin
                mine_time_toggle <= 1'b1;
                bomb_time_toggle <= 1'b1;
                splitter <= 1'b0;
            end
            else begin
                splitter <= 1'b1;
            end
        end
        if (on_board) begin
            case (objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order])
                4'h0: begin
                    if (add_user_bomb && is_player_location && (bomb_count < max_bombs)) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h8;
                        bomb_count <= bomb_count + 4'h1;
                        bomb_time_toggle <= 1'b0;
                    end else if (mine_time_toggle && (mine_count < max_mines)) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h4;
                        mine_count <= mine_count + 4'h1;
                        mine_time_toggle <= 1'b0;
                    end
                end
                4'h4: begin
                    if (collision_up) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h0;
                        mine_count <= mine_count - 1;
                        mine_exploded <= 1'b1;
                    end 
                end
                4'h5: begin
                    if (collision_up) begin
                            objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h0;
                            mine_exploded <= 1'b1;
                    end 
                end
                4'h6: begin
                    if (collision_up) begin
                        game_won <= 1'b1;
                    end
                end
                4'h7: begin
                    if (collision_up) begin
                        pause_time <= 1'b1;
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h0;
                    end
                end
                4'h8: begin
                    if(bomb_time_toggle) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'ha;
								bomb_count <= bomb_count - 4'h1;
                        if (explosion) begin
                            if (((pixel_y - Y_MATRIX) >> tile_order) != 0) begin
                                if(objects[((pixel_y - Y_MATRIX) >> tile_order) - 1][(pixel_x - X_MATRIX) >> tile_order] != 4'h1) begin
                                    if(objects[((pixel_y - Y_MATRIX) >> tile_order) - 1][(pixel_x - X_MATRIX) >> tile_order] == 4'h2) begin
                                        objects[((pixel_y - Y_MATRIX) >> tile_order) - 1][(pixel_x - X_MATRIX) >> tile_order] <= 4'h9;
                                    end else begin
                                        objects[((pixel_y - Y_MATRIX) >> tile_order) - 1][(pixel_x - X_MATRIX) >> tile_order] <= 4'ha;
                                    end
                                end
                            end
                            if(((pixel_y - Y_MATRIX) >> tile_order) != ROWS - 1) begin
                                if(objects[((pixel_y - Y_MATRIX) >> tile_order) + 1][(pixel_x - X_MATRIX) >> tile_order] != 4'h1) begin
                                    if(objects[((pixel_y - Y_MATRIX) >> tile_order) + 1][(pixel_x - X_MATRIX) >> tile_order] == 4'h2) begin
                                        objects[((pixel_y - Y_MATRIX) >> tile_order) + 1][(pixel_x - X_MATRIX) >> tile_order] <= 4'h9;
                                    end else begin
                                        objects[((pixel_y - Y_MATRIX) >> tile_order) + 1][(pixel_x - X_MATRIX) >> tile_order] <= 4'ha;
                                    end
                                end
                            end
                        end else begin
                            if(((pixel_x - X_MATRIX) >> tile_order) != 0) begin
                                if(objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) - 1] != 4'h1) begin
                                    if(objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) - 1] == 4'h2) begin
                                        objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) - 1] <= 4'h9;
                                    end else begin
                                        objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) - 1] <= 4'ha;
                                    end
                                end
                            end
                            if(((pixel_x - X_MATRIX) >> tile_order) != COLUMNS - 1) begin
                                if(objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) + 1] != 4'h1) begin
                                    if(objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) + 1] == 4'h2) begin
                                        objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) + 1] <= 4'h9;
                                    end else begin
                                        objects[(pixel_y - Y_MATRIX) >> tile_order][((pixel_x - X_MATRIX) >> tile_order) + 1] <= 4'ha;
                                    end
                                end
                            end
                        end
                        bomb_time_toggle <= 1'b0;
                    end
                end
                4'h9: begin
                    if (splitter) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h3;
                    end
                end
                4'ha: begin
                    if (splitter) begin
                        objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order] <= 4'h0;
                    end
                end
            endcase
        end

        collision_cur <= collision;
        collision_prev <= collision_cur;
        add_mine_cur <= one_sec;
        add_mine_prev <= add_mine_cur;
    end
end

always_comb begin
    collision_up = (~collision_prev) & collision_cur;
    //add_mine_up <= (~add_mine_prev) & add_mine_cur;

    on_board = (pixel_x >= X_MATRIX) && (pixel_y >= Y_MATRIX) &&
               (pixel_x < X_MATRIX + (COLUMNS << tile_order)) &&
               (pixel_y < Y_MATRIX + (ROWS << tile_order));

    if (!on_board) begin
        tile_x = 11'h0;
        tile_y = 11'h0;
        object = 4'h0;
    end
    else begin
        tile_x = pixel_x & 11'h7E0;
        tile_y = pixel_y & 11'h7E0;

        object = objects[(pixel_y - Y_MATRIX) >> tile_order][(pixel_x - X_MATRIX) >> tile_order];
    end
end

endmodule : object_matrix
