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
    input wire rdy,
    
    //input from ex_mem
    input wire[`OpcodeBus] opcode_i,
    input wire[`OptBus] opt_i,
    input wire we_i,
    input wire[`RegAddrBus] waddr_i,
    input wire[`RegBus] alu_i,
    input wire[`RegBus] rdata2_i,
    
    //output to mem_wb
    output reg[`OpcodeBus] opcode_o,
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

    reg mem_done;
    reg[`RegBus] mem_data;
    reg[2: 0] mem_state;
    

    always @ (*) begin
        if (rst == `Enable) begin
            opcode_o = `OpcodeNOP;
            we_o = `Disable;
            waddr_o = `NOPRegAddr;
            wdata_o = `ZeroWord;    
            stallreq_from_mem = 1'b0;
        end else begin
            if (opcode_i == `OpcodeLoad || opcode_i == `OpcodeStore) begin
                if (mem_done == 1'b1) begin
                    opcode_o = opcode_i;
                    we_o = we_i;
                    waddr_o = waddr_i;
                    wdata_o = mem_data;
                    stallreq_from_mem = 1'b0;   
                end else begin
                    opcode_o = `OpcodeNOP;
                    we_o = `Disable;
                    waddr_o = `NOPRegAddr;
                    wdata_o = `ZeroWord;
                    stallreq_from_mem = 1'b1;  
                end
            end else begin
                opcode_o = opcode_i;
                we_o = we_i;
                waddr_o = waddr_i;
                wdata_o = alu_i;
                stallreq_from_mem = 1'b0;   
            end
        end
    end

    always @ (posedge clk) begin
        if (rst == `Enable) begin
            rw_to_memctrl <= 2'b00;
            addr_to_memctrl <= `ZeroWord;
            data_to_memctrl <= `ZeroByte;
            mem_done <= 1'b0;
            mem_data <= `ZeroWord;
            mem_state <= 3'b000;
        end else begin
            if (stallreq_from_mem == 1'b1) begin
                if (opcode_i == `OpcodeStore) begin
                    case(opt_i)
                        `OptSB:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i;
                                    data_to_memctrl <= rdata2_i[7: 0];
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b10;
                                    //addr_to_memctrl <= alu_i;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b000;
                                end 
                            end
                        `OptSH:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i;
                                    data_to_memctrl <= rdata2_i[7: 0]; 
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i + 32'b1;
                                    data_to_memctrl <= rdata2_i[15: 8];    
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    //rw_to_memctrl <= 2'b10;
                                    //addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b011;
                                end else if (mem_state == 3'b011) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b000;
                                end
                            end
                        `OptSW:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i;
                                    data_to_memctrl <= rdata2_i[7: 0]; 
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i + 32'b1;
                                    data_to_memctrl <= rdata2_i[15: 8];    
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    //rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i + 32'b10;
                                    data_to_memctrl <= rdata2_i[23: 16];
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b011;
                                end else if (mem_state == 3'b011) begin
                                    //rw_to_memctrl <= 2'b10;
                                    addr_to_memctrl <= alu_i + 32'b11;
                                    data_to_memctrl <= rdata2_i[31: 24];    
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b100;
                                end else if (mem_state == 3'b100) begin
                                    //rw_to_memctrl <= 2'b10;
                                    //addr_to_memctrl <= alu_i + 32'b11;
                                    //rw_to_memctrl <= 2'b00;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b101;
                                end else if (mem_state == 3'b101) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b000;
                                end
                            end
                    endcase       
                end else if (opcode_i == `OpcodeLoad) begin
                    case(opt_i)
                        `OptLB:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i;
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b01;
                                    //addr_to_memctrl <= alu_i;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    mem_data <= {{24{data_from_memctrl[7]}}, data_from_memctrl[7: 0]};
                                    mem_state <= 3'b000;
                                end 
                            end
                        `OptLBU:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i;
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b01;
                                    //addr_to_memctrl <= alu_i;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    mem_data <= {{24{1'b0}}, data_from_memctrl[7: 0]};
                                    mem_state <= 3'b000;
                                end
                            end

                        `OptLH:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i;
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    //rw_to_memctrl <= 2'b01;
                                    //addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    mem_data <= {{24{1'b0}}, data_from_memctrl};
                                    mem_state <= 3'b011;
                                end else if (mem_state == 3'b011) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    mem_data <= {{16{data_from_memctrl[7]}}, data_from_memctrl, mem_data[7:0]};
                                    mem_state <= 3'b000;
                                end 
                            end

                        `OptLHU:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i;
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    //rw_to_memctrl <= 2'b01;
                                    //addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    mem_data <= {{24{1'b0}}, data_from_memctrl};
                                    mem_state <= 3'b011;
                                end else if (mem_state == 3'b011) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    mem_data <= {{16{1'b0}}, data_from_memctrl, mem_data[7:0]};
                                    mem_state <= 3'b000;
                                end 
                            end

                        `OptLW:
                            begin
                                if (mem_state == 3'b000) begin
                                    rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i;
                                    mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b001;
                                end else if (mem_state == 3'b001) begin
                                    //rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i + 32'b1;
                                    //mem_done <= 1'b0;
                                    //mem_data <= `ZeroWord;
                                    mem_state <= 3'b010;
                                end else if (mem_state == 3'b010) begin
                                    //rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i + 32'b10;
                                    //mem_done <= 1'b0;
                                    mem_data <= {{24{1'b0}}, data_from_memctrl};
                                    mem_state <= 3'b011;
                                end else if (mem_state == 3'b011) begin
                                    //rw_to_memctrl <= 2'b01;
                                    addr_to_memctrl <= alu_i + 32'b11;
                                    //mem_done <= 1'b0;
                                    mem_data <= {{16{1'b0}}, data_from_memctrl, mem_data[7:0]};
                                    mem_state <= 3'b100;
                                end else if (mem_state == 3'b100) begin
                                    //rw_to_memctrl <= 2'b01;
                                    //addr_to_memctrl <= alu_i + 32'b11;
                                    //mem_done <= 1'b0;
                                    mem_data <= {{8{1'b0}}, data_from_memctrl, mem_data[15:0]};
                                    mem_state <= 3'b101;
                                end else if (mem_state == 3'b101) begin
                                    rw_to_memctrl <= 2'b00;
                                    mem_done <= 1'b1;
                                    mem_data <= {data_from_memctrl, mem_data[23:0]};
                                    mem_state <= 3'b000;
                                end
                            end
                    endcase
                end else begin
                    mem_done <= 1'b0;
                    mem_data <= `ZeroWord;
                    mem_state <= 4'b0000;
                end 
            end else begin
                mem_done <= 1'b0;
                mem_data <= `ZeroWord;
                mem_state <= 4'b0000;
            end
        end
   end
   
endmodule
