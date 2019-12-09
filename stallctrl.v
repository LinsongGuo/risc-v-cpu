//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/17 20:50:26
// Design Name: 
// Module Name: stallctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stallctrl(
	input wire rst,

	input wire stallreq_from_id,
	input wire stallreq_from_mem,
	
	output reg[`StallBus] stall
    );

	always @ (*) begin 
		if (rst == `Enable) begin
			stall = 5'b00000;
		end else begin
			if (stallreq_from_mem == `Stop) begin
				stall = 5'b11111;
			end else if (stallreq_from_id == `Stop) begin
				stall = 5'b00111;
			end else begin
				stall = 5'b00000;
			end
		end
	end
endmodule
