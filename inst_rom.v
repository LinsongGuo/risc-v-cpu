`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/08 19:58:29
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(
    input wire ce,

    //input from pc_reg
    input wire[`InstAddrBus] pcreg_addr_i,
    
    //output to if
    output reg[`InstBus] if_inst_o
    );
    
    reg[`ByteWidth] rom_data[0: `RamSize - 1];
    initial $readmemh ("D:/courses/CA/cpu1/data.txt", rom_data);
  
    always @ (posedge clk) begin
        if (ce == `Disable) begin
            if_inst_o = `ZeroWord;
        end else begin
            if_inst_o = {rom_data[pcreg_addr_i[`RoMSizeLog2 - 1 : 0] + 3], 
                rom_data[pcreg_addr_i[`RoMSizeLog2 - 1 : 0] + 2], 
                rom_data[pcreg_addr_i[`RoMSizeLog2 - 1 : 0] + 1], 
                rom_data[pcreg_addr_i[`RoMSizeLog2 - 1 : 0]]};
        end
    end
    
endmodule
