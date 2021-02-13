// copyright damien pretet 2021
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module friscv_registers

    #(
        parameter XLEN = 32
    )(
        // clock and resets
        input  wire             aclk,
        input  wire             aresetn,
        input  wire             srst,
        // register source 1 for control unit
        input  wire  [5   -1:0] ctrl_rs1_addr,
        output logic [XLEN-1:0] ctrl_rs1_val,
        // register source 2 for control unit
        input  wire  [5   -1:0] ctrl_rs2_addr,
        output logic [XLEN-1:0] ctrl_rs2_val,
        // register source 1 for ALU
        input  wire  [5   -1:0] alu_rs1_addr,
        output logic [XLEN-1:0] alu_rs1_val,
        // register source 2 for ALU
        input  wire  [5   -1:0] alu_rs2_addr,
        output logic [XLEN-1:0] alu_rs2_val,
        // register destination
        input  wire             alu_rd_wr,
        input  wire  [5   -1:0] alu_rd_addr,
        input  wire  [XLEN-1:0] alu_rd_val,
        // registers output
        output logic [XLEN-1:0] x0,
        output logic [XLEN-1:0] x1,
        output logic [XLEN-1:0] x2,
        output logic [XLEN-1:0] x3,
        output logic [XLEN-1:0] x4,
        output logic [XLEN-1:0] x5,
        output logic [XLEN-1:0] x6,
        output logic [XLEN-1:0] x7,
        output logic [XLEN-1:0] x8,
        output logic [XLEN-1:0] x9,
        output logic [XLEN-1:0] x10,
        output logic [XLEN-1:0] x11,
        output logic [XLEN-1:0] x12,
        output logic [XLEN-1:0] x13,
        output logic [XLEN-1:0] x14,
        output logic [XLEN-1:0] x15,
        output logic [XLEN-1:0] x16,
        output logic [XLEN-1:0] x17,
        output logic [XLEN-1:0] x18,
        output logic [XLEN-1:0] x19,
        output logic [XLEN-1:0] x20,
        output logic [XLEN-1:0] x21,
        output logic [XLEN-1:0] x22,
        output logic [XLEN-1:0] x23,
        output logic [XLEN-1:0] x24,
        output logic [XLEN-1:0] x25,
        output logic [XLEN-1:0] x26,
        output logic [XLEN-1:0] x27,
        output logic [XLEN-1:0] x28,
        output logic [XLEN-1:0] x29,
        output logic [XLEN-1:0] x30,
        output logic [XLEN-1:0] x31
    );

    // ISA registers 0-31
    logic [XLEN-1:0] regs [2**5-1:0];

    // registers' write circuit
    always @ (posedge aclk or negedge aresetn) begin
        // asynchronous reset 
        if (aresetn == 1'b0) begin
            for (integer i=0;i<32;i=i+1) 
                regs[i] <= {XLEN{1'b0}};
        // synchronous reset
        end else if (srst) begin
            for (integer i=0;i<32;i=i+1) 
                regs[i] <= {XLEN{1'b0}};
        // write access to registers
        end else begin
            // register 0 is alwyas 0, can't be overwritten
            if (alu_rd_wr && alu_rd_addr == 5'h0) begin
                regs[alu_rd_addr] <= {XLEN{1'b0}};
            // registers 1-31
            end else if (alu_rd_wr && alu_rd_addr != 5'h0) begin
                regs[alu_rd_addr] <= alu_rd_val;
            end
        end
    end

    // register source 1 read circuit for control unit
    assign ctrl_rs1_val = regs[ctrl_rs1_addr];

    // register source 2 read circuit for control unit
    assign ctrl_rs2_val = regs[ctrl_rs2_addr];

    // register source 1 read circuit for ALU
    assign alu_rs1_val = regs[alu_rs1_addr];

    // register source 2 read circuit for ALU
    assign alu_rs2_val = regs[alu_rs2_addr];

    // registers value outputs for CSR and debug
    assign x0  = regs[ 0];
    assign x1  = regs[ 1];
    assign x2  = regs[ 2];
    assign x3  = regs[ 3];
    assign x4  = regs[ 4];
    assign x5  = regs[ 5];
    assign x6  = regs[ 6];
    assign x7  = regs[ 7];
    assign x8  = regs[ 8];
    assign x9  = regs[ 9];
    assign x10 = regs[10];
    assign x11 = regs[11];
    assign x12 = regs[12];
    assign x13 = regs[13];
    assign x14 = regs[14];
    assign x15 = regs[15];
    assign x16 = regs[16];
    assign x17 = regs[17];
    assign x18 = regs[18];
    assign x19 = regs[19];
    assign x20 = regs[20];
    assign x21 = regs[21];
    assign x22 = regs[22];
    assign x23 = regs[23];
    assign x24 = regs[24];
    assign x25 = regs[25];
    assign x26 = regs[26];
    assign x27 = regs[27];
    assign x28 = regs[28];
    assign x29 = regs[29];
    assign x30 = regs[30];
    assign x31 = regs[31];

endmodule

`resetall