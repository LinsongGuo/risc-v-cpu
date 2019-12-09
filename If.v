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
	input wire[`InstAddrBus] jump_addr_from_ex,

	//input from memctrl
	input wire[`ByteBus] data_from_memctrl,

	//output to memctrl
	output reg[`InstAddrBus] addr_to_memctrl,

	//intput from stallctrl
	input wire[`StallBus] stall,

	//output to if_id  
	output reg[`InstAddrBus] pc_o,
	output reg flag_o,
	output reg[`InstBus] inst_o
    );
	
	reg[`InstAddrBus] pc;
	reg[`InstBus] inst;
	reg[3: 0] if_state;
	
	always @ (posedge clk) begin
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
				if (stall[0]) begin
					addr_to_memctrl <= jump_addr_from_ex;
					read_o = 1'b1;
					read_addr_o <= jump_addr_from_ex[16: 0];
					flag_o <= 1'b0;
					pc <= jump_addr_from_ex;
					inst <= `ZeroWord;
					if_state <= 4'b0001;	
				end else begin
					flag_o <= 1'b0;
					pc <= jump_addr_from_ex;
					inst <= `ZeroWord;
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
								pc <= pc;
								inst <= `ZeroWord;
								if_state <= 4'b0001;	
							end else begin
								pc <= pc;
								inst <= `ZeroWord;
								if_state <= 4'b0000;
							end
						end 
					4'b0001:
						begin
							if (!stall[0]) begin
								if (read_hit_i == 1'b1) begin
									addr_to_memctrl <= pc + 32'b100; 
									read_o = 1'b1;
									read_addr_o <= pc[16: 0] + 17'b100;
									flag_o <= 1'b1;
									pc_o <= pc;
									inst_o <= read_inst_i;
									pc <= pc + 32'b100;
									inst <= `ZeroWord;
									if_state <= 4'b0001;	
								end else begin
									addr_to_memctrl <= pc + 32'b1;
									flag_o <= 1'b0;
									pc <= pc;
									inst <= `ZeroWord;
									if_state <= 4'b0010;
								end
							end else begin
								if (read_hit_i == 1'b1) begin
									pc <= pc;
									inst <= read_inst_i;
									if_state <= 4'b1101;	
								end begin
									pc <= pc;
									inst <= `ZeroWord;
									if_state <= 4'b1001;
								end
							end
						end

					4'b1001:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b1;
								flag_o <= 1'b0;
								pc <= pc;
								inst <= `ZeroWord;
								if_state <= 4'b0010;
							end else begin
								pc <= pc;
								inst <= `ZeroWord;
								if_state <= 4'b1001;
							end
						end
								
					4'b0010:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b10;
								pc <= pc;
								inst <= {{24{1'b0}}, data_from_memctrl};
								if_state <= 4'b0011;	
							end else begin
								pc <= pc;
								inst <= {{24{1'b0}}, data_from_memctrl};
								if_state <= 4'b1010;
							end
						end
								
					4'b1010:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b10;
								pc <= pc;
								inst <= inst;
								if_state <= 4'b0011;
							end	else begin
								pc <= pc;
								inst <= inst;
								if_state <= 4'b1010;
							end
						end

					4'b0011:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b11;
								pc <= pc;
								inst <= {{16{1'b0}}, data_from_memctrl, inst[7: 0]};
								if_state = 4'b0100;
							end else begin
								pc <= pc;
								inst <= {{16{1'b0}}, data_from_memctrl, inst[7: 0]};
								if_state <= 4'b1011;
							end
						end

					4'b1011:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b11;
								pc <= pc;
								inst <= inst;
								if_state <= 4'b0100;
							end else begin
								pc <= pc;
								inst <= inst;
								if_state <= 4'b1011;
							end
						end
							
					4'b0100:
						begin
							if (!stall[0]) begin
								pc <= pc;
								inst <= {{8{1'b0}}, data_from_memctrl, inst[15: 0]};
								if_state <= 4'b0101;
							end else begin
								pc <= pc;
								inst <= {{8{1'b0}}, data_from_memctrl, inst[15: 0]};
								if_state <= 4'b1100;
							end
						end
							
					4'b1100: 
						begin
							if (!stall[0]) begin
								pc <= pc;
								inst <= inst;
								if_state <= 4'b0101;
							end else begin
								pc <= pc;
								inst <= inst;
								if_state <= 4'b1100;
							end
						end
							
					4'b0101:
						begin
							if (!stall[0]) begin
								write_o <= 1'b1;
								write_addr_o <= pc[16: 0];
								write_inst_o <= {data_from_memctrl, inst[23: 0]};
								flag_o <= 1'b1;
								pc_o <= pc;
								inst_o <= {data_from_memctrl, inst[23: 0]};
								pc <= pc + 32'b100;
								inst <= {data_from_memctrl, inst[23: 0]};
								if_state <= 4'b0000;
							end else begin
								write_o <= 1'b1;
								write_addr_o <= pc[16: 0];
								write_inst_o <= {data_from_memctrl, inst[23: 0]};
								pc <= pc;
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
								pc <= pc + 32'b100;
								inst <= inst;
								if_state <= 4'b0000;
							end else begin
								pc <= pc;
								inst <= inst;
								if_state <= 4'b1101;
							end
						end
				endcase
			end
		end
	end
	
endmodule