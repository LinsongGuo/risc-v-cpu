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

	//input from pc_reg
	input wire flag_i,
	input wire[`InstAddrBus] pc_i,

	//input from memctrl
	input wire r_from_memctrl,
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg r_to_memctrl,
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,

	//output to stallctrl
	output reg stallreq_from_if,

	//output to if_id
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[2: 0] sent_to_memctrl;
    reg[1: 0] received_from_memctrl;

    initial begin
    	r_to_memctrl <= 1'b0;
		addr_to_memctrl <= `ZeroWord;
		stallreq_from_if <= 1'b0;
		flag_o <= 1'b0;
		pc_o <= `ZeroWord;
		inst_o <= `ZeroWord;
    	sent_to_memctrl <= 3'b000;
    	received_from_memctrl <= 2'b00;
    end

	always @(posedge clk) begin
		if (rst == `Enable) begin
			r_to_memctrl <= 1'b0;
			addr_to_memctrl <= `ZeroWord;
			stallreq_from_if <= 1'b0;
			flag_o <= 1'b0;
			pc_o <= `ZeroWord;
			inst_o <= `ZeroWord;
			sent_to_memctrl <= 3'b000;
    		received_from_memctrl <= 2'b00;
		end else begin
			if (flag_i == 1'b1) begin
				r_to_memctrl <= 1'b1;
				addr_to_memctrl <= pc_i;
				stallreq_from_if <= 1'b1;
				flag_o <= 1'b0;	
				pc_o <= `ZeroWord;
				inst_o <= `ZeroWord;
				sent_to_memctrl <= 3'b001;
    			received_from_memctrl <= 2'b00;
			end else begin	
				if (r_from_memctrl == 1'b1) begin
					if (received_from_memctrl == 2'b00) begin
						flag_o <= 1'b0;
						pc_o <= `ZeroWord;		
						inst_o <= data_from_memctrl;
						stallreq_from_if <= 1'b1;
						received_from_memctrl <= 2'b01;
					end else if (received_from_memctrl == 2'b01) begin
						flag_o <= 1'b0;	
						pc_o <= `ZeroWord;		
						inst_o <= (inst_o << 8) | data_from_memctrl;
						stallreq_from_if <= 1'b1;
						received_from_memctrl <= 2'b10;
					end else if (received_from_memctrl == 2'b10) begin
						flag_o <= 1'b0;	
						pc_o <= `ZeroWord;		
						inst_o <= (inst_o << 8) | data_from_memctrl;
						stallreq_from_if <= 1'b1;
						received_from_memctrl <= 2'b11;
					end else begin
						flag_o <= 1'b1;	
						pc_o <= pc_i;
						inst_o <= (inst_o << 8) | data_from_memctrl;
						stallreq_from_if <= 1'b0;
						received_from_memctrl <= 2'b00;
					end
				end else begin
					flag_o <= 1'b0;
					pc_o <= `ZeroWord;		
				end

				if (sent_to_memctrl == 3'b001) begin
					r_to_memctrl <= 1'b1;
					addr_to_memctrl <= pc_i + 32'b1;
					stallreq_from_if <= 1'b1;
					sent_to_memctrl <= 3'b010;
				end else if (sent_to_memctrl == 3'b010) begin
					r_to_memctrl <= 1'b1;
					addr_to_memctrl <= pc_i + 32'b10;
					stallreq_from_if <= 1'b1;
					sent_to_memctrl <= 3'b011;
				end else if (sent_to_memctrl == 3'b011) begin
					r_to_memctrl <= 1'b1;
					addr_to_memctrl <= pc_i + 32'b11;
					stallreq_from_if <= 1'b1;
					sent_to_memctrl <= 3'b100;		
				end else begin
					r_to_memctrl <= 1'b0;
					addr_to_memctrl <= `ZeroWord;
				end
			end
		end
	end
endmodule
