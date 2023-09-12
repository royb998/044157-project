/// Assuming only one heart display is ready at any given time, output the
/// corresponding output RGB value.

module heart_selector (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input logic [2:0] lives,
    input logic [2:0] heart_drawing_requests,
    input logic [2:0][7:0] heart_rgb,
    
    output logic drawing_request,
    output logic [7:0] rgb
);

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        drawing_request <= 0;
        rgb <= 8'h00;
    end else begin
        drawing_request <= 1'b0;

        if (lives == 3'h0 || lives > 3'h3) begin
            rgb <= 8'h00;
        end else if (lives >= 3'h1 && heart_drawing_requests[0]) begin
            drawing_request <= 1'b1;
            rgb <= heart_rgb[0];
        end else if (lives >= 3'h2 && heart_drawing_requests[1]) begin
            drawing_request <= 1'b1;
            rgb <= heart_rgb[1];
        end else if (lives == 3'h3 && heart_drawing_requests[2]) begin
            drawing_request <= 1'b1;
            rgb <= heart_rgb[2];
        end
    end
end

endmodule : heart_selector
