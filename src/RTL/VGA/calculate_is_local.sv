


module calculate_is_local 	
( 
	input 	logic 	[10:0] pixelX,// current VGA pixel 
	input 	logic 	[10:0] pixelY,
	input 	logic 	[10:0] topLeftX, //position on the screen 
	input 	logic	 	[10:0] topLeftY,   // can be negative , if the object is partliy outside 
							
	output logic is_local	
) ;
  
  
always_comb begin
	if(topLeftX + 11'h10 == pixelX && topLeftY + 11'h10 == pixelY)
		is_local = 1'b1;
	else
		is_local = 1'b0;
end

endmodule
