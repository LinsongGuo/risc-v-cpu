//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 14:46:55
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
    input wire clk,
    input wire rst,
    
    //input from ex
    input wire[`OpcodeBus] ex_opcode,
    input wire[`OptBus] ex_opt,
    input wire ex_we,
    input wire[`RegAddrBus] ex_waddr,
    input wire[`RegBus] ex_alu,
    input wire[`RegBus] ex_rdata2,
    
    input wire[`StallBus] stall,

    //outut to mem
    output reg[`OpcodeBus] mem_opcode,
    output reg[`OptBus] mem_opt,
    output reg mem_we,
    output reg[`RegAddrBus] mem_waddr,
    output reg[`RegBus] mem_alu,
    output reg[`RegBus] mem_rdata2
    );
    
    always @ (posedge clk) begin
        if (rst == `Enable) begin
            mem_opcode <= 7'b0;
            mem_opt <= `OptNOP;
            mem_we <= `Disable;
            mem_waddr <= `NOPRegAddr;
            mem_alu <= `ZeroWord;
            mem_rdata2 <= `ZeroWord; 
        end else begin   
            if (stall[3] == `NoStop) begin
                mem_opcode <= ex_opcode;
                mem_opt <= ex_opt;
                mem_we <= ex_we;
                mem_waddr <= ex_waddr;
                mem_alu <= ex_alu;
                mem_rdata2 <= ex_rdata2;   
            end 
        end
    end
    
endmodule
