
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021
//updated --Eyal Lev 2021


module game_controller (
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic draw_request_player,
    input logic draw_request_object,
    input logic draw_request_bg,

    output logic collision, // active in case of collision between two objects
    output logic SingleHitPulse // critical code, generating A single pulse in a frame
    );

assign collision = draw_request_player && (draw_request_object || draw_request_bg);

logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        flag <= 1'b0;
        SingleHitPulse <= 1'b0;
    end else begin
        SingleHitPulse <= 1'b0;

        if(startOfFrame) begin
            flag <= 1'b0 ; // reset for next time
        end

        if (collision && (flag == 1'b0)) begin
            flag <= 1'b1; // to enter only once
            SingleHitPulse <= 1'b1 ;
        end
    end
end

endmodule
