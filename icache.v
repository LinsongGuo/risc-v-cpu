//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/27 21:56:13
// Design Name: 
// Module Name: icache
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


module icache(
	input wire clk,
	input wire rst,
	input wire rdy,

	//input from if
	input wire read_i, 
	input wire[31: 0] read_addr_i,
	input wire write_i,
	input wire[31: 0] write_addr_i,
	input wire[`InstBus] write_inst_i,
	
	//output to if
	output reg read_hit_o,//hit:1 miss:0
	output reg[`InstBus] read_inst_o
    );
	

	(* ram_style = "registers" *) reg cache_valid[255: 0];
	(* ram_style = "registers" *) reg[7: 0] cache_tag[255: 0];
	(* ram_style = "registers" *) reg[31: 0] cache_data[255: 0];

	wire[7: 0] read_index_i;
	wire[7: 0] read_tag_i;
	wire[7: 0] write_index_i;
	wire[7: 0] write_tag_i;
	wire valid;
	wire[7: 0] tag;
	wire[31: 0] data;

	assign read_index_i = read_addr_i[9: 2];
	assign read_tag_i = read_addr_i[17: 10];
	assign write_index_i = write_addr_i[9: 2];
	assign write_tag_i = write_addr_i[17: 10];
		
	assign valid = cache_valid[read_index_i];
	assign tag = cache_tag[read_index_i];
	assign data = cache_data[read_index_i]; 
	
	integer i;
	initial begin
		for(i = 0; i < 64; i = i + 1) begin
			cache_valid[i] = 1'b0;
			cache_tag[i] = 8'b0;
			cache_data[i] = 32'b0;
		end
	end
	
	always @ (posedge clk) begin
		if (rst == `Disable && rdy == `Enable && write_i == 1'b1) begin
			cache_valid[write_index_i] <= 1'b1;
			cache_tag[write_index_i] <= write_tag_i;
			cache_data[write_index_i] <= write_inst_i;
		end
	end

	always @ (*) begin
		if (rst == `Enable || rdy == `Disable) begin
			read_hit_o <= 1'b0;
			read_inst_o <= `ZeroWord;
		end else if (read_i == 1'b1) begin
			if (read_tag_i == tag && valid == 1'b1) begin
				read_hit_o <= 1'b1;
				read_inst_o <= data;
			end else begin
				read_hit_o <= 1'b0;
				read_inst_o <= `ZeroWord;
			end
		end else begin
			read_hit_o <= 1'b0;
			read_inst_o <= `ZeroWord;
		end
	end

endmodule
