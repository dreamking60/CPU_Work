`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/20 11:13:21
// Design Name: 
// Module Name: Controller
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


module control32 (
    input[5:0] Opcode,
    input[5:0] Function_opcode,

    output Jr,
    output RegDST,
    output ALUSrc,
    output MemtoReg,
    output RegWrite,
    output MemWrite,
    output Branch,
    output nBranch,
    output Jmp,
    output Jal,



    output I_format,
    output Sftmd,
    output [1:0] ALUOp
);

wire R_format;
wire lw;
wire sw;

assign R_format = (Opcode == 6'b000000)?1'b1:1'b0,
    I_format = (Opcode[5:3] == 3'b001)?1'b1:1'b0,
    lw = (Opcode == 6'b100011)?1'b1:1'b0,
    sw = (Opcode == 6'b101011)?1'b1:1'b0,

    Jr = ((Function_opcode == 6'b001000)&&(Opcode == 6'b000000))?1'b1:1'b0,
    Jmp = (Opcode == 6'b000010)?1'b1:1'b0,
    Jal = (Opcode == 6'b000011)?1'b1:1'b0,

    Branch = (Opcode == 6'b000100)?1'b1:1'b0,
    nBranch = (Opcode == 6'b000101)?1'b1:1'b0,

    RegDST = R_format,
    RegWrite = (R_format||lw||Jal||I_format) && !(Jr),

    ALUSrc = I_format || lw || sw,
    ALUOp = {(R_format||I_format),(Branch||nBranch)},
    Sftmd=(((Function_opcode == 6'b000000)||(Function_opcode == 6'b000010)||(Function_opcode == 6'b000011)||(Function_opcode == 6'b000100)||(Function_opcode == 6'b000110)||(Function_opcode == 6'b000111))&&R_format)?1'b1:1'b0,
    
    MemWrite = sw,
    MemtoReg = lw;
       

endmodule
