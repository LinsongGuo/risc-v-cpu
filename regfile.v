//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 10:21:47
// Design Name: 
// Module Name: regfile
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

module regfile(
	input wire clk,
	input wire rst,
	input wire rdy,
	
	//input from mem_wb
	input wire wb_we_i,
	input wire [`RegAddrBus] wb_waddr_i,
	input wire [`RegBus] wb_wdata_i,

	//input from mem
	input wire[`OpcodeBus] mem_opcode_i,
	input wire mem_we_i,
	input wire[`RegAddrBus] mem_waddr_i,
	input wire[`RegBus] mem_wdata_i,

	//input from ex
	input wire[`OpcodeBus] ex_opcode_i,
	input wire ex_we_i,
	input wire[`RegAddrBus] ex_waddr_i,
	input wire[`RegBus] ex_alu_i,
	
	//input from id
	input wire re1_i,
	input wire re2_i,
	input wire[`RegAddrBus] raddr1_i,
	input wire[`RegAddrBus] raddr2_i,
	
	//output to id
	output reg[`RegBus] rdata1_o,
	output reg[`RegBus] rdata2_o,
	
	//output to stallctrl
	output reg stallreq_from_id
    );
    
    reg[`RegBus] regs[0: `RegNum - 1];
  
    reg stallreq_from_id_reg1, stallreq_from_id_reg2;

    integer i;
    initial begin
    	for (i = 0; i < 32; i = i + 1) begin
    		regs[i] = `ZeroWord;
    	end
    end

    // write data to register
    always @ (posedge clk) begin
    	if (rst == `Disable && wb_we_i == `Enable && wb_waddr_i != 5'h0) begin
    		regs[wb_waddr_i] <= wb_wdata_i;
    	end
    end
    
    // read from register 1
    always @ (*) begin
    	if (rst == `Enable) begin
    		rdata1_o = `ZeroWord;
    		stallreq_from_id_reg1 = 1'b0;
    	end else begin
    		if (re1_i == `Enable) begin
    			if (raddr1_i == 5'b00000) begin
    				rdata1_o = `ZeroWord;
    				stallreq_from_id_reg1 = 1'b0;
    			end else if (ex_we_i == `Enable && raddr1_i == ex_waddr_i) begin
    				if (ex_opcode_i == `OpcodeLoad) begin
    					rdata1_o = `ZeroWord;
    					stallreq_from_id_reg1 = 1'b1;
    				end else begin
    					rdata1_o = ex_alu_i;
    					stallreq_from_id_reg1 = 1'b0;
    				end
    			end else if (mem_we_i == `Enable && raddr1_i == mem_waddr_i) begin
    				if (mem_opcode_i == `OpcodeLoad) begin
    					rdata1_o = `ZeroWord;
    					stallreq_from_id_reg1 = 1'b1;
    				end else begin
    					rdata1_o = mem_wdata_i;
    					stallreq_from_id_reg1 = 1'b0;
    				end
    			end else if (wb_we_i == `Enable && raddr1_i == wb_waddr_i) begin
    				rdata1_o = wb_wdata_i;
    				stallreq_from_id_reg1 = 1'b0;
    			end else begin
    				rdata1_o = regs[raddr1_i];
    				stallreq_from_id_reg1 = 1'b0;
    			end
    		end else begin
    			rdata1_o = `ZeroWord;
    			stallreq_from_id_reg1 = 1'b0;
    		end
 		end
	end


	always @ (*) begin
    	if (rst == `Enable) begin
			rdata2_o = `ZeroWord;
    		stallreq_from_id_reg2 = 1'b0; 
    	end else begin
    		if (re2_i == `Enable) begin
				if (raddr2_i == 5'b00000) begin
					rdata2_o = `ZeroWord;
    				stallreq_from_id_reg2 = 1'b0;   
				end else if (ex_we_i == `Enable && raddr2_i == ex_waddr_i) begin
					if (ex_opcode_i == `OpcodeLoad) begin
						rdata2_o = `ZeroWord;
						stallreq_from_id_reg2 = 1'b1;
					end else begin
						rdata2_o = ex_alu_i;
						stallreq_from_id_reg2 = 1'b0;
					end
				end else if (mem_we_i == `Enable && raddr2_i == mem_waddr_i) begin
					if (mem_opcode_i == `OpcodeLoad) begin
						rdata2_o = `ZeroWord;
						stallreq_from_id_reg2 = 1'b1;
					end else begin
						rdata2_o = mem_wdata_i;
						stallreq_from_id_reg2 = 1'b0;
					end
				end else if (wb_we_i == `Enable && raddr2_i == wb_waddr_i) begin
					rdata2_o = wb_wdata_i;
					stallreq_from_id_reg2 = 1'b0;
				end else begin
					rdata2_o = regs[raddr2_i];
					stallreq_from_id_reg2 = 1'b0;
				end
			end else begin
				rdata2_o = `ZeroWord;
				stallreq_from_id_reg2 = 1'b0;
			end
		end
	end
	
	always @ (*) begin
		if (rst == `Enable) begin
			stallreq_from_id = 1'b0;
		end else begin
			stallreq_from_id = stallreq_from_id_reg1 | stallreq_from_id_reg2;
		end
	end
endmodule
