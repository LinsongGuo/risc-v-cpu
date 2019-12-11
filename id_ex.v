//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 14:21:04
// Design Name: 
// Module Name: id_ex
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

module id_ex(
    input wire clk,
    input wire rst,
    
    //input from id
    input wire id_prediction,
    input wire[`InstAddrBus] id_pc,
    input wire[`OpcodeBus] id_opcode,
    input wire[`OptBus] id_opt,
    input wire[`RegBus] id_rdata1,
    input wire[`RegBus] id_rdata2,
    input wire id_we,
    input wire[`RegAddrBus] id_waddr,
    input wire[`DataBus] id_imm,
    input wire[`ShamtBus] id_shamt,
    
    //input from stallctrl
    input wire[`StallBus] stall,

    //input from ex
    input wire branch_from_ex,

    //output to ex
    output reg ex_prediction,
    output reg[`InstAddrBus] ex_pc,
    output reg[`OpcodeBus] ex_opcode,
    output reg[`OptBus] ex_opt,
    output reg[`RegBus] ex_rdata1,
    output reg[`RegBus] ex_rdata2,
    output reg ex_we,
    output reg[`RegAddrBus] ex_waddr,
    output reg[`DataBus] ex_imm,
    output reg[`ShamtBus] ex_shamt
    );
    
    
    always @ (posedge clk) begin
        if (rst == `Enable) begin
            ex_prediction <= 1'b0;
            ex_pc <= `ZeroWord;
            ex_opcode <= `OpcodeNOP;
            ex_opt <= `OptNOP;
            ex_rdata1 <= `ZeroWord;
            ex_rdata2 <= `ZeroWord;
            ex_we <= `Disable;
            ex_waddr <= `NOPRegAddr;
            ex_imm <= `ZeroWord;
            ex_shamt <= 5'b0;
        end else begin
            if (stall[2] == `Stop && stall[3] == `NoStop) begin
                ex_prediction <= 1'b0;
                ex_pc <= `ZeroWord;
                ex_opcode <= `OpcodeNOP;
                ex_opt <= `OptNOP;
                ex_rdata1 <= `ZeroWord;
                ex_rdata2 <= `ZeroWord;
                ex_we <= `Disable;
                ex_waddr <= `NOPRegAddr;
                ex_imm <= `ZeroWord;
                ex_shamt <= `NOPShamt;    
            end else if (stall[2] == `NoStop) begin
                if (branch_from_ex == 1'b1) begin
                    ex_prediction <= 1'b0;
                    ex_pc <= `ZeroWord;
                    ex_opcode <= `OpcodeNOP;
                    ex_opt <= `OptNOP;
                    ex_rdata1 <= `ZeroWord;
                    ex_rdata2 <= `ZeroWord;
                    ex_we <= `Disable;
                    ex_waddr <= `NOPRegAddr;
                    ex_imm <= `ZeroWord;
                    ex_shamt <= 5'b0;
                end else begin
                    ex_prediction <= id_prediction;
                    ex_pc <= id_pc;
                    ex_opcode <= id_opcode;
                    ex_opt <= id_opt;
                    ex_rdata1 <= id_rdata1;
                    ex_rdata2 <= id_rdata2;
                    ex_we <= id_we;
                    ex_waddr <= id_waddr;
                    ex_imm <= id_imm;
                    ex_shamt <= id_shamt;   
                end
            end
        end
    end
endmodule


