`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 09:34:35
// Design Name: 
// Module Name: memacc_ctrl
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


module memacc_ctrl(
	input wire clk,
	input wire rst,

	//input from if
	input wire r_from_if, 
	input wire[`InstAddrBus] addr_from_if,

	//output to if
	output wire[`InstBus] inst_to_if,

	//input from mem
	input wire[1: 0] rw_from_mem, //01:load, 1o:store
	input wire[`DataAddrBus] addr_from_mem,
	input wire[`DataBus] data_from_mem,
	input wire[4: 0] bits_from_mem,

	//output to mem
	output wire[`DataBus] data_to_mem,

	//input from ram
	input wire[`ByteBus] data_from_ram,

	//output to ram
	output reg rw_to_ram, //read:1 write:0
	output reg[`DataAddrBus] addr_to_ram,
	output reg[`ByteBus] data_to_ram
    );

	reg[1: 0] state_in_ctrl;//00:free 01:load 10:store 11:if
	reg[`DataAddrBus] addr_in_ctrl;
	reg[`DataBus] data_in_ctrl;
	reg[4: 0] bits_in_ctrl;

	initial begin
		state_in_ctrl = 2'b00;
		addr_in_ctrl = `ZeroWord;
		data_in_ctrl = `ZeroWord;
		bits_in_ctrl <= 5'b00000;
		//initial output to ram
		rw_to_ram = 1'b1;
		addr_to_ram = `ZeroWord;
		data_to_ram = `ZeroByte;
	end

	always @ (posedge clk) begin
		if (rst == `Enable) begin
			inst_to_if <= `ZeroWord;
			data_to_mem <= `ZeroWord;
			state_in_ctrl <= 2'b00;
			addr_in_ctrl <= `ZeroWord;
			data_in_ctrl <= `ZeroWord;
			bits_in_ctrl <= 5'b00000;
		end else begin
			if (state_in_ctrl == 2'b00) begin
				if (rw_from_mem == 2'b01) begin //load
					state_in_ctrl <= 2'b01;
					addr_in_ctrl <= addr_from_mem;
					data_in_ctrl <= `ZeroWord;
					bits_in_ctrl <= bits_from_mem;
					//output to ram
					rw_to_ram <= 1'b1;
					addr_to_ram <= addr_from_mem;
					data_to_ram <= `ZeroByte;
				end else if (rw_from_mem == 2'b10) begin //store
					state_in_ctrl <= 2'b10;
					addr_in_ctrl <= addr_from_mem;
					data_in_ctr <= data_to_mem;
					bits_in_ctrl <= bits_from_mem;
					//output to ram
					rw_to_ram <= 1'b0;
					addr_to_ram <= addr_from_mem;
					data_to_ram <= data_from_mem[bits_from_mem: bits_from_mem - `ByteShamt];					
				end else if (r_from_if == 1'b1) begin //if
					state_in_ctrl <= 2'b11;
					addr_in_ctrl <= addr_from_if;
					data_in_ctrl <= data_from_ctrl;
					bits_in_ctrl <= 5'b11111;
					//output to ram
					rw_to_ram <= 1'b1;
					addr_to_ram <= addr_from_if;
					data_to_ram <= `ZeroByte;
				end else begin //do nothing
					state_in_ctrl <= 2'b00;
					addr_in_ctrl <= `ZeroWord;
					data_in_ctrl <= `ZeroWord;
					bits_in_ctrl <= 5'b00000;
					//output to ram
					rw_to_ram <= 1'b1;
					addr_to_ram <= `ZeroWord;
					data_to_ram <= `ZeroByte;
				end 
			end else if (state_in_ctrl == 2'b01) begin
				
			end else if (state_in_ctrl == 2'b10) begin
				
			end else begin
				
			end
		end
	end
endmodule

