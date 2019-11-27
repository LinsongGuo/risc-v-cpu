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
	
    //input from stallctrl
    input wire[`StallBus] stall,

    //input from if
    input wire if_flag,
    input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,	
    
    //output to id
    output reg id_flag,
	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
    );

    always @ (posedge clk) begin
    	if (rst == `Enable) begin
            id_flag <= `Disable;
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else begin
            if (stall[1] == `Stop && stall[2] == `NoStop) begin
        		id_flag <= `Disable;
                id_pc <= `ZeroWord;
        		id_inst <= `ZeroWord;
            end else if (stall[1] == `NoStop && if_flag == 1'b1) begin
                id_flag <= if_flag;
                id_pc <= if_pc - 32'b100;
        		id_inst <= if_inst;
            //    $write("%04x %08x\n", if_pc - 32'b100, if_inst);
        	end else begin
                id_flag <= `Disable;
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end
    	end
	end
endmodule
