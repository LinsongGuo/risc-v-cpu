`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 00:15:37
// Design Name: 
// Module Name: if_id
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

module if_id(
	input wire clk,
	input wire rst,
	
    input wire if_flag,
    input wire if_first,
    input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,
	
	input wire[`StallBus] stall,

    output reg id_first,
	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
    );

    always @ (posedge clk) begin
    	if (rst == `Disable) begin
    		if (stall[1] == `Stop && stall[2] == `NoStop) begin
    			id_first <= 1'b0;
                id_pc <= `ZeroWord;
    			id_inst <= `ZeroWord;
            end else if (stall[1] == `NoStop && if_flag == 1'b1) begin
                id_first <= if_first;
                id_pc <= if_pc;
    			id_inst <= if_inst;
    		end else begin
                id_first <= 1'b0;
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end
    	end else begin
            id_first <= 1'b0;
    		id_pc <= `ZeroWord;
    		id_inst <= `ZeroWord;
		end
	end
endmodule
