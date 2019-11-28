//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 09:34:35
// Design Name: 
// Module Name: memctrl
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

module memctrl(
	input wire rst,

	//input from if
	input wire[`InstAddrBus] addr_from_if,

	//output to if
	output reg[`ByteBus] data_to_if,

	//input from mem
	input wire[1: 0] rw_from_mem, //01:load, 10:store
	input wire[`DataAddrBus] addr_from_mem,
	input wire[`ByteBus] data_from_mem,

	//output to mem
	output reg[`ByteBus] data_to_mem,

	//input from ram
	input wire[`ByteBus] data_from_ram,

	//output to ram
	output reg rw_to_ram, //read:0 write:1
	output reg[`DataAddrBus] addr_to_ram,
	output reg[`ByteBus] data_to_ram
    );

	always @ (*) begin
		if (rst == `Enable) begin
			rw_to_ram = 1'b0;
			addr_to_ram = `ZeroWord;
			data_to_ram = `ZeroByte;
		end else begin
			if (rw_from_mem == 2'b01) begin //load
				rw_to_ram = 1'b0;
				addr_to_ram = addr_from_mem;
				data_to_ram = `ZeroByte;	
			end else if (rw_from_mem == 2'b10) begin //store
				rw_to_ram = 1'b1;
				addr_to_ram = addr_from_mem;
				data_to_ram = data_from_mem;					
			end else begin //if
				rw_to_ram = 1'b0;
				addr_to_ram = addr_from_if;
				data_to_ram = `ZeroByte;
			end 			
		end
	end

	always @ (*) begin
		if (rst == `Enable) begin
			data_to_if = `ZeroByte;
			data_to_mem = `ZeroByte;
		end else begin	
			data_to_if = data_from_ram;
			data_to_mem = data_from_ram;
		end
	end

endmodule

