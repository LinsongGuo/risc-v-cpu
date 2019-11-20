`timescale 1ns / 1ps
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
	input wire r_from_if, 
	input wire flag_from_if,
	input wire[`InstAddrBus] addr_from_if,

	//output to if
	output reg r_to_if,
	output reg[`ByteBus] data_to_if,

	//input from mem
	input wire flag_from_mem,
	input wire[1: 0] rw_from_mem, //01:load, 10:store
	input wire[`DataAddrBus] addr_from_mem,
	input wire[`ByteBus] data_from_mem,

	//output to mem
	output reg r_to_mem,
	output reg[`ByteBus] data_to_mem,

	//input from ram
	input wire[`ByteBus] data_from_ram,

	//output to ram
	output reg rw_to_ram, //read:1 write:0
	output reg[`DataAddrBus] addr_to_ram,
	output reg[`ByteBus] data_to_ram
    );

	initial begin
		r_to_if = 1'b0;
		data_to_if = `ZeroByte;
		r_to_mem = 1'b0;
		data_to_mem = `ZeroByte;
		rw_to_ram = 1'b0;
		addr_to_ram = `ZeroWord;
		data_to_ram = `ZeroByte;
	end

	always @ (*) begin
		if (rst == `Enable) begin
			r_to_if = 1'b0;
			data_to_if = `ZeroByte;
			r_to_mem = 1'b0;
			data_to_mem = `ZeroByte;
			rw_to_ram = 1'b0;
			addr_to_ram = `ZeroWord;
			data_to_ram = `ZeroByte;
		end else begin

			if (flag_from_mem == 1'b1) begin
				r_to_if = 1'b0;
				r_to_mem = 1'b1;
				data_to_mem = data_from_ram;
			end else if (flag_from_if == 1'b1) begin				
				r_to_if = 1'b1;
				r_to_mem = 1'b0;
				data_to_if = data_from_ram;
			end else begin
				r_to_if = 1'b0;
				r_to_mem = 1'b0;
				data_to_if = `ZeroWord;
			end

			if (rw_from_mem == 2'b01) begin //load
				rw_to_ram = 1'b0;
				addr_to_ram = addr_from_mem;
				data_to_ram = `ZeroByte;	
			end else if (rw_from_mem == 2'b10) begin //store
				rw_to_ram = 1'b1;
				addr_to_ram = addr_from_mem;
				data_to_ram = data_from_mem;					
			end else if (r_from_if == 1'b1) begin //if
				rw_to_ram = 1'b0;
				addr_to_ram = addr_from_if;
				data_to_ram = `ZeroByte;
			end else begin //do nothing
				rw_to_ram = 1'b0;
				addr_to_ram = `ZeroWord;
				data_to_ram = `ZeroByte;
			end 

		end
	end
endmodule

