`timescale 1ns / 1ps
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
    input wire cond_i,
    input wire[`RegBus] rdata2_i,
    input wire flag_i,

    //output to mem_wb
    output reg[`OpcodeBus] opcode_o,
    output reg[`OptBus] opt_o,
    output reg we_o,
    output reg[`RegAddrBus] waddr_o,
    output reg[`RegBus] wdata_o,

    //input from memctrl
    input wire r_from_memctrl,
    input wire[`ByteBus] data_from_memctrl,

    //output to memctrl
    output reg flag_to_memctrl,
    output reg[1: 0] rw_to_memctrl,
    output reg[`DataAddrBus] addr_to_memctrl,
    output reg[`ByteBus] data_to_memctrl, 

    //output to stallctrl
    output reg stallreq_from_mem
    );

    reg[2: 0] sent_to_memctrl;
    reg[1: 0] received_from_memctrl;

    always @ (*) begin
        if (rst == `Enable) begin
            opcode_o = `OpcodeNOP;
            opt_o = `OptNOP;
            we_o = `Disable;
            waddr_o = `NOPRegAddr;
            wdata_o = `ZeroWord;
            flag_to_memctrl = 1'b0;
            rw_to_memctrl = 2'b00;
            addr_to_memctrl = `ZeroWord;
            data_to_memctrl = `ZeroByte;
            stallreq_from_mem = 1'b0;   
            sent_to_memctrl = 3'b00;
            received_from_memctrl = 2'b0;
        end else begin
            if(opcode_i == `OpcodeStore || opcode_i == `OpcodeStore) begin
                opcode_o = `OpcodeNOP;
                opt_o = `OptNOP;
                we_o = 1'b0;
                waddr_o = 5'h0;
                wdata_o = `ZeroWord;
                flag_to_memctrl = 1'b0;
                rw_to_memctrl = 2'b00;
                addr_to_memctrl = `ZeroWord;
                data_to_memctrl = `ZeroByte;
                stallreq_from_mem = 1'b1;   
                sent_to_memctrl = 3'b00;
                received_from_memctrl = 2'b0;
            end else begin
                opcode_o = opcode_i;
                opt_o = opt_i;
                we_o = we_i;
                waddr_o = waddr_i;
                wdata_o = alu_i;
                flag_to_memctrl = 1'b0;
                rw_to_memctrl = 2'b00;
                addr_to_memctrl = `ZeroWord;
                data_to_memctrl = `ZeroByte;
                stallreq_from_mem = 1'b0;   
                sent_to_memctrl = 3'b00;
                received_from_memctrl = 2'b0;
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
            flag_to_memctrl = 1'b0;
            rw_to_memctrl = 2'b00;
            addr_to_memctrl = `ZeroWord;
            data_to_memctrl = `ZeroByte;
            stallreq_from_mem = 1'b0;   
            sent_to_memctrl = 3'b00;
            received_from_memctrl = 2'b0;
        end else begin
            opcode_o = opcode_i;
            opt_o = opt_i;
            we_o = we_i;
            waddr_o = waddr_i;
            if (opcode_i == `OpcodeStore) begin
                wdata_o = `ZeroWord;
                flag_to_memctrl = 1'b0;
                rw_to_memctrl = 2'b10;
                case(opt_i)
                    `OptSB:
                        begin
                            if (flag_i == 1'b1) begin
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0];
                                stallreq_from_mem = 1'b0;
                                sent_to_memctrl = 3'b001;   
                            end
                        end
                    `OptSH:
                        begin
                            if (flag_i == 1'b1) begin
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0];
                                stallreq_from_mem = 1'b1;   
                                sent_to_memctrl = 3'b001;    
                            end else if (sent_to_memctrl == 3'b001) begin
                                addr_to_memctrl = alu_i + 32'b1;
                                data_to_memctrl = rdata2_i[15: 8];
                                stallreq_from_mem = 1'b0;   
                                sent_to_memctrl = 3'b010;
                            end
                        end
                    `OptSW:
                        begin
                            if (flag_i == 1'b1) begin
                                addr_to_memctrl = alu_i;
                                data_to_memctrl = rdata2_i[7: 0];
                                stallreq_from_mem = 1'b1;   
                                sent_to_memctrl = 3'b001;
                            end else if (sent_to_memctrl == 3'b001) begin
                                addr_to_memctrl = alu_i + 32'b1;
                                data_to_memctrl = rdata2_i[15: 8];
                                stallreq_from_mem = 1'b1;   
                                sent_to_memctrl = 3'b010; 
                            end else if (sent_to_memctrl == 3'b010) begin
                                addr_to_memctrl = alu_i + 32'b10;
                                data_to_memctrl = rdata2_i[23: 16];
                                stallreq_from_mem = 1'b1;   
                                sent_to_memctrl = 3'b011;            
                            end else begin
                                addr_to_memctrl = alu_i + 32'b11;
                                data_to_memctrl = rdata2_i[31: 24];
                                stallreq_from_mem = 1'b0;   
                                sent_to_memctrl = 3'b100; 
                            end
                        end
                endcase       
            end else if (opcode_i == `OpcodeLoad) begin
                wdata_o = `ZeroWord;
                data_to_memctrl = `ZeroByte;
                case(opt_i)
                    `OptLB:
                        begin
                            if (flag_i == 1'b1) begin
                                rw_to_memctrl = 2'b01;
                                flag_to_memctrl = 1'b0;
                                addr_to_memctrl = alu_i;
                                stallreq_from_mem = 1'b1;
                                sent_to_memctrl = 3'b001;
                                received_from_memctrl = 2'b00;
                                wdata_o = `ZeroWord;
                            end else begin
                                rw_to_memctrl = 2'b00;
                                if (r_from_memctrl == 1'b1) begin
                                    flag_to_memctrl = 1'b0;
                                    wdata_o = {{24{data_from_memctrl[7]}}, data_from_memctrl};
                                    stallreq_from_mem = 1'b0;
                                    received_from_memctrl = 2'b01;
                                end
                            end
                        end
                    `OptLBU:
                        begin
                            if (flag_i == 1'b1) begin
                                rw_to_memctrl = 2'b01;
                                flag_to_memctrl = 1'b0;
                                addr_to_memctrl = alu_i;
                                stallreq_from_mem = 1'b1;
                                sent_to_memctrl = 3'b001;
                                received_from_memctrl = 2'b00;
                                wdata_o = `ZeroWord;
                            end else begin
                                rw_to_memctrl = 2'b00;
                                if (r_from_memctrl == 1'b1) begin
                                    flag_to_memctrl = 1'b0;
                                    wdata_o = {{24{1'b0}}, data_from_memctrl};
                                    stallreq_from_mem = 1'b0;
                                    received_from_memctrl = 2'b01;
                                end  
                            end
                        end
                    `OptLH:
                        begin
                            if (flag_i == 1'b1) begin
                                rw_to_memctrl = 2'b01;
                                flag_to_memctrl = 1'b0;
                                addr_to_memctrl = alu_i;
                                stallreq_from_mem = 1'b1;
                                sent_to_memctrl = 3'b001;
                                received_from_memctrl = 2'b00;
                                wdata_o = `ZeroWord;
                            end else begin
                                if (sent_to_memctrl == 3'b001) begin
                                    rw_to_memctrl = 2'b01;
                                    addr_to_memctrl = alu_i + 32'b1;
                                    stallreq_from_mem = 1'b1;
                                    sent_to_memctrl = 3'b010;
                                end else begin
                                    rw_to_memctrl = 2'b00;
                                end

                                if (r_from_memctrl == 1'b1) begin
                                    if (received_from_memctrl == 2'b00) begin
                                        flag_to_memctrl = 1'b1;
                                        wdata_o = {{24{1'b0}}, data_from_memctrl};
                                        stallreq_from_mem = 1'b1;
                                        received_from_memctrl = 2'b01;          
                                    end else if (received_from_memctrl == 2'b01) begin
                                        flag_to_memctrl = 1'b0;
                                        wdata_o = {{16{1'b0}}, data_from_memctrl, wdata_o[7:0]};
                                        stallreq_from_mem = 1'b0;
                                        received_from_memctrl = 2'b10;
                                    end
                                end 
                            end
                        end
                    `OptLHU:
                       begin
                            if (flag_i == 1'b1) begin
                                rw_to_memctrl = 2'b01;
                                flag_to_memctrl = 1'b0;
                                addr_to_memctrl = alu_i;
                                stallreq_from_mem = 1'b1;
                                sent_to_memctrl = 3'b001;
                                received_from_memctrl = 2'b00;
                                wdata_o = `ZeroWord;
                            end else begin
                                if (sent_to_memctrl == 3'b001) begin
                                    rw_to_memctrl = 2'b01;
                                    addr_to_memctrl = alu_i + 32'b1;
                                    stallreq_from_mem = 1'b1;
                                    sent_to_memctrl = 3'b010;
                                end else begin
                                    rw_to_memctrl = 2'b00;
                                end

                                if (r_from_memctrl == 1'b1) begin
                                    if (received_from_memctrl == 2'b00) begin
                                        flag_to_memctrl = 1'b1;
                                        wdata_o = {{24{1'b0}}, data_from_memctrl};
                                        stallreq_from_mem = 1'b1;
                                        received_from_memctrl = 2'b01;          
                                    end else if (received_from_memctrl == 2'b01) begin
                                        flag_to_memctrl = 1'b0;
                                        wdata_o = {{16{data_from_memctrl[7]}}, data_from_memctrl, wdata_o[7:0]};
                                        stallreq_from_mem = 1'b0;
                                        received_from_memctrl = 2'b10;
                                    end
                                end 
                            end
                        end
                    `OptLW:
                        begin
                            if (flag_i == 1'b1) begin
                                rw_to_memctrl = 2'b01;
                                flag_to_memctrl = 1'b0;
                                addr_to_memctrl = alu_i;
                                stallreq_from_mem = 1'b1;
                                sent_to_memctrl = 3'b001;
                                received_from_memctrl = 2'b00;
                                wdata_o = `ZeroWord;
                            end else begin
                                if (sent_to_memctrl == 3'b001) begin
                                    rw_to_memctrl = 2'b01;
                                    addr_to_memctrl = alu_i + 32'b01;
                                    stallreq_from_mem = 1'b1;
                                    sent_to_memctrl = 3'b010;
                                end else if (sent_to_memctrl == 3'b010)begin
                                    rw_to_memctrl = 2'b01;
                                    addr_to_memctrl = alu_i + 32'b10;
                                    stallreq_from_mem = 1'b1;
                                    sent_to_memctrl = 3'b011;    
                                end else if (sent_to_memctrl == 3'b011)begin
                                    rw_to_memctrl = 2'b01;
                                    addr_to_memctrl = alu_i + 32'b11;
                                    stallreq_from_mem = 1'b1;
                                    sent_to_memctrl = 3'b100;    
                                end else begin
                                    rw_to_memctrl = 2'b00;
                                end

                                if (r_from_memctrl == 1'b1) begin
                                    if (received_from_memctrl == 2'b00) begin
                                        flag_to_memctrl = 1'b1;
                                        wdata_o = {{24{1'b0}}, data_from_memctrl};
                                        stallreq_from_mem = 1'b1;
                                        received_from_memctrl = 2'b01;          
                                    end else if (received_from_memctrl == 2'b01) begin
                                        flag_to_memctrl = 1'b1;
                                        wdata_o = {{16{data_from_memctrl[7]}}, data_from_memctrl, wdata_o[7:0]};
                                        stallreq_from_mem = 1'b1;
                                        received_from_memctrl = 2'b10;
                                    end else if (received_from_memctrl == 2'b10) begin
                                        flag_to_memctrl = 1'b1;
                                        wdata_o = {{8{data_from_memctrl[7]}}, data_from_memctrl, wdata_o[15:0]};
                                        stallreq_from_mem = 1'b1;
                                        received_from_memctrl = 2'b11;        
                                    end else begin
                                        flag_to_memctrl = 1'b0;
                                        wdata_o = {data_from_memctrl, wdata_o[23:0]};
                                        stallreq_from_mem = 1'b0;
                                        received_from_memctrl = 2'b00;            
                                    end
                                end
                            end
                        end
                endcase

            end else  begin
                opcode_o = `OpcodeNOP;
                opt_o = `OptNOP;
                we_o = 1'b0;
                waddr_o = 5'h0;
                wdata_o = `ZeroWord;
                flag_to_memctrl = 1'b0;
                rw_to_memctrl = 2'b00;
                addr_to_memctrl = `ZeroWord;
                data_to_memctrl = `ZeroByte;
                stallreq_from_mem = 1'b0;   
                sent_to_memctrl = 3'b00;
                received_from_memctrl = 2'b0;
            end 
        end
   end
   
endmodule