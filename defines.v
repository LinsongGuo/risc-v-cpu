`define Enable 1'b1
`define Disable 1'b0

`define ZeroWord 32'h00000000

`define ByteBus 7:0
`define ShamtBus 4:0
`define DataBus 31:0
`define DataAddrBus 31:0

`define InstBus 31:0
`define InstAddrBus 31:0
`define InvalidInst 32'h10000000

`define ByteShamt 5'b00111
`define ZeroByte 8'b00000000

`define RegBus 31:0
`define RegAddrBus 4:0
`define RegWidth 32
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

`define NOPShamt 5'b00000

`define RamSize 1024
`define RamSizeLog2 10

`define StallBus 4:0
`define Stop 1'b1
`define NoStop 1'b0

`define OpcodeBus    6:0
`define OpcodeNOP    7'b0000000
`define OpcodeLUI    7'b0110111
`define OpcodeAUIPC  7'b0010111
`define OpcodeJAL    7'b1101111
`define OpcodeJALR   7'b1100111
`define OpcodeBranch 7'b1100011
`define OpcodeLoad   7'b0000011
`define OpcodeStore  7'b0100011
`define OpcodeCalcI  7'b0010011
`define OpcodeCalc   7'b0110011 


`define OptBus   5:0
`define OptNOP   6'b000000
`define OptLUI   6'b000001
`define OptAUIPC 6'b000010
`define OptJAL   6'b000011
`define OptJALR  6'b000100
`define OptBEQ   6'b000101
`define OptBNE   6'b000110
`define OptBLT   6'b000111
`define OptBGE   6'b001000 
`define OptBLTU  6'b001001
`define OptBGEU  6'b001010
`define OptLB    6'b001011
`define OptLH    6'b001100
`define OptLW    6'b001101
`define OptLBU   6'b001110
`define OptLHU   6'b001111
`define OptSB    6'b010000
`define OptSH    6'b010001
`define OptSW    6'b010010
`define OptADDI  6'b010011
`define OptSLTI  6'b010100
`define OptSLTIU 6'b010101 
`define OptXORI  6'b010110
`define OptORI   6'b010111
`define OptANDI  6'b011000
`define OptSLLI  6'b011001
`define OptSRLI  6'b011010
`define OptSRAI  6'b011011
`define OptADD   6'b011100
`define OptSUB   6'b011101
`define OptSLL   6'b011110
`define OptSLT   6'b011111
`define OptSLTU  6'b100000
`define OptXOR   6'b100001
`define OptSRL   6'b100010
`define OptSRA   6'b100011
`define OptOR    6'b100100
`define OptAND   6'b100101
