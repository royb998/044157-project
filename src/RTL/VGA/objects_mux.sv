
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module  objects_mux (
    input logic clk,
    input logic resetN,

    input logic endgameDrawingRequest,
    input logic [7:0] endgameRGB,
    input logic playerDrawingRequest,
    input logic [7:0] playerRGB,
    input logic heartDrawingRequest,
    input logic [7:0] heartRGB,
    input logic objectDrawingRequest,
    input logic [7:0] objectRGB,
    input logic [7:0] RGB_MIF,

    output logic [7:0] RGBOut
);

always_ff@ (posedge clk or negedge resetN) begin
    if (!resetN) begin
            RGBOut  <= 8'b0;
    end

    /**
     * Prioritize drawing requests in the following order:
     * 1. End screen
     * 2. Player
     * 3. Heart
     * 4. Object (from matrix)
     * 5. Background (i.e. MIF)
     */
    else begin
        if (endgameDrawingRequest == 1'b1) begin
            RGBOut <= endgameRGB;
        end else if (playerDrawingRequest == 1'b1) begin
            RGBOut <= playerRGB;
        end else if (heartDrawingRequest == 1'b1) begin
            RGBOut <= heartRGB;
        end else if (objectDrawingRequest == 1'b1) begin
            RGBOut <= objectRGB;
        end else begin
            RGBOut <= RGB_MIF;
        end
    end
end

endmodule


