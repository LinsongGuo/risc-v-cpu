//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 19:14:57
// Design Name: 
// Module Name: if
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

module If(
	input wire clk,
	input wire rst,
	
	//input from icache
	input wire read_hit_i,
	input wire[`InstBus] read_inst_i,

	//output to icache
	output reg read_o,
	output reg[16: 0] read_addr_o,
	output reg write_o,
	output reg[16: 0] write_addr_o,
	output reg[`InstBus] write_inst_o,

	//input from ex(branches)
	input wire branch_from_ex,
	input wire[`InstAddrBus] addr_from_ex,

	//input from memctrl
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,

	//input from predictor
	input wire prediction_from_predictor,

	//output to predictor
	output reg[7: 0] addr_to_predictor,

	//output to if_id  
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[`InstAddrBus] pc;
	reg[`InstBus] inst;
	reg[3: 0] if_state;
	
	always @ (posedge clk) begin
		//$write("%d %04x %08x\n", clk, pc, inst);
		write_o <= 1'b0;
		read_o = 1'b0;
		if (rst == `Enable) begin
			addr_to_memctrl <= `ZeroWord;
			flag_o <= 1'b0;
			pc_o <= `ZeroWord;
			inst_o <= `ZeroWord;
			pc <= `ZeroWord;
			inst <= `ZeroWord;
			if_state <= 4'b0000;
		end else begin
			if (branch_from_ex == 1'b1) begin
				if (!stall[0]) begin
					addr_to_memctrl <= addr_from_ex;
					read_o = 1'b1;
					read_addr_o <= addr_from_ex[16: 0];
					flag_o <= 1'b0;
					pc <= addr_from_ex;
					if_state <= 4'b0001;	
				end else begin
					flag_o <= 1'b0;
					pc <= addr_from_ex;
					if_state <= 4'b0000;
				end
			end else begin
				case (if_state)
					4'b0000:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc;
								read_o = 1'b1;
								read_addr_o <= pc[16: 0];
								flag_o <= 1'b0;
								inst <= `ZeroWord;
								if_state <= 4'b0001;	
							end
						end 
					4'b0001:
						begin
							if (!stall[0]) begin
								if (read_hit_i == 1'b1) begin
									inst <= read_inst_i;
									flag_o <= 1'b1;
									pc_o <= pc;
									inst_o <= read_inst_i;
									if (read_inst_i[6: 0] == 6'b1101111) begin //JAL
										pc <= pc + {{12{read_inst_i[31]}}, read_inst_i[19:12], read_inst_i[20], read_inst_i[30:21], 1'b0};
										if_state <= 4'b0000;	
									end else if (read_inst_i[6: 0] == 6'b1100011) begin //Compare
										addr_to_predictor <= pc;	
										if_state <= 4'b1111;
									end else begin
										addr_to_memctrl <= pc + 32'b100; 
										read_o = 1'b1;
										read_addr_o <= pc[16: 0] + 17'b100;
										pc <= pc + 32'b100;
										if_state <= 4'b0001;	
									end
								end else begin
									addr_to_memctrl <= pc + 32'b1;
									flag_o <= 1'b0;
									if_state <= 4'b0010;
								end
							end else begin
								if (read_hit_i == 1'b1) begin
									inst <= read_inst_i;
									if_state <= 4'b1101;	
								end begin
									if_state <= 4'b1001;
								end
							end
						end

					4'b1001:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b1;
								flag_o <= 1'b0;
								inst <= `ZeroWord;
								if_state <= 4'b0010;
							end else begin
								inst <= `ZeroWord;
								if_state <= 4'b1001;
							end
						end
								
					4'b0010:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b10;
								inst <= {{24{1'b0}}, data_from_memctrl};
								if_state <= 4'b0011;	
							end else begin
								inst <= {{24{1'b0}}, data_from_memctrl};
								if_state <= 4'b1010;
							end
						end
								
					4'b1010:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b10;
								if_state <= 4'b0011;
							end
						end

					4'b0011:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b11;
								inst <= {{16{1'b0}}, data_from_memctrl, inst[7: 0]};
								if_state = 4'b0100;
							end else begin
								inst <= {{16{1'b0}}, data_from_memctrl, inst[7: 0]};
								if_state <= 4'b1011;
							end
						end

					4'b1011:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b11;
								if_state <= 4'b0100;
							end
						end
							
					4'b0100:
						begin
							if (!stall[0]) begin
								inst <= {{8{1'b0}}, data_from_memctrl, inst[15: 0]};
								if_state <= 4'b0101;
							end else begin
								inst <= {{8{1'b0}}, data_from_memctrl, inst[15: 0]};
								if_state <= 4'b1100;
							end
						end
							
					4'b1100: 
						begin
							if (!stall[0]) begin
								if_state <= 4'b0101;
							end else begin
								if_state <= 4'b1100;
							end
						end
							
					4'b0101:
						begin
							if (!stall[0]) begin
								flag_o <= 1'b1;
								pc_o <= pc;
								inst_o <= {data_from_memctrl, inst[23: 0]};
								write_o <= 1'b1;
								write_addr_o <= pc[16: 0];
								write_inst_o <= {data_from_memctrl, inst[23: 0]};
								if (inst[6: 0] == 6'b1101111) begin //JAL
									pc <= pc + {{12{data_from_memctrl[6]}}, inst[19:12], inst[20], data_from_memctrl[6: 0], inst[23: 21], 1'b0};
									if_state <= 4'b0000;	
								end else if (inst[6: 0] == 6'b1100011) begin //Compare
									addr_to_predictor <= pc;	
									inst <= {data_from_memctrl, inst[23: 0]};
									if_state <= 4'b1111;
								end else begin
									pc <= pc + 32'b100;
									if_state <= 4'b0000;
								end
							end else begin
								write_o <= 1'b1;
								write_addr_o <= pc[16: 0];
								write_inst_o <= {data_from_memctrl, inst[23: 0]};
								inst <= {data_from_memctrl, inst[23: 0]};
								if_state <= 4'b1101;
							end
						end
					
					4'b1101:
						begin
							if (!stall[0]) begin
								flag_o <= 1'b1;
								pc_o <= pc;
								inst_o <= inst;
								if (inst[6: 0] == 6'b1101111) begin //JAL
									pc <= pc + {{12{inst[31]}}, inst[19:12], inst[20], inst[30: 21], 1'b0};
									if_state <= 4'b0000;	
								end else if (inst[6: 0] == 6'b1100011) begin //Compare
									addr_to_predictor <= pc;	
									if_state <= 4'b1111;
								end else begin
									pc <= pc + 32'b100;
									if_state <= 4'b0000;
								end
							end
						end

					4'b1111:
						begin
							if (!stall[0]) begin
								if (prediction_from_predictor == 1'b1) begin
									flag_o <= 1'b0;
									pc <= pc + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									if_state <= 4'b0000;	
								end else begin
									flag_o <= 1'b0;
									pc <= pc + 32'b100;
									if_state <= 4'b0000;	
								end
							end
						end
				endcase
			end
		end
	end
	
endmodule