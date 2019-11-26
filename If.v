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
	
	//input from ex(branches)
	input wire branch_from_id,
	input wire[`InstAddrBus] jump_addr_from_id,

	//input from memctrl
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,

	//output to if_id
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[3: 0] if_state;

	always @ (posedge clk) begin
		if (rst == `Enable) begin
			addr_to_memctrl <= `ZeroWord;
			pc_o <= `ZeroWord;
			flag_o <= 1'b0;
			inst_o <= `ZeroWord;
			if_state <= 4'b0000;
		
		end else begin
			if (branch_from_id == 1'b1) begin
				if (!stall[0]) begin
					addr_to_memctrl <= jump_addr_from_id;
					pc_o <= jump_addr_from_id + 32'b1;
					flag_o <= 1'b0;
					inst_o <= `ZeroWord;
					if_state <= 4'b0001;
				end else begin
					addr_to_memctrl <= `ZeroWord;
					pc_o <= jump_addr_from_id;
					flag_o <= 1'b0;
					inst_o <= `ZeroWord;
					if_state <= 4'b0000;
				end
				
			end else begin
				if (if_state == 4'b0000) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						flag_o <= 1'b0;
						inst_o <= `ZeroWord;
						if_state <= 4'b0001;
					end
				
				end else if (if_state == 4'b0001) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						if_state <= 4'b0010;	
					end else begin
						if_state <= 4'b1001;
					end

				end else if (if_state == 4'b1001) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						if_state <= 4'b0010;
					end 

				end	else if (if_state == 4'b0010) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						inst_o <= {{24{1'b0}}, data_from_memctrl};
						if_state <= 4'b0011;	
					end else begin
						inst_o <= {{24{1'b0}}, data_from_memctrl};
						if_state <= 4'b1010;
					end

				end else if (if_state == 4'b1010) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						if_state <= 4'b0011;
					end

				end else if (if_state == 4'b0011) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						inst_o <= {{16{1'b0}}, data_from_memctrl, inst_o[7: 0]};
						if_state = 4'b0100;
					end else begin
						inst_o <= {{16{1'b0}}, data_from_memctrl, inst_o[7: 0]};
						if_state <= 4'b1011;
					end
				
				end else if (if_state == 4'b1011) begin
					if (!stall[0]) begin
						addr_to_memctrl <= pc_o;
						pc_o <= pc_o + 32'b1;
						if_state <= 4'b0100;
					end 

				end else if (if_state == 4'b0100) begin
					if (!stall[0]) begin
						inst_o <= {{8{1'b0}}, data_from_memctrl, inst_o[15: 0]};
						if_state <= 4'b0101;
					end else begin
						inst_o <= {{8{1'b0}}, data_from_memctrl, inst_o[15: 0]};
						if_state <= 4'b1100;
					end

				end else if (if_state == 4'b1100) begin
					if (!stall[0]) begin
						if_state <= 4'b0101;
					end

				end else if (if_state == 4'b0101) begin
					if (!stall[0]) begin
						inst_o <= {data_from_memctrl, inst_o[23: 0]};
						flag_o <= 1'b1;
						if_state <= 4'b0000;
					end else begin
						inst_o <= {data_from_memctrl, inst_o[23: 0]};
						if_state <= 4'b1101;
					end
				
				end else if (if_state == 4'b1101) begin
					if (!stall[0]) begin
						flag_o <= 1'b1;
						if_state <= 4'b0000;
					end
				end

			end
		end
	end
	
endmodule
