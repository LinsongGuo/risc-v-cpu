//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 15:07:54
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
    input wire clk,
    input wire rst,
    
    //input from mem
    input wire mem_we,
    input wire[`RegAddrBus] mem_waddr,
    input wire[`RegBus] mem_wdata,
    
    input wire[`StallBus] stall,
        
    //output to regfile(write back)
    output reg wb_we,
    output reg[`RegAddrBus] wb_waddr,
    output reg[`RegBus] wb_wdata
    );
    
    always @ (posedge clk) begin
        if(rst == `Enable) begin
            wb_we <= `Disable;
            wb_waddr <= `NOPRegAddr;
            wb_wdata <= `ZeroWord;
        end else begin
            if (stall[4] == `Stop) begin
                wb_we <= `Disable;
                wb_waddr <= `NOPRegAddr;
                wb_wdata <= `ZeroWord;
            end else begin
                wb_we <= mem_we;
                wb_waddr <= mem_waddr;
                wb_wdata <= mem_wdata;    
            end    
        end
    end
    
endmodule
