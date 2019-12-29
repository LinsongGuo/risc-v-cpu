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

    //branch and BTB
    wire [`InstAddrBus]pc_from_ex;
    wire branch_from_ex;
    wire jump_from_ex;
    wire [`InstAddrBus]jump_addr_from_ex;
    wire goback_from_ex;
    wire [`InstAddrBus]goback_addr_from_ex;
    wire read_from_if_to_BTB;
    wire[`InstAddrBus] addr_from_if_to_BTB;
    wire res_from_BTB_to_if;
    wire [`InstAddrBus]addr_from_BTB_to_if;
    wire jump_from_BTB_to_ifid;
    wire jump_from_ifid_to_id;
    wire jump_from_id_to_idex;
    wire jump_from_idex_to_ex;

    //stallctrl
    wire stallreq_from_id;
    wire stallreq_from_mem;
    wire[`StallBus] stall;

    //memctrl -- if 
    wire[`InstAddrBus] addr_from_if_to_ctrl;
    wire[`ByteBus] data_from_ctrl_to_if;

    //memctrl -- mem
    wire[1: 0] rw_from_mem_to_ctrl; //01:load, 10:store
    wire[`DataAddrBus] addr_from_mem_to_ctrl;
    wire[`ByteBus] data_from_mem_to_ctrl;
    wire[`ByteBus] data_from_ctrl_to_mem;

    //memctrl -- ram
    wire[`ByteBus] data_from_ram_to_ctrl;
    wire rw_from_ctrl_to_ram; //read:1 write:0
    wire[`DataAddrBus] addr_from_ctrl_to_ram;
    wire[`ByteBus] data_from_ctrl_to_ram;

    //icache -- if
    wire write_from_if_to_icache;
    wire[31: 0] write_addr_from_if_to_icache;
    wire[`InstBus] write_inst_from_if_to_icache;
    wire read_from_if_to_icache;
    wire[31: 0] read_addr_from_if_to_icache;
    wire read_hit_from_icache_to_if;
    wire[`InstBus] read_inst_from_icache_to_if;

    
    //if -- if_id
    wire[`InstAddrBus] pc_from_if_to_ifid;
    wire flag_from_if_to_ifid;
    wire[`InstBus] inst_from_if_to_ifid;

    //if_id -- id
    wire flag_from_ifid_to_id;
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
    wire[`RegBus] rdata2_from_ex_to_exmem;

    //ex_mem -- mem
    wire[`OpcodeBus] opcode_from_exmem_to_mem;
    wire[`OptBus] opt_from_exmem_to_mem;
    wire we_from_exmem_to_mem;
    wire[`RegAddrBus] waddr_from_exmem_to_mem;
    wire[`RegBus] alu_from_exmem_to_mem;
    wire[`RegBus] rdata2_from_exmem_to_mem;
    
    //mem -- mem_wb / regfile(forwarding)
    wire[`OpcodeBus] opcode_from_mem;
    wire we_from_mem;
    wire[`RegAddrBus] waddr_from_mem;
    wire[`RegBus] wdata_from_mem;

    //mem_wb -- regfile
    wire we_from_memwb_to_rf;
    wire[`RegAddrBus] waddr_from_memwb_to_rf;
    wire[`RegBus] wdata_from_memwb_to_rf;

    BTB BTB0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),
        
        .read_from_if(read_from_if_to_BTB),
        .addr_from_if(addr_from_if_to_BTB),

        .res_to_if(res_from_BTB_to_if),
        .addr_to_if(addr_from_BTB_to_if),

        .jump_to_ifid(jump_from_BTB_to_ifid),

        .pc_from_ex(pc_from_ex),
        .branch_from_ex(branch_from_ex),
        .jump_from_ex(jump_from_ex),
        .jump_addr_from_ex(jump_addr_from_ex)
    );

    If if0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),
        
        .read_hit_i(read_hit_from_icache_to_if),
        .read_inst_i(read_inst_from_icache_to_if),

        .read_o(read_from_if_to_icache),
        .read_addr_o(read_addr_from_if_to_icache),
        .write_o(write_from_if_to_icache),
        .write_addr_o(write_addr_from_if_to_icache),
        .write_inst_o(write_inst_from_if_to_icache),

        .res_from_BTB(res_from_BTB_to_if),
        .addr_from_BTB(addr_from_BTB_to_if),

        .read_to_BTB(read_from_if_to_BTB),
        .addr_to_BTB(addr_from_if_to_BTB),

        .goback_from_ex(goback_from_ex),
        .goback_addr_from_ex(goback_addr_from_ex),        

        .data_from_memctrl(data_from_ctrl_to_if),

        .addr_to_memctrl(addr_from_if_to_ctrl),

        .stall(stall),
        
        .pc_o(pc_from_if_to_ifid),
        .flag_o(flag_from_if_to_ifid),
        .inst_o(inst_from_if_to_ifid)
    );

   icache icache0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .read_i(read_from_if_to_icache),
        .read_addr_i(read_addr_from_if_to_icache),

        .write_i(write_from_if_to_icache),
        .write_addr_i(write_addr_from_if_to_icache),
        .write_inst_i(write_inst_from_if_to_icache),

        .read_hit_o(read_hit_from_icache_to_if),
        .read_inst_o(read_inst_from_icache_to_if)
    );

    if_id if_id0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .stall(stall),
        
        .jump_from_BTB(jump_from_BTB_to_ifid),

        .if_flag(flag_from_if_to_ifid),
        .if_pc(pc_from_if_to_ifid),
        .if_inst(inst_from_if_to_ifid),

        .goback_from_ex(goback_from_ex),

        .id_flag(flag_from_ifid_to_id),
        .id_jump(jump_from_ifid_to_id),
        .id_pc(pc_from_ifid_to_id),
        .id_inst(inst_from_ifid_to_id)
    );
    
    id id0(
        .rst(rst_in), .rdy(rdy_in),

        .flag_i(flag_from_ifid_to_id),
        .jump_i(jump_from_ifid_to_id),
        .pc_i(pc_from_ifid_to_id),
        .inst_i(inst_from_ifid_to_id),

        .rdata1_i(rdata1_from_rf_to_id),
        .rdata2_i(rdata2_from_rf_to_id),

        .re1_o(re1_from_id_to_rf),
        .re2_o(re2_from_id_to_rf),
        .raddr1_o(raddr1_from_id_to_rf),
        .raddr2_o(raddr2_from_id_to_rf),

        .pc_o(pc_from_id_to_idex),
        .jump_o(jump_from_id_to_idex),
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
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .id_pc(pc_from_id_to_idex),
        .id_jump(jump_from_id_to_idex),
        .id_opcode(opcode_from_id_to_idex),
        .id_opt(opt_from_id_to_idex),
        .id_rdata1(rdata1_from_id_to_idex),
        .id_rdata2(rdata2_from_id_to_idex),
        .id_we(we_from_id_to_idex),
        .id_waddr(waddr_from_id_to_idex),
        .id_imm(imm_from_id_to_idex),
        .id_shamt(shamt_from_id_to_idex),

        .stall(stall),

        .goback_from_ex(goback_from_ex),

        .ex_pc(pc_from_idex_to_ex),
        .ex_jump(jump_from_idex_to_ex),
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
        .rst(rst_in), .rdy(rdy_in),

        .pc_i(pc_from_idex_to_ex),
        .opcode_i(opcode_from_idex_to_ex),
        .opt_i(opt_from_idex_to_ex),
        .rdata1_i(rdata1_from_idex_to_ex),
        .rdata2_i(rdata2_from_idex_to_ex),
        .we_i(we_from_idex_to_ex),
        .waddr_i(waddr_from_idex_to_ex),
        .imm_i(imm_from_idex_to_ex),
        .shamt_i(shamt_from_idex_to_ex),
        .jump_i(jump_from_idex_to_ex),

        .pc_o(pc_from_ex),
        .opcode_o(opcode_from_ex),
        .opt_o(opt_from_ex_to_exmem),
        .we_o(we_from_ex),
        .waddr_o(waddr_from_ex),
        .alu_o(alu_from_ex),
        .rdata2_o(rdata2_from_ex_to_exmem),

        .branch_o(branch_from_ex),
        .jump_o(jump_from_ex),
        .jump_addr_o(jump_addr_from_ex),
        .goback_o(goback_from_ex),
        .goback_addr_o(goback_addr_from_ex)    
    );

    ex_mem ex_mem0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .ex_opcode(opcode_from_ex),
        .ex_opt(opt_from_ex_to_exmem),
        .ex_we(we_from_ex),
        .ex_waddr(waddr_from_ex),
        .ex_alu(alu_from_ex),
        .ex_rdata2(rdata2_from_ex_to_exmem),

        .stall(stall),
        
        .mem_opcode(opcode_from_exmem_to_mem),
        .mem_opt(opt_from_exmem_to_mem),
        .mem_we(we_from_exmem_to_mem),
        .mem_waddr(waddr_from_exmem_to_mem),
        .mem_alu(alu_from_exmem_to_mem),
        .mem_rdata2(rdata2_from_exmem_to_mem)
    );

    mem mem0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .opcode_i(opcode_from_exmem_to_mem),
        .opt_i(opt_from_exmem_to_mem),
        .we_i(we_from_exmem_to_mem),
        .waddr_i(waddr_from_exmem_to_mem),
        .alu_i(alu_from_exmem_to_mem),
        .rdata2_i(rdata2_from_exmem_to_mem),
        
        .opcode_o(opcode_from_mem),
        .we_o(we_from_mem),
        .waddr_o(waddr_from_mem),
        .wdata_o(wdata_from_mem),

        .data_from_memctrl(data_from_ctrl_to_mem),

        .rw_to_memctrl(rw_from_mem_to_ctrl),
        .addr_to_memctrl(addr_from_mem_to_ctrl),
        .data_to_memctrl(data_from_mem_to_ctrl),

        .stallreq_from_mem(stallreq_from_mem)
    );

    mem_wb mem_wb0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

        .mem_we(we_from_mem),
        .mem_waddr(waddr_from_mem),
        .mem_wdata(wdata_from_mem),

        .stall(stall),

        .wb_we(we_from_memwb_to_rf),
        .wb_waddr(waddr_from_memwb_to_rf),
        .wb_wdata(wdata_from_memwb_to_rf)
    );

    regfile regfile0(
        .clk(clk_in), .rst(rst_in), .rdy(rdy_in),

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
        .rst(rst_in), .rdy(rdy_in),

        .stallreq_from_id(stallreq_from_id),
        .stallreq_from_mem(stallreq_from_mem),
        
        .stall(stall)
    );

    memctrl memctrl(
        .rst(rst_in), .rdy(rdy_in),

        .addr_from_if(addr_from_if_to_ctrl),

        .data_to_if(data_from_ctrl_to_if),

        .rw_from_mem(rw_from_mem_to_ctrl),
        .addr_from_mem(addr_from_mem_to_ctrl),
        .data_from_mem(data_from_mem_to_ctrl),

        .data_to_mem(data_from_ctrl_to_mem),

        .data_from_ram(mem_din),

        .rw_to_ram(mem_wr),
        .addr_to_ram(mem_a),
        .data_to_ram(mem_dout)
    );

endmodule