`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 19:14:57
// Design Name: 
// Module Name: if
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

module If(
	input wire clk,
	input wire rst,
	
	//input from id(branches)
	input wire branch_from_id,
	input wire[`InstAddrBus] jump_addr_from_id,

	//input from memctrl
	input wire r_from_memctrl,
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg flag_to_memctrl,
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,
	input wire[1: 0] mem_rw_to_memctrl,

	//output to if_id
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[2: 0] sent_to_memctrl;
    reg[2: 0] received_from_memctrl;
    

	always @(posedge clk) begin
		if (rst == `Enable) begin
			flag_to_memctrl = `Disable;
			addr_to_memctrl = `ZeroWord;
			pc_o = `ZeroWord;
			flag_o = 1'b0;
			inst_o = `ZeroWord;
			sent_to_memctrl = 3'b001;
    		received_from_memctrl = 3'b000;
		end else begin
			if (branch_from_id == `Enable) begin
				pc_o = jump_addr_from_id;
				inst_o = `ZeroWord;
				flag_o = `Disable;
				flag_to_memctrl = `Disable;
				addr_to_memctrl = pc_o;
				sent_to_memctrl = 3'b001;
				received_from_memctrl = 3'b000;	
			end else begin
				if (mem_rw_to_memctrl == 2'b00) begin
					if (sent_to_memctrl == 3'b000) begin
						pc_o = pc_o + 32'b1;
						inst_o = `ZeroWord;
						flag_to_memctrl = `Disable;
						addr_to_memctrl = pc_o;
						sent_to_memctrl = 3'b001;
						received_from_memctrl = 3'b000;
					end else if (sent_to_memctrl == 3'b001) begin
						pc_o = pc_o + 32'b1;
						flag_to_memctrl = `Enable;
						addr_to_memctrl = pc_o;
						sent_to_memctrl = 3'b010;
					end else if (sent_to_memctrl == 3'b010) begin
						pc_o = pc_o + 32'b1;
						flag_to_memctrl = `Enable;
						addr_to_memctrl = pc_o;
						sent_to_memctrl = 3'b011;
					end else if (sent_to_memctrl == 3'b011) begin
						pc_o = pc_o + 32'b1;
						flag_to_memctrl = `Enable;
						addr_to_memctrl = pc_o;
						sent_to_memctrl = 3'b100;
					end
				end 

				if (r_from_memctrl == 1'b1) begin
					if (received_from_memctrl == 3'b000) begin
						flag_o = `Disable;
						inst_o = data_from_memctrl;
						received_from_memctrl = 3'b001;
					end else if (received_from_memctrl == 3'b001) begin
						flag_o = `Disable;	
						inst_o = {{16{1'b0}}, data_from_memctrl, inst_o[7: 0]};
						received_from_memctrl = 3'b010;
					end else if (received_from_memctrl == 3'b010) begin
						flag_o = `Disable;	
						inst_o = {{8{1'b0}}, data_from_memctrl, inst_o[15: 0]};
						received_from_memctrl = 3'b011;
					end else if(received_from_memctrl == 3'b011) begin
						flag_o = `Enable;
						flag_to_memctrl = `Disable;	
						inst_o = {data_from_memctrl, inst_o[23: 0]};
						received_from_memctrl = 3'b100;
						sent_to_memctrl = 3'b000;
					end else begin
						flag_o = `Disable;
					end
				end else begin
					flag_o = `Disable;
				end			

				if (sent_to_memctrl == received_from_memctrl) begin
					flag_to_memctrl = `Disable;
				end
			end
		end
	end
endmodule
