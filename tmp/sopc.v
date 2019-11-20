`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/08 20:04:38
// Design Name: 
// Module Name: sopc
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


module sopc(
    input wire clk,
    input wire rst
    );
    
    wire rom_ce;
    wire[`InstAddrBus] addr;
    wire[`InstBus] inst;
   
   mips mips0(
       .clk(clk), .rst(rst),
       .rom_data_i(inst),
       .rom_ce_o(rom_ce), .rom_addr_o(addr)
   );
   
   inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(addr), .inst(inst)
   );
   
endmodule
