`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/16 03:41:47
// Design Name: 
// Module Name: Executs32
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


module Executs32(Read_data_1,Read_data_2,Imme_extend,Function_opcode,opcode,
                 ALUOp,Shamt,ALUSrc,I_format,Zero,Sftmd,ALU_Result,Addr_result,PC_plus_4,Jr);
    input[31:0] Read_data_1;
    input[31:0] Read_data_2;
    input[31:0] Imme_extend;

    input[5:0] Function_opcode;
    input[5:0] opcode;
    input[4:0] Shamt;
    input[31:0] PC_plus_4;

    input[1:0] ALUOp;
    input ALUSrc;
    input I_format;
    input Sftmd;
    input Jr;

    output Zero;
    output reg [31:0] ALU_Result;
    output[31:0] Addr_result;

    wire[31:0] Ainput,Binput;
    wire[5:0] Exe_code;
    wire[2:0] ALU_ctl;
    wire[2:0] Sftm;

    reg[31:0] ALU_output_mux;
    reg[31:0] Shift_Result;

    wire[32:0] Branch_Addr;

    assign Sftm = Function_opcode[2:0];
    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc) ? Imme_extend : Read_data_2;
    assign Exe_code = (I_format) ? {3'b000,opcode[2:0]} : Function_opcode;

    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];

    assign Zero = (ALU_output_mux[31:0] == 32'h0000_0000) ? 1'b1 : 1'b0;
    assign Branch_Addr = PC_plus_4[31:2] + Imme_extend[31:0];
    assign Addr_result = Branch_Addr[31:0];

    always @*
    begin
        if(Sftmd)
            case(Sftm[2:0])
                3'b000:Shift_Result = Binput << Shamt;
                3'b010:Shift_Result = Binput >> Shamt;
                3'b100:Shift_Result = Binput << Ainput;
                3'b110:Shift_Result = Binput >> Ainput;
                3'b011:Shift_Result = $signed(Binput) >>> Shamt;
                3'b111:Shift_Result = Binput >>> Shamt;
                default:Shift_Result = Binput;
            endcase
    end

    always @(ALU_ctl or Ainput or Binput)
    begin
        case(ALU_ctl)
            3'b000:ALU_output_mux = Ainput & Binput;
            3'b001:ALU_output_mux = Ainput | Binput;
            3'b010:ALU_output_mux = Ainput + Binput;
            3'b011:ALU_output_mux = Ainput + Binput;
            3'b100:ALU_output_mux = Ainput ^ Binput;
            3'b101:ALU_output_mux = ~(Ainput | Binput);
            3'b110:ALU_output_mux = Ainput - Binput;
            3'b111:ALU_output_mux = Ainput - Binput;
        endcase
    end

    always @*
    begin
        if((ALU_ctl == 3'b111) && (Exe_code[3] == 1) || (ALU_ctl[2:1] == 2'b11 && (I_format == 1)))
            ALU_Result = (Ainput-Binput<0)?1:0;
        else if((ALU_ctl == 3'b101) && (I_format == 1))
            ALU_Result[31:0] = {Binput[15:0],{16{1'b0}}};
        else if(Sftmd == 1)
            ALU_Result = Shift_Result;
        else
            ALU_Result = ALU_output_mux[31:0];    
    end

endmodule
