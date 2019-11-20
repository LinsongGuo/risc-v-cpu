`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/17 23:24:08
// Design Name: 
// Module Name: riscv
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


module riscv(
		input wire clk,
        input wire rst,
        
        //the input address from rom
        input wire[`RegBus] rom_data_i,
        
        //the output address to rom
        output wire[`RegBus] rom_addr_o 
    );
	 //if --> if_id
    wire[`InstAddrBus] if_pc_o;
    
    //if_id --> id
    wire[`InstAddrBus] id_pc_i;
    wire[`InstBus] id_inst_i;
    
    //id --> id_ex
    wire[`AluOpBus] id_opcode_o;
    wire[`AluSelBus] id_opt_o;
    wire[`RegBus] id_reg1_o;
    wire[`RegBus] id_reg2_o;
    wire id_wreg_o;
    wire[`RegAddrBus] id_wd_o;
    
    //id_ex --> ex
    wire[`AluOpBus] ex_aluop_i;
    wire[`AluSelBus] ex_alusel_i;
    wire[`RegBus] ex_reg1_i;
    wire[`RegBus] ex_reg2_i;
    wire ex_wreg_i;
    wire[`RegAddrBus] ex_wd_i;
    
    //ex --> ex_mem
    wire ex_wreg_o;
    wire[`RegAddrBus] ex_wd_o;
    wire[`RegBus] ex_wdata_o;
    
    //ex_mem --> mem
    wire mem_wreg_i;
    wire[`RegAddrBus] mem_wd_i;
    wire[`RegBus] mem_wdata_i;
    
    //mem --> mem_wb
    wire mem_wreg_o;
    wire[`RegAddrBus] mem_wd_o;
    wire[`RegBus] mem_wdata_o;
    
    //mem_wb --> wb
    wire wb_wreg_i;
    wire[`RegAddrBus] wb_wd_i;
    wire[`RegBus] wb_wdata_i;
    
    //id --> regfile
    wire reg1_read;
    wire reg2_read;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;
    
    //regfile --> id
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
	
    wire[`StallBus] stall;
    wire stallreq_from_id;
    wire stallreq_from_mem;
     

	pc_reg pc_reg0(
        .clk(clk), .rst(rst), 
        //input from stallctrl
        .stall(stall),
        .pc(if_pc_o),
    );
    
    assign rom_addr_o = if_pc_o;
    
    if_id if_id0(
        .clk(clk), .rst(rst),
        //input from if and rom
        .if_pc(if_pc_o), .if_inst(rom_data_i), 
        //input from stallctrl
        .stall(stall),
        //output to id
        .id_pc(id_pc_i), .id_inst(id_inst_i)
    );
    
    id id0(
		.rst(rst),
		//input from if_id
		.pc_i(id_pc_i), .inst_i(id_inst_i),   
        //input from regfile
		.reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
        //output to regfile
		.reg1_read_o(reg1_read), .reg2_read_o(reg2_read), .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr), 
		//output to id_ex
		.opcode_o(id_opcode_o), .opt_o(id_opt_o), .reg1_data_o(id_reg1_o), .reg2_data_o(id_reg2_o), 
        .wreg_o(id_wreg_o), .wd_o(id_wd_o), .imm_o(), .shamt_o()
	);
	
	regfile regfile0(
	   .clk(clk), .rst(rst),
	   //input from mem_wb
	   .we(wb_wreg_i), .waddr(wb_wd_i), .wdata(wb_wdata_i), 
	   //input from id
	   .re1(reg1_read), .raddr1(reg1_addr), .re2(reg2_read), .raddr2(reg2_addr),
	   //output to id
	   .rdata1(reg1_data), .rdata2(reg2_data)
	);
	
    id_ex id_ex0(
        .clk(clk), .rst(rst),
        //input from id
        .id_aluop(id_aluop_o), .id_alusel(id_alusel_o), .id_reg1(id_reg1_o), .id_reg2(id_reg2_o), .id_wreg(id_wreg_o), .id_wd(id_wd_o),
        //output to ex
        .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i), .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i), .ex_wreg(ex_wreg_i), .ex_wd(ex_wd_i)
    ); 
    
    ex ex0(
        .rst(rst),
        //input from id_ex
        .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i), .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i), .wreg_i(ex_wreg_i), .wd_i(ex_wd_i),
        //output to ex_mem
        .wreg_o(ex_wreg_o), .wd_o(ex_wd_o), .wdata_o(ex_wdata_o)
    );
    
    ex_mem ex_mem0(
        .clk(clk), .rst(rst),
        //input from ex
        .ex_wreg(ex_wreg_o), .ex_wd(ex_wd_o), .ex_wdata(ex_wdata_o),
        //output to mem
        .mem_wreg(mem_wreg_i), .mem_wd(mem_wd_i), .mem_wdata(mem_wdata_i)
    );
    
    mem mem0(
        .rst(rst),
        //input from ex_mem
        .wreg_i(mem_wreg_i), .wd_i(mem_wd_i), .wdata_i(mem_wdata_i),
        //output to mem_wb
        .wreg_o(mem_wreg_o), .wd_o(mem_wd_o), .wdata_o(mem_wdata_o)
    );
    
    mem_wb mem_wb0(
        .clk(clk), .rst(rst),
        //input from mem
        .mem_wreg(mem_wreg_o), .mem_wd(mem_wd_o), .mem_wdata(mem_wdata_o),
        //output to wb
        .wb_wreg(wb_wreg_i), .wb_wd(wb_wd_i), .wb_wdata(wb_wdata_i)
    );
endmodule
