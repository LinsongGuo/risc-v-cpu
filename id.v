//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 12:54:33
// Design Name: 
// Module Name: id
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

module id(
	input wire rst,
	
	//input from if_id
	input wire flag_i,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,
	
	//input from regfile
	input wire[`RegBus] rdata1_i,
	input wire[`RegBus] rdata2_i,
	
	//output to regfile
	output reg re1_o, 
	output reg re2_o,
	output reg[`RegAddrBus] raddr1_o, 
	output reg[`RegAddrBus] raddr2_o,
	
	//output to ex
	output reg[`InstAddrBus] pc_o,
	output reg[`InstBus] inst_o,
	output reg[`OpcodeBus] opcode_o,
	output reg[`OptBus] opt_o,
	output reg[`RegBus] rdata1_o,
	output reg[`RegBus] rdata2_o,
	output reg we_o,
	output reg[`RegAddrBus] waddr_o,
	output reg[`DataBus] imm_o,
	output reg[`ShamtBus] shamt_o
    );
    
	wire[`OpcodeBus] opcode = inst_i[`OpcodeBus];
    wire[2:0] funct3 = inst_i[14: 12];
    wire[6:0] funct7 = inst_i[31: 25];
    
    always @ (*) begin
        if (rst == `Enable) begin
        	re1_o = `Disable;
        	re2_o = `Disable;
        	raddr1_o = `NOPRegAddr;
        	raddr2_o = `NOPRegAddr;
        	pc_o = `ZeroWord;
        	opcode_o = `OpcodeNOP;
        	opt_o = `OptNOP;
        	rdata1_o = `ZeroWord;
        	rdata2_o = `ZeroWord;
        	we_o = `Disable;
        	waddr_o = `NOPRegAddr;
        	imm_o = `ZeroWord;
        	shamt_o = 5'b0;
        	inst_o = `ZeroWord;
        end else if (flag_i == 1'b1) begin
	        raddr1_o = inst_i[19: 15];
	        raddr2_o = inst_i[24: 20];
	        pc_o = pc_i;
	    	opcode_o = opcode;
	        rdata1_o = rdata1_i;
	        rdata2_o = rdata2_i;
	        waddr_o = inst_i[11: 7];
	        imm_o = `ZeroWord;
	        shamt_o = 5'b0;
	        inst_o = inst_i;
	        case(opcode)
	            `OpcodeLUI:
	                begin
	                    opt_o = `OptLUI;
	                    imm_o = {inst_i[31:12], 12'b0};
	                    we_o = `Enable;
	                    re1_o = `Disable;
	                    re2_o = `Disable;
	                end
	            `OpcodeAUIPC:
	                begin
	                    opt_o = `OptAUIPC;
	                    imm_o = {inst_i[31:12], 12'b0};
	                    we_o = `Enable;
	                    re1_o = `Disable;
	                    re2_o = `Disable;
	                end
	            `OpcodeJAL:
	            	begin 
	            		opt_o = `OptJAL;
	            		imm_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
	            		we_o = `Enable;
	            		re1_o = `Disable;
	            		re2_o = `Disable;
	            	end
	            `OpcodeJALR:
	            	begin
	            		opt_o = `OptJALR;
	            		imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
	       				we_o = `Enable;
	       				re1_o = `Enable;
	       				re2_o = `Disable;
	       			end
	       		`OpcodeBranch:
	       			begin
	       				imm_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
	        			we_o = `Disable;
	        			re1_o = `Enable;
	        			re2_o = `Enable;
	       				case(funct3)
					 		3'b000: 
					 			begin 
					 				opt_o = `OptBEQ; 
					 			end
					 		3'b001: 
					 			begin 
					 				opt_o = `OptBNE;
					 			end
					 		3'b100: 
					 			begin 
					 				opt_o = `OptBLT;
					 			end
					 		3'b101:	
					 			begin 
					 				opt_o = `OptBGE; 
					 			end
					 		3'b110: 
					 			begin 
					 				opt_o = `OptBLTU;
					 			end
					 		3'b111: 
					 			begin 
					 				opt_o = `OptBGEU;
					 			end
					 		default: 
					 			begin 
					 				opt_o = `OptNOP; 
					 			end
	        			endcase
	        		end
	        	`OpcodeLoad:
	        		begin
	        			case(funct3)
	        				3'b000: begin opt_o = `OptLB; end
				 			3'b001: begin opt_o = `OptLH; end
				 			3'b010: begin opt_o = `OptLW; end
				 			3'b100: begin opt_o = `OptLBU; end
				 			3'b101: begin opt_o = `OptLHU; end
				 			default: begin opt_o = `OptNOP; end
				 		endcase
				 		imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 		we_o = `Enable;
				 		re1_o = `Enable;
				 		re2_o = `Disable;
	        		end
	        	`OpcodeStore:
	        		begin
	        			case(funct3)
	        				3'b000: begin opt_o = `OptSB; end
				 			3'b001: begin opt_o = `OptSH; end
				 			3'b010: begin opt_o = `OptSW; end
				 			default: begin opt_o = `OptNOP; end
				 		endcase
				 		imm_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
				 		we_o = `Disable;
				 		re1_o = `Enable;
				 		re2_o = `Enable;
				 	end
				 `OpcodeCalcI:
				 	begin
				 		case(funct3)
				 			3'b00: 
				 				begin 
				 					opt_o = `OptADDI; 
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end
				 			3'b010:
				 				begin
				 					opt_o = `OptSLTI;
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end
				 			3'b011:
				 				begin
				 					opt_o = `OptSLTIU;
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end		
				 			3'b100:
				 				begin
				 					opt_o = `OptXORI;
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end
				 			3'b110:
				 				begin
				 					opt_o = `OptORI;
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end
				 			3'b111:
				 				begin
				 					opt_o = `OptANDI;
				 					imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
				 				end
				 			3'b001:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSLLI;
				 						shamt_o = inst_i[24: 20];
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b101:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSRLI;
				 						shamt_o = inst_i[24: 20];
				 					end else if (funct7 == 7'b0100000) begin
				 						opt_o = `OptSRAI;
				 						shamt_o = inst_i[24: 20];
				 					end else begin 
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			default:
				 				begin opt_o = `OptNOP; end
				 		endcase
				 		we_o = `Enable;
				 		re1_o = `Enable;
				 		re2_o = `Disable;
				 	end	
				 `OpcodeCalc:
				 	begin
				 		case(funct3)
				 			3'b000:
				 				begin
				 					 if (funct7 == 7'b0000000) begin
				 					 	opt_o = `OptADD;
				 					 end else if(funct7 == 7'b0100000) begin
				 					 	opt_o = `OptSUB;
				 					 end else begin
				 					 	opt_o = `OptNOP;
				 					 end
				 				end
				 			3'b001:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSLL;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b010:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSLT;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b011:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSLTU;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b100:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptXOR;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b101:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptSRL;
				 					end else if(funct7 == 7'b0100000) begin
				 						opt_o = `OptSRA;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b110:
				 				begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptOR;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			3'b111:
								begin
				 					if (funct7 == 7'b0000000) begin
				 						opt_o = `OptAND;
				 					end else begin
				 						opt_o = `OptNOP;
				 					end
				 				end
				 			default:
				 				begin opt_o = `OptNOP; end
				 		endcase
				 		we_o = `Enable;
				 		re1_o = `Enable;
				 		re2_o = `Enable;
				 	end
				 default:
				 	begin opt_o = `OptNOP; end	
	        endcase
    	end else begin
    		re1_o = `Disable;
        	re2_o = `Disable;
        	raddr1_o = `NOPRegAddr;
        	raddr2_o = `NOPRegAddr;
        	pc_o = `ZeroWord;
        	opcode_o = `OpcodeNOP;
        	opt_o = `OptNOP;
        	rdata1_o = `ZeroWord;
        	rdata2_o = `ZeroWord;
        	we_o = `Disable;
        	waddr_o = `NOPRegAddr;
        	imm_o = `ZeroWord;
        	shamt_o = 5'b0;
        	inst_o = `ZeroWord;
    	end
    end
	
endmodule
