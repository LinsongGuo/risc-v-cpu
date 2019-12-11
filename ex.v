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
    input wire prediction_i,
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
    output reg[`RegBus] rdata2_o,

    //output
    output reg branch_o,
    output reg[`InstAddrBus] jump_addr_o
    );
    
    
    always @ (*) begin
        if (rst == `Enable) begin
            opcode_o = `OpcodeNOP;
            opt_o = `OptNOP;
            we_o = `Disable;
            waddr_o = `NOPRegAddr;
            rdata2_o = `ZeroWord;
            alu_o = `ZeroWord;
            branch_o = 1'b0;
            jump_addr_o = `ZeroWord;
        end else if (rst == `Disable) begin
            opcode_o = opcode_i;
            opt_o = opt_i;
            we_o = we_i;
            waddr_o = waddr_i;
            rdata2_o = rdata2_i;
            case(opt_i)
                `OptLUI:
                    begin
                        alu_o = imm_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptAUIPC:
                    begin
                        alu_o = $signed(pc_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptJAL:
                    begin
                        alu_o = pc_i + 4; 
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptJALR:
                    begin
                        alu_o = pc_i + 4;
                        branch_o = 1'b1;
                        jump_addr_o = $signed(rdata1_i) + $signed(imm_i); 
                    end
                `OptBEQ:
                    begin
                        alu_o = `ZeroWord;
                        if (rdata1_i == rdata2_i) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptBNE:
                    begin
                        alu_o = `ZeroWord;
                        if (rdata1_i != rdata2_i) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptBLT:
                    begin
                        alu_o = `ZeroWord;
                        if ($signed(rdata1_i) < $signed(rdata2_i)) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptBGE:
                    begin
                        alu_o = `ZeroWord;
                        if ($signed(rdata1_i) >= $signed(rdata2_i)) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptBLTU:
                    begin
                        alu_o = `ZeroWord;
                        if (rdata1_i < rdata2_i) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptBGEU:
                    begin
                        alu_o = `ZeroWord;
                        if (rdata1_i >= rdata2_i) begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord;
                            end else begin
                                branch_o = 1'b1;
                                jump_addr_o = $signed(pc_i) + $signed(imm_i); 
                            end                         
                        end else begin
                            if (prediction_i == 1'b1) begin
                                branch_o = 1'b1;
                                jump_addr_o = pc_i + 32'b100;
                            end else begin
                                branch_o = 1'b0;
                                jump_addr_o = `ZeroWord; 
                            end
                        end
                    end
                `OptLB:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptLH:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptLW:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptLBU:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptLHU:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSB:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSH:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSW:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptADDI:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLTI:
                    begin
                        alu_o = $signed(rdata1_i) < $signed(imm_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLTIU:
                    begin
                        alu_o = rdata1_i < imm_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptXORI:
                    begin
                        alu_o = rdata1_i ^ imm_i; 
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptORI:
                    begin
                        alu_o = rdata1_i | imm_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptANDI:
                    begin
                        alu_o = rdata1_i & imm_i; 
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLLI:
                    begin
                        alu_o = rdata1_i << shamt_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSRLI:
                    begin
                        alu_o = rdata1_i >> shamt_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSRAI:
                    begin
                        alu_o = $signed(rdata1_i) >>> shamt_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptADD:
                    begin
                        alu_o = $signed(rdata1_i) + $signed(rdata2_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSUB:
                    begin
                        alu_o = $signed(rdata1_i) - $signed(rdata2_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLL:
                    begin
                        alu_o = rdata1_i << rdata2_i[4: 0];
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLT:
                    begin
                        alu_o = $signed(rdata1_i) < $signed(rdata2_i);
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSLTU:
                    begin
                        alu_o = rdata1_i < rdata2_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptXOR:
                    begin
                        alu_o = rdata1_i ^ rdata2_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSRL:
                    begin
                        alu_o = rdata1_i >> rdata2_i[4: 0];
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptSRA:
                    begin
                        alu_o = $signed(rdata1_i) >>> rdata2_i[4: 0]; 
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptOR:
                    begin
                        alu_o = rdata1_i | rdata2_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                `OptAND:
                    begin
                        alu_o = rdata1_i & rdata2_i;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
                default:
                    begin
                        alu_o = `ZeroWord;
                        branch_o = 1'b0;
                        jump_addr_o = `ZeroWord;
                    end
            endcase               
        end
    end
    
     
endmodule
