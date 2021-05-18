`timescale 1ns / 1ps

module Ifetc32(
    Instruction,branch_base_addr,Addr_result,
    Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,
    clock,reset,link_addr,pco
);
    output[31:0] Instruction;
    output[31:0] branch_base_addr;
    output reg [31:0] link_addr;
    output[31:0] pco;

    input clock,reset;
//from ALU
    input[31:0] Addr_result;
    input Zero;                         //while Zero is 1, ALUresult is zero.
//from Decoder
    input[31:0] Read_data_1;
//from constroller
    input Branch;
    input nBranch;
    input Jmp;                      
    input Jal;
    input Jr;

reg[31:0] PC, Next_PC;
reg[31:0] bb;

prgrom instmem(
    .clka(clock),
    .addra(PC[15:2]), 
    .douta(Instruction) 
);

assign branch_base_addr = PC + 4;
assign pco = PC;

always @*
begin
    if(((Branch == 1) && (Zero == 1)) || ((nBranch == 1) && (Zero == 0)))
    begin
        Next_PC = (Addr_result << 2);
    end
    else if(Jr == 1)
    begin
        Next_PC = (Read_data_1 << 2);
    end
    else 
    begin
        Next_PC = PC + 4;
    end    

end

always @(negedge clock)
begin
    if(reset == 1)
    begin
        PC <= 32'h0000_0000;
    end
    else if((Jmp == 1) || (Jal == 1))
    begin
        link_addr = (PC+4) >> 2;
        PC <= {{PC+4}[31:28], Instruction[27:0]<<2};
    end
    else 
    begin
       PC <= Next_PC;
    end
end


endmodule 