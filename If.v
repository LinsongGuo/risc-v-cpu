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

	output reg[`InstAddrBus] pc_o,

	//input from memctrl
	input wire r_from_memctrl,
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg r_to_memctrl,
	output reg flag_to_ctrl,
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,

	//output to if_id
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[2: 0] sent_to_memctrl;
    reg[2: 0] received_from_memctrl;
    
    initial begin
    	pc_o = `ZeroWord;
    end

	always @(posedge clk) begin
		if (rst == `Enable) begin
			r_to_memctrl = 1'b0;
			flag_to_ctrl = 1'b0;
			addr_to_memctrl = `ZeroWord;
			stallreq_from_if = 1'b1;
			flag_o = 1'b0;
			pc_o = `ZeroWord;
			inst_o = `ZeroWord;
			sent_to_memctrl = 3'b000;
    		received_from_memctrl = 2'b00;
		end else begin
			if (stall[0] == `NoStop) begin
				if (sent_to_memctrl == 3'b000) begin
					pc_o = pc_o + 32'b1;
					addr_to_memctrl = pc_i;
					sent_to_memctrl = 3'b001;
					received_from_memctrl = 3'b000;
				end else if (sent_to_memctrl == 3'b001) begin
					pc_o = pc_o + 32'b1;
					addr_to_memctrl = pc_i;
					sent_to_memctrl = 3'b010;
				end else if (sent_to_memctrl == 3'b010) begin
					pc_o = pc_o + 32'b1;
					addr_to_memctrl = pc_i;
					sent_to_memctrl = 3'b011;
				end else if (sent_to_memctrl == 3'b011) begin
					pc_o = pc_o + 32'b1;
					addr_to_memctrl = pc_i;
					sent_to_memctrl = 3'b100;
				end 

				if (r_from_memctrl == 1'b1) begin
					if (received_from_memctrl == 3'b000) begin
						flag_o = 1'b0;
						inst_o = data_from_memctrl;
						received_from_memctrl = 3'b001;
					end else if (received_from_memctrl == 3'b001) begin
						flag_o = 1'b0;	
						inst_o = {{16{1'b0}}, data_from_memctrl, inst_o[7: 0]};
						received_from_memctrl = 3'b010;
					end else if (received_from_memctrl == 3'b010) begin
						flag_o = 1'b0;	
						inst_o = {{8{1'b0}}, data_from_memctrl, inst_o[15: 0]};
						received_from_memctrl = 3'b011;
					end else if(received_from_memctrl == 3'b011) begin
						flag_o = 1'b1;	
						inst_o = {data_from_memctrl, inst_o[23: 0]};
						received_from_memctrl = 3'b100;
						sent_to_memctrl = 3'b000;
					end else begin
						flag_o = 1'b0;
					end
				else begin
					flag_o = 1'b0;
				end
			end else begin
				flag_o = 1'b0;				
			end				
		end
	end
endmodule
