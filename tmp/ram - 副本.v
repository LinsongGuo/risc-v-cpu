`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/14 10:18:59
// Design Name: 
// Module Name: ram
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


module ram(
	input wire clk,
	input wire ce,
	input wire we,

	//input from mem
	input wire[`DataAddrBus] mem_addr_i,
	input wire[5: 0] mem_opt_i,
	input wire[`DataBus] mem_data_i,

	//output to mem_wb
	output reg[`DataBus] mem_data_o,

	//input from pc_reg
    input wire[`InstAddrBus] pcreg_addr_i,
    
    //output to if_id
    output reg[`InstBus] if_inst_o
    );
	
	reg[`ByteBus] ram_data[0: `RamSize - 1];
	initial $readmemh ("D:/courses/CA/cpu1/data.txt", ram_data);


	always @ (posedge clk) begin
		if (ce == `Enable && we == `Enable) begin
			if (mem_opt_i == `OptSW) begin
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]] <= mem_data_i[31: 24];
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 1] <= mem_data_i[23: 16];
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 2] <= mem_data_i[15: 8];
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 3] <= mem_data_i[7: 0];
			end else if (mem_opt_i == `OptSH) begin
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]] <= mem_data_i[15: 8];
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 1] <= mem_data_i[7: 0];	
			end else if (mem_opt_i == `OptSB) begin
				ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]] <= mem_data_i[7: 0];
			end
		end
	end

	always @ (posedge clk) begin
		if (ce == `Disable) begin
			mem_data_o <= `ZeroWord;
		end else if (we == `Enable) begin
			case(mem_opt_i)
				`OptLW:
					begin
						mem_data_o <= {ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]], 
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 1], 
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 2], 
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 3]};
					end
				`OptLH:
					begin
						mem_data_o <= {{16{ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]][7]}},
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]], 
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 1]};
					end
				`OptLHU:
					begin
						mem_data_o <= {{16{1'b0}},
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]], 
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0] + 1]};		
					end
				`OptLB:
					begin
						mem_data_o <= {{24{ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]][7]}},
										ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]]};
					end
				`OptLBU:
					begin
						mem_data_o <= {{24{1'b0}}, ram_data[mem_addr_i[`RamSizeLog2 - 1: 0]]};
					end
				default:
					begin
						mem_data_o <= `ZeroWord;
					end
			endcase
		end
	end

	always @ (posedge clk) begin
        if (ce == `Disable) begin
            if_inst_o <= `ZeroWord;
        end else begin
            if_inst_o <= {ram_data[pcreg_addr_i[`RamSizeLog2 - 1 : 0] + 3], 
                ram_data[pcreg_addr_i[`RamSizeLog2 - 1 : 0] + 2], 
                ram_data[pcreg_addr_i[`RamSizeLog2 - 1 : 0] + 1], 
                ram_data[pcreg_addr_i[`RamSizeLog2 - 1 : 0]]};
        end
    end

endmodule
