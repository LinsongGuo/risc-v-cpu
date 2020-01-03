//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/29 18:40:33
// Design Name: 
// Module Name: BTB
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
`include "defines.v"
module BTB(
	input wire clk,
	input wire rst,
	input wire rdy,

	//input from if
	input wire read_from_if,
	input wire[31: 0] addr_from_if,

	//output to if
	output reg res_to_if,
	output reg[31: 0] addr_to_if,
    
 	//output to if_id
 	output reg jump_to_ifid,

	//input from ex
	input wire[31: 0] pc_from_ex,
	input wire branch_from_ex,
	input wire jump_from_ex,
	input wire[31: 0] jump_addr_from_ex
	);

	(* ram_style = "registers" *) reg valid_table[63: 0];
	(* ram_style = "registers" *) reg[1: 0] predict_table[63: 0];
	(* ram_style = "registers" *) reg[9: 0] tag_table[63: 0];
	(* ram_style = "registers" *) reg[17: 0] addr_table[63: 0];

	wire[5: 0] index_from_if;
	wire[9: 0] tag_from_if;

	assign index_from_if = addr_from_if[7: 2];
	assign tag_from_if = addr_from_if[17: 8];

	wire valid_if;
	wire predict_if;
	wire[9: 0] tag_if;
	wire[31: 0] addr_if;
	
	assign valid_if = valid_table[index_from_if];
	assign predict_if = predict_table[index_from_if][1: 1];
	assign tag_if = tag_table[index_from_if];
	assign addr_if = addr_table[index_from_if]; 
	
	wire[5: 0] index_from_ex;
	wire[9: 0] tag_from_ex;
	
	assign index_from_ex = pc_from_ex[7: 2];
	assign tag_from_ex = pc_from_ex[17: 8];
	
	integer i;
	initial begin
		for(i = 0; i < 64; i = i + 1) begin
			valid_table[i] = 1'b0;
			predict_table[i] = 2'b0;
			tag_table[i] = 10'b0;
			addr_table[i] = 18'b0;
		end
	end
	
	always @ (posedge clk) begin
		if (rst == `Disable && rdy == `Enable && branch_from_ex == 1'b1) begin
			valid_table[index_from_ex] <= 1'b1;
			tag_table[index_from_ex] <= tag_from_ex;
			addr_table[index_from_ex] <= jump_addr_from_ex;
			if (jump_from_ex == 1'b1) begin
				if (predict_table[index_from_ex] == 2'b10) begin 
					predict_table[index_from_ex] <= 2'b11;
				end else if (predict_table[index_from_ex] == 2'b01) begin 
					predict_table[index_from_ex] <= 2'b10;
				end else if (predict_table[index_from_ex] == 2'b00) begin
					predict_table[index_from_ex] <= 2'b01;
				end
			end else begin
				if (predict_table[index_from_ex] == 2'b11) begin 
					predict_table[index_from_ex] <= 2'b10;
				end else if (predict_table[index_from_ex] == 2'b10) begin 
					predict_table[index_from_ex] <= 2'b01;
				end else if (predict_table[index_from_ex] == 2'b01) begin
					predict_table[index_from_ex] <= 2'b00;
				end
			end
		end
	end

	always @ (*) begin
		if (rst == `Enable || rdy == `Disable) begin
			res_to_if = 1'b0;
			jump_to_ifid = 1'b0;
			addr_to_if = `ZeroWord;
		end else if (read_from_if == 1'b1 && valid_if == 1'b1 && predict_if == 1'b1 && tag_if == tag_from_if) begin
			res_to_if = 1'b1;
			jump_to_ifid = 1'b1;
			addr_to_if = {{14{1'b0}}, addr_if};	
		end else begin
			res_to_if = 1'b0;
			jump_to_ifid = 1'b0;
			addr_to_if = `ZeroWord;
		end
	end

	
endmodule
