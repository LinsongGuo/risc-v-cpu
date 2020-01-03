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
	input wire rdy,
	
	//input from icache
	input wire read_hit_i,
	input wire[`InstBus] read_inst_i,

	//output to icache
	output reg read_o,
	output reg[31: 0] read_addr_o,
	output reg write_o,
	output reg[31: 0] write_addr_o,
	output reg[`InstBus] write_inst_o,

	//input from BTB
	input wire res_from_BTB,
	input wire[31: 0] addr_from_BTB,

	//output to BTB
	output reg read_to_BTB,
	output reg[31: 0] addr_to_BTB, 

	//input from ex(branches)
	input wire goback_from_ex,
	input wire[`InstAddrBus] goback_addr_from_ex,

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
	
	initial begin
		pc <= `ZeroWord;
		inst <= `ZeroWord;
		if_state <= 4'b0000;
	end

	always @ (posedge clk) begin
		if (rst == `Enable) begin
			addr_to_memctrl <= `ZeroWord;
			flag_o <= 1'b0;
			pc_o <= `ZeroWord;
			inst_o <= `ZeroWord;
			write_o <= 1'b0;
			read_o <= 1'b0;
			read_to_BTB <= 1'b0;
			addr_to_BTB <= 1'b0;
			//pc <= `ZeroWord;
			//inst <= `ZeroWord;
			//if_state <= 4'b0000;
		end else begin
			if (goback_from_ex == 1'b1) begin
				write_o <= 1'b0;
				read_to_BTB <= 1'b0;
				flag_o <= 1'b0;
				if (!stall[0]) begin
					addr_to_memctrl <= goback_addr_from_ex;
					read_o <= 1'b1;
					read_addr_o <= goback_addr_from_ex;
					pc <= goback_addr_from_ex;
					//inst <= `ZeroWord;
					if_state <= 4'b0001;	
				end else begin
					read_o <= 1'b0;
					pc <= goback_addr_from_ex;
					//inst <= `ZeroWord;
					if_state <= 4'b0000;
				end
			end else begin
				case (if_state)
					4'b0000:
						begin
							write_o <= 1'b0;
							if (!stall[0]) begin
								addr_to_memctrl <= pc;
								read_o <= 1'b1;
								read_addr_o <= pc;
								read_to_BTB <= 1'b0;
								flag_o <= 1'b0;
								if_state <= 4'b0001;	
							end else begin
								read_o <= 1'b0;
							end
						end 
					4'b0001:
						begin
							write_o <= 1'b0;
							if (!stall[0]) begin
								if (res_from_BTB == 1'b1) begin
									read_to_BTB <= 1'b0;
									addr_to_memctrl <= addr_from_BTB;
									read_o <= 1'b1;
									read_addr_o <= addr_from_BTB;
									flag_o <= 1'b0;
									pc <= addr_from_BTB;
									//if_state = 4'b0001;
								end else begin
									if (read_hit_i == 1'b1) begin
										addr_to_memctrl <= pc + 32'b100; 
										read_o <= 1'b1;
										read_addr_o <= pc + 32'b100;
										read_to_BTB <= 1'b1;
										addr_to_BTB <= pc;
										flag_o <= 1'b1;
										pc_o <= pc;
										inst_o <= read_inst_i;
										pc <= pc + 32'b100;
										//inst <= `ZeroWord;
										//if_state <= 4'b0001;	
									end else begin
										addr_to_memctrl <= pc + 32'b1;
										read_o <= 1'b0;
										read_to_BTB <= 1'b0;
										flag_o <= 1'b0;
										if_state <= 4'b0010;
									end
								end
							end else begin
								read_o <= 1'b0;	
								//read_to_BTB <= 1'b0;
								if (res_from_BTB == 1'b1) begin
									pc <= addr_from_BTB;
									if_state = 4'b0000;
								end else begin
									if (read_hit_i == 1'b1) begin
										inst <= read_inst_i;
										if_state <= 4'b1101;	
									end else begin
										if_state <= 4'b1001;
									end
								end
							end
					    end

					4'b1001:
						begin
							if (!stall[0]) begin
								read_to_BTB <= 1'b0;
								addr_to_memctrl <= pc + 32'b1;
								flag_o <= 1'b0;
								if_state <= 4'b0010;
							end else begin
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
					/*

					4'b0001:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b1;
								if_state <= 4'b0010;
							end else begin
								if_state <= 4'b1001;
							end
						end

					4'b1001:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b1;
								if_state <= 4'b0010;
							end
						end
															
					4'b0010:
						begin
							if (!stall[0]) begin
								if (read_hit_i == 1'b1) begin
									flag_o <= 1'b1;
									pc_o <= pc;
									inst_o <= read_inst_i;
									pc <= pc + 32'b100;
									if_state <= 4'b0000;	
								end else begin
									addr_to_memctrl <= pc + 32'b10;
									inst <= {{24{1'b0}}, data_from_memctrl};
									if_state <= 4'b0011;	
								end
							end else begin
								if (read_hit_i == 1'b1) begin
									inst <= read_inst_i;
									if_state <= 4'b1101;	
								end else begin
									inst <= {{24{1'b0}}, data_from_memctrl};
									if_state <= 4'b1010;	
								end
							end
						end
								
					4'b1010:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b10;
								if_state <= 4'b0011;
							end
						end
					*/
					4'b0011:
						begin
							if (!stall[0]) begin
								addr_to_memctrl <= pc + 32'b11;
								inst <= {{16{1'b0}}, data_from_memctrl, inst[7: 0]};
								if_state <= 4'b0100;
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
								//addr_to_memctrl <= pc + 32'b11;
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
								addr_to_memctrl <= pc + 32'b11;
								if_state <= 4'b0101;
							end
						end
							
					4'b0101:
						begin
							if (!stall[0]) begin
								write_o <= 1'b1;
								write_addr_o <= pc;
								write_inst_o <= {data_from_memctrl, inst[23: 0]};
								flag_o <= 1'b1;
								pc_o <= pc;
								inst_o <= {data_from_memctrl, inst[23: 0]};
								
								/*pc <= pc + 32'b100;
								//inst <= {data_from_memctrl, inst[23: 0]};
								if_state <= 4'b0000;
								*/
								addr_to_memctrl <= pc + 32'b100; 
								read_o <= 1'b1;
								read_addr_o <= pc + 32'b100;
								read_to_BTB <= 1'b1;
								addr_to_BTB <= pc;
								pc <= pc + 32'b100;
								if_state <= 4'b0001;	
							end else begin
								write_o <= 1'b1;
								write_addr_o <= pc;
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
								/*
								pc <= pc + 32'b100;
								if_state <= 4'b0000;
								
								*/
								write_o <= 1'b0;
								addr_to_memctrl <= pc + 32'b100; 
								read_o <= 1'b1;
								read_addr_o <= pc + 32'b100;
								read_to_BTB <= 1'b1;
								addr_to_BTB <= pc;		
								pc <= pc + 32'b100;
								if_state <= 4'b0001;
							end
						end
				endcase
			end
		end
	end
	
endmodule