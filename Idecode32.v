`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/12 02:35:12
// Design Name: 
// Module Name: Idecode32
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


module Idecode32(
    output [31:0] read_data_1,
    output [31:0] read_data_2,
    input [31:0] Instruction,
    input [31:0] read_data,
    input [31:0] ALU_result,
    input Jal, RegWrite, MemtoReg, RegDst, 
    output [31:0] imme_extend, 
    input clock, reset,
    input [31:0] opcplus4
    );

    reg [31:0] rg[0:31];
    wire [4:0] rs = Instruction[25:21];
    wire [4:0] rt = Instruction[20:16];
    wire [4:0] rd = Instruction[15:11];
    wire [5:0] Opcode = Instruction[31:26];
    wire [15:0] imme = Instruction[15:0];
    
    assign imme_extend = (Opcode == 6'hd || Opcode == 6'hc) ? {{16{1'b0}},imme} : {{16{imme[15]}},imme};
    wire [4:0] wr = (Jal) ? 5'b11111 : (RegDst) ? rd : rt;
    wire [31:0] wr_data = (Jal) ? opcplus4 : (MemtoReg == 1'b0) ? ALU_result : read_data;
    
    assign read_data_1 = rg[rs];
    assign read_data_2 = rg[rt];

    integer i;
    always @(posedge clock or negedge reset) 
    begin
        if(reset == 1)
        begin
            for(i = 0; i < 32; i = i+1)
                rg[i] <= 0;
        end
        else if(RegWrite == 1 && wr != 0)
        begin
            rg[wr] <= wr_data;
        end

    end

endmodule
