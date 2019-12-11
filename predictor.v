`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/10 19:56:50
// Design Name: 
// Module Name: predictor
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


module predictor(
	input wire clk,
	input wire rst,

	input wire[7: 0] addr_from_if,

	input wire flag_from_ex,
	input wire[7: 0] addr_from_ex,
	input wire branch_from_ex,

	output reg prediction_to_if
    );

	reg[1: 0] history_table[255: 0];
	
	integer i;
	initial begin
		gloabl = 2'b00;
		for (i = 0; i < 256; i = i + 1) begin
			history_table[0][i] = 2'b0;
			history_table[1][i] = 2'b0;
			history_table[2][i] = 2'b0;
			history_table[3][i] = 2'b0;
		end
	end

	always @ (*) begin
		if (rst == `Enable) begin
			prediction_to_if = 1'b0;
		end else begin
			prediction_to_if = history_table[addr_from_if][1];
		end
	end  

	always @ (posedge clk) begin
		if (rst == `Disable && flag_from_ex == 1'b0) begin
			if (history_table[addr_from_ex] == 2'b11) begin
				if (branch_from_ex == 1'b0) begin
					history_table[addr_from_ex] <= 2'b10;
				end
			end	else if (history_table[addr_from_ex] == 2'b10) begin
				if (branch_from_ex == 1'b1) begin
					history_table[addr_from_ex] <= 2'b11; 
				end else begin
					history_table[addr_from_ex] <= 2'b01;
				end
			end else if (history_table[addr_from_ex] == 2'b01) begin
				if (branch_from_ex == 1'b1) begin
					history_table[addr_from_ex] <= 2'b10;
				end else begin
					history_table[addr_from_ex] <= 2'b00;
				end
			end else begin
				if (branch_from_ex == 1'b1) begin
					history_table[addr_from_ex] <= 2'b01;
				end
			end
		end
	end
endmodule
