// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the bomb mini-project
// FSM, with present and next states

module bomb
    (
    input logic clk, 
    input logic resetN, 
    input logic pause, 
    input logic OneSecPulse, 
    input logic timerEnd,
	 input logic save,

    output logic countLoadN, 
    output logic countEnable, 
    output logic saved,
	 output logic explode
   );

//-------------------------------------------------------------------------------------------
	logic [0:2] timer_ns, timer_ps;
// state machine decleration 
    enum logic [2:0] {s_idle, s_arm, s_run, s_pause, s_pause1, s_pause2, s_explode, s_save } bomb_ps, bomb_ns;
    
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always_ff @(posedge clk or negedge resetN)
   begin
       
   if ( !resetN ) begin // Asynchronic reset
        bomb_ps <= s_idle;
		  timer_ps <= 3'b0;
	  end
   
    else begin        // Synchronic logic FSM
        bomb_ps <= bomb_ns;
        timer_ps <= timer_ns;
	  end
    end // always sync
    
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//                                  (not seperating to two different always sections)   
always_comb // Update next state and outputs
    begin
    // set all default values 
        bomb_ns = bomb_ps;
		  timer_ns = timer_ps; 
        countEnable = 1'b0;
        countLoadN = 1'b1;
		  explode = 1'b0;
		  saved = 1'b0;

        case (bomb_ps)
        
            //Note: the implementation of the idle state is already given you as an example
            s_idle: begin
						
                    bomb_ns = s_arm; 
						  //countLoadN = 1'b0;
                end // idle
				s_arm: begin
                    bomb_ns = s_run; 
						  countLoadN = 1'b0;
                end // idle
            s_run: begin
                if (timerEnd == 1'b1) begin
                    bomb_ns = s_explode;
                end
                if (pause == 1'b1) begin
                    bomb_ns = s_pause;
                end
					 
					 if (save == 1'b1) begin
                    bomb_ns = s_save;
                end
					 
                countEnable = 1'b1;
				 end // run
                    
            s_pause: begin
					
               if (OneSecPulse == 1'b1) begin
						timer_ns = timer_ps + 3'b001;
					end
					
					if (timer_ps == 3'b111) begin
						timer_ns = timer_ps + 3'b001;
						bomb_ns = s_pause1;
					end

                if (save == 1'b1) begin
                    bomb_ns = s_save;
                end
//                
					end // pause
                    
            s_pause1: begin
                
                if (OneSecPulse == 1'b1) begin
                    bomb_ns = s_pause2;
                end
                if (save == 1'b1) begin
                    bomb_ns = s_save;
                end
                end // pause1
                    
            s_pause2: begin
                
                if (OneSecPulse == 1'b1) begin
                    bomb_ns = s_run;
                end
                if (save == 1'b1) begin
                    bomb_ns = s_save;
                end
                end // pause2
                        
            s_explode: begin
                    explode = 1'b1;
                    
                end // lampOff
                
            s_save: begin
						  saved = 1'b1;

                end // lampOn
                        
                        
        endcase
    end // always comb
    
endmodule
