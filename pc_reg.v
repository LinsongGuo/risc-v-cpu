`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 00:19:03
// Design Name: 
// Module Name: pc_reg
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

module pc_reg(
    input wire clk,
    input wire rst,

    //input from stall
    input wire[`StallBus] stall,

    //output to if.v
    output reg[`InstAddrBus] pc_o,
    
    output reg stallreq_from_pcreg
    );
	
	always @ (posedge clk) begin    
		if (rst == `Enable) begin
			pc_o <= `ZeroWord;
		end else begin
			if (stall[0] == `NoStop) begin
				pc_o <= pc_o + 4'h4;
				stallreq_from_pcreg <= 1'b1;
		    end else begin
		    	stallreq_from_pcreg <= 1'b0;
		    end
		end 

	end
	
endmodule
