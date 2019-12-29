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
    input wire rdy,
	
    //input from stallctrl
    input wire[`StallBus] stall,

    //input from BTB
    input wire jump_from_BTB,

    //input from if
    input wire if_flag,
    input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,	
    
    //input from ex
    input wire goback_from_ex,

    //output to id
    output reg id_flag,
    output reg id_jump,
	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
    );

    always @ (posedge clk) begin
    	if (rst == `Enable) begin
            id_flag <= `Disable;
            id_jump <= 1'b0;
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else begin
            if (stall[1] == `Stop && stall[2] == `NoStop) begin
                id_flag <= `Disable;
                id_jump <= 1'b0;
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end else if (stall[1] == `NoStop) begin
                if (goback_from_ex == 1'b1) begin
                    id_flag <= `Disable;
                    id_jump <= 1'b0;
                    id_pc <= `ZeroWord;
                    id_inst <= `ZeroWord;
                end else if (if_flag == 1'b1) begin
                    id_flag <= if_flag;
                    id_pc <= if_pc;
                    id_inst <= if_inst;
                    if (jump_from_BTB == 1'b1) begin
                        id_jump <= 1'b1;
                    end else begin
                        id_jump <= 1'b0;
                    end
                    //$write("%04x %08x %d\n", if_pc, if_inst, jump_from_BTB);    
                end else begin
                    id_flag <= `Disable;
                    id_jump <= 1'b0;
                    id_pc <= `ZeroWord;
                    id_inst <= `ZeroWord;
                end  
            end
    	end
	end
endmodule
