// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "defines.v"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

    //stallctrl
    wire stallreq_from_pcreg;
    wire stallreq_from_if;
    wire stallreq_from_id;
    wire stallreq_from_mem;
    wire[`StallBus] stall;

    //memctrl -- if 
    wire flag_from_if_to_ctrl;
    wire r_from_if_to_ctrl;
    wire[`InstAddrBus] addr_from_if_to_ctrl;
    wire r_from_ctrl_to_if;
    wire[`ByteBus] data_from_ctrl_to_if;

    //memctrl -- mem
    wire flag_from_mem_to_ctrl;
    wire[1: 0] rw_from_mem_to_ctrl; //01:load, 10:store
    wire[`DataAddrBus] addr_from_mem_to_ctrl;
    wire[`ByteBus] data_from_mem_to_ctrl;
    wire r_from_ctrl_to_mem;
    wire[`ByteBus] data_from_ctrl_to_mem;

    //memctrl -- ram
    wire[`ByteBus] data_from_ram_to_ctrl;
    wire rw_from_ctrl_to_ram; //read:1 write:0
    wire[`DataAddrBus] addr_from_ctrl_to_ram;
    wire[`ByteBus] data_from_ctrl_to_ram;

    //pc_reg -- if
    wire flag_from_pcreg_to_if;
    wire[`InstAddrBus] pc_from_pcreg_to_if;
    
    //if -- if_id
    wire[`InstAddrBus] pc_from_if_to_ifid;
    wire flag_from_if_to_ifid;
    wire first_from_if_to_ifid;
    wire[`InstBus] inst_from_if_to_ifid; 

    //if_id -- id
    wire first_from_ifid_to_id;
    wire[`InstAddrBus] pc_from_ifid_to_id;
    wire[`InstBus] inst_from_ifid_to_id;

    //id -- regfile
    wire re1_from_id_to_rf; 
    wire re2_from_id_to_rf;
    wire[`RegAddrBus] raddr1_from_id_to_rf;    
    wire[`RegAddrBus] raddr2_from_id_to_rf;
    wire[`RegBus] rdata1_from_rf_to_id;
    wire[`RegBus] rdata2_from_rf_to_id;
  
    //id -- id_ex
    wire[`InstAddrBus] pc_from_id_to_idex;
    wire[`OpcodeBus] opcode_from_id_to_idex;
    wire[`OptBus] opt_from_id_to_idex;
    wire[`RegBus] rdata1_from_id_to_idex;
    wire[`RegBus] rdata2_from_id_to_idex;
    wire we_from_id_to_idex;
    wire[`RegAddrBus] waddr_from_id_to_idex;
    wire[`DataBus] imm_from_id_to_idex;
    wire[`ShamtBus] shamt_from_id_to_idex;

    //id_ex -- ex
    wire[`InstAddrBus] pc_from_idex_to_ex;
    wire[`OpcodeBus] opcode_from_idex_to_ex;
    wire[`OptBus] opt_from_idex_to_ex;
    wire[`RegBus] rdata1_from_idex_to_ex;
    wire[`RegBus] rdata2_from_idex_to_ex;
    wire we_from_idex_to_ex;
    wire[`RegAddrBus] waddr_from_idex_to_ex;
    wire[`DataBus] imm_from_idex_to_ex;
    wire[`ShamtBus] shamt_from_idex_to_ex;

    //ex -- ex_mem / regfile(forwarding)
    wire[`OpcodeBus] opcode_from_ex;
    wire[`OptBus] opt_from_ex_to_exmem;
    wire we_from_ex;
    wire[`RegAddrBus] waddr_from_ex;
    wire[`RegBus] alu_from_ex;
    wire cond_from_ex_to_exmem;
    wire[`RegBus] rdata2_from_ex_to_exmem;

    //ex_mem -- mem
    wire[`OpcodeBus] opcode_from_exmem_to_mem;
    wire[`OptBus] opt_from_exmem_to_mem;
    wire we_from_exmem_to_mem;
    wire[`RegAddrBus] waddr_from_exmem_to_mem;
    wire[`RegBus] alu_from_exmem_to_mem;
    wire cond_from_exmem_to_mem;
    wire[`RegBus] rdata2_from_exmem_to_mem;
    wire flag_from_exmem_to_mem;

    //mem -- mem_wb / regfile(forwarding)
    wire[`OpcodeBus] opcode_from_mem;
    wire[`OptBus] opt_from_mem_to_memwb;
    wire we_from_mem;
    wire[`RegAddrBus] waddr_from_mem;
    wire[`RegBus] wdata_from_mem;

    //mem_wb -- regfile
    wire we_from_memwb_to_rf;
    wire[`RegAddrBus] waddr_from_memwb_to_rf;
    wire[`RegBus] wdata_from_memwb_to_rf;
  
    pc_reg pc_reg0(
        .clk(clk_in), .rst(rst_in),

        .stall(stall),
        
        .pc_o(pc_from_pcreg_to_if),

        .stallreq_from_pcreg(stallreq_from_pcreg)
    );
    
    If if0(
        .clk(clk_in), .rst(rst_in),
        
        .pc_i(pc_from_pcreg_to_if),
        
        .r_from_memctrl(r_from_ctrl_to_if),
        .data_from_memctrl(data_from_ctrl_to_if),

        .flag_to_ctrl(flag_from_if_to_ctrl),
        .r_to_memctrl(r_from_if_to_ctrl),
        .addr_to_memctrl(addr_from_if_to_ctrl),

        .stall(stall),

        .stallreq_from_if(stallreq_from_if),

        .pc_o(pc_from_if_to_ifid),
        .flag_o(flag_from_if_to_ifid),
        .first_o(first_from_if_to_ifid),
        .inst_o(inst_from_if_to_ifid)
    );

    if_id if_id0(
        .clk(clk_in), .rst(rst_in),

        .if_flag(flag_from_if_to_ifid),
        .if_first(flag_from_if_to_ifid),
        .if_pc(pc_from_if_to_ifid),
        .if_inst(inst_from_if_to_ifid),

        .stall(stall),

        .id_first(first_from_ifid_to_id),
        .id_pc(pc_from_ifid_to_id),
        .id_inst(inst_from_ifid_to_id)
    );
    
    id id0(
        .rst(rst_in),

        .first_i(first_from_ifid_to_id),
        .pc_i(pc_from_ifid_to_id),
        .inst_i(inst_from_ifid_to_id),

        .rdata1_i(rdata1_from_rf_to_id),
        .rdata2_i(rdata2_from_rf_to_id),

        .re1_o(re1_from_id_to_rf),
        .re2_o(re2_from_id_to_rf),
        .raddr1_o(raddr1_from_id_to_rf),
        .raddr2_o(raddr2_from_id_to_rf),

        .pc_o(pc_from_id_to_idex),
        .opcode_o(opcode_from_id_to_idex),
        .opt_o(opt_from_id_to_idex),
        .rdata1_o(rdata1_from_id_to_idex),
        .rdata2_o(rdata2_from_id_to_idex),
        .we_o(we_from_id_to_idex),
        .waddr_o(waddr_from_id_to_idex),
        .imm_o(imm_from_id_to_idex),
        .shamt_o(shamt_from_id_to_idex)
    );

    id_ex id_ex0(
        .clk(clk_in), .rst(rst_in),

        .id_pc(pc_from_id_to_idex),
        .id_opcode(opcode_from_id_to_idex),
        .id_opt(opt_from_id_to_idex),
        .id_rdata1(rdata1_from_id_to_idex),
        .id_rdata2(rdata2_from_id_to_idex),
        .id_we(we_from_id_to_idex),
        .id_waddr(waddr_from_id_to_idex),
        .id_imm(imm_from_id_to_idex),
        .id_shamt(shamt_from_id_to_idex),

        .stall(stall),

        .ex_pc(pc_from_idex_to_ex),
        .ex_opcode(opcode_from_idex_to_ex),
        .ex_opt(opt_from_idex_to_ex),
        .ex_rdata1(rdata1_from_idex_to_ex),
        .ex_rdata2(rdata2_from_idex_to_ex),
        .ex_we(we_from_idex_to_ex),
        .ex_waddr(waddr_from_idex_to_ex),
        .ex_imm(imm_from_idex_to_ex),
        .ex_shamt(shamt_from_idex_to_ex)
    );


     ex ex0(
        .rst(rst_in),

        .pc_i(pc_from_idex_to_ex),
        .opcode_i(opcode_from_idex_to_ex),
        .opt_i(opt_from_idex_to_ex),
        .rdata1_i(rdata1_from_idex_to_ex),
        .rdata2_i(rdata2_from_idex_to_ex),
        .we_i(we_from_idex_to_ex),
        .waddr_i(waddr_from_idex_to_ex),
        .imm_i(imm_from_idex_to_ex),
        .shamt_i(shamt_from_idex_to_ex),

        .opcode_o(opcode_from_ex),
        .opt_o(opt_from_ex_to_exmem),
        .we_o(we_from_ex),
        .waddr_o(waddr_from_ex),
        .alu_o(alu_from_ex),
        .cond_o(cond_from_ex_to_exmem),
        .rdata2_o(rdata2_from_ex_to_exmem)    
    );

    ex_mem ex_mem0(
        .clk(clk_in), .rst(rst_in),

        .ex_opcode(opcode_from_ex),
        .ex_opt(opt_from_ex_to_exmem),
        .ex_we(we_from_ex),
        .ex_waddr(waddr_from_ex),
        .ex_alu(alu_from_ex),
        .ex_cond(cond_from_ex_to_exmem),
        .ex_rdata2(rdata2_from_ex_to_exmem),

        .stall(stall),
        
        .mem_opcode(opcode_from_exmem_to_mem),
        .mem_opt(opt_from_exmem_to_mem),
        .mem_we(we_from_exmem_to_mem),
        .mem_waddr(waddr_from_exmem_to_mem),
        .mem_alu(alu_from_exmem_to_mem),
        .mem_cond(cond_from_exmem_to_mem),
        .mem_rdata2(rdata2_from_exmem_to_mem),
        .mem_flag(flag_from_exmem_to_mem)
    );

    mem mem0(
        .clk(clk_in), .rst(rst_in),

        .opcode_i(opcode_from_exmem_to_mem),
        .opt_i(opt_from_exmem_to_mem),
        .we_i(we_from_exmem_to_mem),
        .waddr_i(waddr_from_exmem_to_mem),
        .alu_i(alu_from_exmem_to_mem),
        .cond_i(cond_from_exmem_to_mem),
        .rdata2_i(rdata2_from_exmem_to_mem),
        .flag_i(flag_from_exmem_to_mem),

        .opcode_o(opcode_from_mem),
        .opt_o(opt_from_mem_to_memwb),
        .we_o(we_from_mem),
        .waddr_o(waddr_from_mem),
        .wdata_o(wdata_from_mem),

        .r_from_memctrl(r_from_ctrl_to_mem),
        .data_from_memctrl(data_from_ctrl_to_mem),

        .flag_to_memctrl(flag_from_mem_to_ctrl),
        .rw_to_memctrl(rw_from_mem_to_ctrl),
        .addr_to_memctrl(addr_from_mem_to_ctrl),
        .data_to_memctrl(data_from_mem_to_ctrl),

        .stallreq_from_mem(stallreq_from_mem)
    );

    mem_wb mem_wb0(
        .clk(clk_in), .rst(rst_in),

        .mem_we(we_from_mem),
        .mem_waddr(waddr_from_mem),
        .mem_wdata(wdata_from_mem),

        .stall(stall),

        .wb_we(we_from_memwb_to_rf),
        .wb_waddr(waddr_from_memwb_to_rf),
        .wb_wdata(wdata_from_memwb_to_rf)
    );

    regfile regfile0(
        .clk(clk_in), .rst(rst_in),

        .wb_we_i(we_from_memwb_to_rf),
        .wb_waddr_i(waddr_from_memwb_to_rf),
        .wb_wdata_i(wdata_from_memwb_to_rf),

        .mem_opcode_i(opcode_from_mem),
        .mem_we_i(we_from_mem),
        .mem_waddr_i(waddr_from_mem),
        .mem_wdata_i(wdata_from_mem),

        .ex_opcode_i(opcode_from_ex),
        .ex_we_i(we_from_ex),
        .ex_waddr_i(waddr_from_ex),
        .ex_alu_i(alu_from_ex),

        .re1_i(re1_from_id_to_rf),
        .re2_i(re2_from_id_to_rf),
        .raddr1_i(raddr1_from_id_to_rf),
        .raddr2_i(raddr2_from_id_to_rf),

        .rdata1_o(rdata1_from_rf_to_id),
        .rdata2_o(rdata2_from_rf_to_id),

        .stallreq_from_id(stallreq_from_id)
    );

    stallctrl stallctrl(
        .rst(rst_in),

        .stallreq_from_pcreg(stallreq_from_pcreg),
        .stallreq_from_if(stallreq_from_if),
        .stallreq_from_id(stallreq_from_id),
        .stallreq_from_mem(stallreq_from_mem),

        .stall(stall)
    );

    memctrl memctrl(
        .rst(rst_in),

        .flag_from_if(flag_from_if_to_ctrl),
        .r_from_if(r_from_if_to_ctrl),
        .addr_from_if(addr_from_if_to_ctrl),

        .r_to_if(r_from_ctrl_to_if),
        .data_to_if(data_from_ctrl_to_if),

        .flag_from_mem(flag_from_mem_to_ctrl),
        .rw_from_mem(rw_from_mem_to_ctrl),
        .addr_from_mem(addr_from_mem_to_ctrl),
        .data_from_mem(data_from_mem_to_ctrl),

        .r_to_mem(r_from_ctrl_to_mem),
        .data_to_mem(data_from_ctrl_to_mem),

        .data_from_ram(mem_din),

        .rw_to_ram(mem_wr),
        .addr_to_ram(mem_a),
        .data_to_ram(mem_dout)
    );
/*
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end
*/
endmodule