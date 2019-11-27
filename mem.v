//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 14:55:36
// Design Name: 
// Module Name: mem
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

module mem(
    input wire clk,
    input wire rst,
    
    //input from ex_mem
    input wire[`OpcodeBus] opcode_i,
    input wire[`OptBus] opt_i,
    input wire we_i,
    input wire[`RegAddrBus] waddr_i,
    input wire[`RegBus] alu_i,
    input wire[`RegBus] rdata2_i,
    
    //output to mem_wb
    output reg[`OpcodeBus] opcode_o,
    output reg[`OptBus] opt_o,
    output reg we_o,
    output reg[`RegAddrBus] waddr_o,
    output reg[`RegBus] wdata_o,

    //input from memctrl
    input wire[`ByteBus] data_from_memctrl,

    //output to memctrl
    output reg[1: 0] rw_to_memctrl,
    output reg[`DataAddrBus] addr_to_memctrl,
    output reg[`ByteBus] data_to_memctrl, 

    //output to stallctrl
    output reg stallreq_from_mem
    );

    reg[2: 0] mem_state;

    always @ (*) begin
        if (rst == `Enable) begin
            opcode_o = `OpcodeNOP;
            opt_o = `OptNOP;
            we_o = `Disable;
            waddr_o = `NOPRegAddr;
            wdata_o = `ZeroWord;
            rw_to_memctrl = 2'b00;
            addr_to_memctrl = `ZeroWord;
            data_to_memctrl = `ZeroByte;
            stallreq_from_mem = 1'b0;   
            mem_state = 3'b000;
        end else begin
            if(opcode_i == `OpcodeStore || opcode_i == `OpcodeLoad) begin
                opcode_o = `OpcodeNOP;
                opt_o = `OptNOP;
                we_o = `Disable;
                rw_to_memctrl = 2'b00; 
                stallreq_from_mem = 1'b1;
                mem_state = 3'b000;
            end else begin
                opcode_o = opt_i;
                opt_o = opt_i;
                we_o = we_i;
                waddr_o = waddr_i;
                wdata_o = alu_i;
                rw_to_memctrl = 2'b00;
                stallreq_from_mem = 1'b0;
                mem_state = 3'b000;
            end
        end   
    end

    always @ (posedge clk) begin
        if (rst == `Enable) begin
            opcode_o = `OpcodeNOP;
            opt_o = `OptNOP;
            we_o = `Disable;
            waddr_o = `NOPRegAddr;
            wdata_o = `ZeroWord;
            rw_to_memctrl = 2'b00;
            addr_to_memctrl = `ZeroWord;
            data_to_memctrl = `ZeroByte;
            stallreq_from_mem = 1'b0;   
            mem_state = 3'b000;
        end else begin
            if (opcode_i == `OpcodeStore) begin
                case(opt_i)
                    `OptSB:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0];
                                mem_state = 3'b001;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b00;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                rw_to_memctrl = 2'b00;
                                stallreq_from_mem = 1'b0;    
                                mem_state = 3'b000;
                            end 
                        end
                    `OptSH:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0]; 
                                mem_state = 3'b001;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i + 32'b1;
                                data_to_memctrl = rdata2_i[15: 8];    
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                rw_to_memctrl = 2'b00;
                                mem_state = 3'b011;
                            end else if (mem_state == 3'b011) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                rw_to_memctrl = 2'b00;
                                stallreq_from_mem = 1'b0;    
                                mem_state = 3'b000;
                            end
                        end
                    `OptSW:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0]; 
                                mem_state = 3'b001;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i + 32'b1;
                                data_to_memctrl = rdata2_i[15: 8];    
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i + 32'b10;
                                data_to_memctrl = rdata2_i[23: 16];
                                mem_state = 3'b011;
                            end else if (mem_state == 3'b011) begin
                                rw_to_memctrl = 2'b10;
                                addr_to_memctrl = alu_i + 32'b11;
                                data_to_memctrl = rdata2_i[31: 24];    
                                mem_state = 3'b100;
                            end else if (mem_state == 3'b100) begin
                                rw_to_memctrl = 2'b00;
                                mem_state = 3'b101;
                            end else if (mem_state == 3'b101) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                rw_to_memctrl = 2'b00;
                                stallreq_from_mem = 1'b0;
                                mem_state = 3'b000;
                            end
                        end
                endcase       
            end else if (opcode_i == `OpcodeLoad) begin
                case(opt_i)
                    `OptLB:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i;
                                mem_state = 3'b001;
                                wdata_o = `ZeroWord;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b00;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                waddr_o = waddr_i;
                                rw_to_memctrl = 2'b00;
                                wdata_o = {{24{data_from_memctrl[7]}}, data_from_memctrl[7: 0]};
                                stallreq_from_mem = 1'b0;
                                mem_state = 3'b000;
                            end 
                        end
                    `OptLBU:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i;
                                mem_state = 3'b001;
                                wdata_o = `ZeroWord;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b00;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                waddr_o = waddr_i;
                                rw_to_memctrl = 2'b00;
                                wdata_o = {{24{1'b0}}, data_from_memctrl[7: 0]};
                                stallreq_from_mem = 1'b0;
                                mem_state = 3'b000;
                            end
                        end

                    `OptLH:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i;
                                mem_state = 3'b001;
                                wdata_o = `ZeroWord;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b1;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b10;
                                wdata_o = {{24{1'b0}}, data_from_memctrl};
                                mem_state = 3'b011;
                            end else if (mem_state == 3'b011) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                waddr_o = waddr_i;
                                we_o = we_i;
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b11;
                                wdata_o = {{16{data_from_memctrl[7]}}, data_from_memctrl, wdata_o[7:0]};
                                stallreq_from_mem = 1'b0;
                                mem_state = 3'b000;
                            end 
                        end

                    `OptLHU:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i;
                                mem_state = 3'b001;
                                wdata_o = `ZeroWord;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b1;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b10;
                                wdata_o = {{24{1'b0}}, data_from_memctrl};
                                mem_state = 3'b011;
                            end else if (mem_state == 3'b011) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                waddr_o = waddr_i;
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b11;
                                wdata_o = {{16{1'b0}}, data_from_memctrl, wdata_o[7:0]};
                                stallreq_from_mem = 1'b0;
                                mem_state = 3'b000;
                            end 
                        end

                    `OptLW:
                        begin
                            if (mem_state == 3'b000) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i;
                                mem_state = 3'b001;
                                wdata_o = `ZeroWord;
                            end else if (mem_state == 3'b001) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b1;
                                mem_state = 3'b010;
                            end else if (mem_state == 3'b010) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b10;
                                wdata_o = {{24{1'b0}}, data_from_memctrl};
                                mem_state = 3'b011;
                            end else if (mem_state == 3'b011) begin
                                rw_to_memctrl = 2'b01;
                                addr_to_memctrl = alu_i + 32'b11;
                                wdata_o = {{16{1'b0}}, data_from_memctrl, wdata_o[7:0]};
                                mem_state = 3'b100;
                            end else if (mem_state == 3'b100) begin
                                rw_to_memctrl = 2'b00;
                                wdata_o = {{8{1'b0}}, data_from_memctrl, wdata_o[15:0]};
                                mem_state = 3'b101;
                            end else if (mem_state == 3'b101) begin
                                opcode_o = opcode_i;
                                opt_o = opt_i;
                                we_o = we_i;
                                waddr_o = waddr_i;
                                rw_to_memctrl = 2'b00;
                                wdata_o = {data_from_memctrl, wdata_o[23:0]};
                                mem_state = 3'b000;
                                stallreq_from_mem = 1'b0;
                            end
                        end
                endcase
            end else begin
                opcode_o = `OpcodeNOP;
                opt_o = `OptNOP;
                we_o = 1'b0;
                rw_to_memctrl = 2'b00;
                stallreq_from_mem = 1'b0;
            end 
        end
   end
   
endmodule
