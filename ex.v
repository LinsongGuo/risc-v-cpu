`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 14:35:41
// Design Name: 
// Module Name: ex
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

module ex(
    input wire rst,
    
    //input from id_ex
    input wire[`InstAddrBus] pc_i,
    input wire[`OpcodeBus] opcode_i,
    input wire[`OptBus] opt_i,
    input wire[`RegBus] rdata1_i,
    input wire[`RegBus] rdata2_i,
    input wire we_i,
    input wire[`RegAddrBus] waddr_i,
    input wire[`DataBus] imm_i,
    input wire[`ShamtBus] shamt_i,

    //output to ex_mem
    output reg[`OpcodeBus] opcode_o,
    output reg[`OptBus] opt_o,
    output reg we_o,
    output reg[`RegAddrBus] waddr_o,
    output reg[`RegBus] alu_o,
    output reg[`RegBus] rdata2_o
    );
    
    
    always @ (*) begin
        opcode_o = opcode_i;
        opt_o = opt_i;
        we_o = we_i;
        waddr_o = waddr_i;
        alu_o = `ZeroWord;
        rdata2_o = rdata2_i;
        if (rst == `Disable) begin
            case(opt_i)
                `OptLUI:
                    begin
                        alu_o = imm_i;
                    end
                `OptAUIPC:
                    begin
                        alu_o = $signed(pc_i) + $signed(imm_i);
                    end
                `OptJAL:
                    begin
                        alu_o = pc_i + 4;
                        
                    end
                `OptJALR:
                    begin
                       alu_o = pc_i + 4; 
                    end
                    /*
                `OptBEQ:
                    begin
                        cond_o = (rdata1_i == rdata2_i);
                        //pc_o = $signed(pc_i) + $signed(imm_i);
                    end
                `OptBNE:
                    begin
                        cond_o = (rdata1_i != rdata2_i);
                        //pc_o = $signed(pc_i) + $signed(imm_i);
                    end
                `OptBLT:
                    begin
                        cond_o = $signed(rdata1_i) < $signed(rdata2_i);
                        //pc_o = $signed(pc_i) + $signed(imm_i); 
                    end
                `OptBGE:
                    begin
                        cond_o = $signed(rdata1_i) >= $signed(rdata2_i);
                        //pc_o = $signed(pc_i) + $signed(imm_i);
                    end
                `OptBLTU:
                    begin
                        cond_o = rdata1_i < rdata2_i;
                        //pc_o = $signed(pc_i) + $signed(imm_i);
                    end
                `OptBGEU:
                    begin
                        cond_o = rdata1_i >= rdata2_i;
                        //pc_o = $signed(pc_i) + $signed(imm_i); 
                    end*/
                `OptLB:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptLH:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptLW:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptLBU:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptLHU:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptSB:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptSH:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptSW:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptADDI:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                    end
                `OptSLTI:
                    begin
                        alu_o = $signed(rdata1_i) < $signed(imm_i);
                    end
                `OptSLTIU:
                    begin
                        alu_o = rdata1_i < imm_i;
                    end
                `OptXORI:
                    begin
                        alu_o = rdata1_i ^ imm_i; 
                    end
                `OptORI:
                    begin
                        alu_o = rdata1_i | imm_i;
                    end
                `OptANDI:
                    begin
                        alu_o = rdata1_i & imm_i; 
                    end
                `OptSLLI:
                    begin
                        alu_o = rdata1_i << shamt_i;
                    end
                `OptSRLI:
                    begin
                        alu_o = rdata1_i >> shamt_i;
                    end
                `OptSRAI:
                    begin
                        alu_o = $signed(rdata1_i) >>> shamt_i;
                    end
                `OptADD:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(rdata2_i);
                    end
                `OptSUB:
                    begin
                        alu_o = $signed(rdata1_i) - $signed(rdata2_i);
                    end
                `OptSLL:
                    begin
                        alu_o = rdata1_i << rdata2_i[4: 0];
                    end
                `OptSLT:
                    begin
                        alu_o = $signed(rdata1_i) < $signed(rdata2_i);
                    end
                `OptSLTU:
                    begin
                        alu_o = rdata1_i < rdata2_i;
                    end
                `OptXOR:
                    begin
                        alu_o = rdata1_i ^ rdata2_i;
                    end
                `OptSRL:
                    begin
                        alu_o = rdata1_i >> rdata2_i[4: 0];
                    end
                `OptSRA:
                    begin
                        alu_o = $signed(rdata1_i) >>> rdata2_i[4: 0]; 
                    end
                `OptOR:
                    begin
                        alu_o = rdata1_i | rdata2_i;
                    end
                `OptAND:
                    begin
                        alu_o = rdata1_i & rdata2_i;
                    end
                default:
                    begin
                        we_o = `Disable;
                    end
            endcase               
        end
    end
    
     
endmodule
