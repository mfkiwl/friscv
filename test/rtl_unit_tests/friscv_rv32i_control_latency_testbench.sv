// copyright damien pretet 2021
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 100 ps
`default_nettype none

/// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
`include "friscv_h.sv"

module friscv_rv32i_control_latency_testbench();

    `SVUT_SETUP

    parameter ADDRW     = 16;
    parameter BOOT_ADDR =  0;
    parameter XLEN      = 32;

    logic                      aclk;
    logic                      aresetn;
    logic                      srst;
    logic                      inst_en;
    logic [ADDRW        -1:0]  inst_addr;
    logic [XLEN         -1:0]  inst_rdata;
    logic                      inst_ready;
    logic                      alu_en;
    logic                      alu_ready;
    logic [`ALU_INSTBUS_W-1:0] alu_instbus;
    logic [5             -1:0] ctrl_rs1_addr;
    logic [XLEN          -1:0] ctrl_rs1_val;
    logic [5             -1:0] ctrl_rs2_addr;
    logic [XLEN          -1:0] ctrl_rs2_val;
    logic                      ctrl_rd_wr;
    logic [5             -1:0] ctrl_rd_addr;
    logic [XLEN          -1:0] ctrl_rd_val;

    logic [32            -1:0] prev_pc;
    logic [32            -1:0] next_pc;
    logic [12            -1:0] offset;
    string                     msg;

    friscv_rv32i_control
    #(
    ADDRW,
    BOOT_ADDR,
    XLEN
    )
    dut
    (
    aclk,
    aresetn,
    srst,
    inst_en,
    inst_addr,
    inst_rdata,
    inst_ready,
    alu_en,
    alu_ready,
    alu_instbus,
    ctrl_rs1_addr,
    ctrl_rs1_val,
    ctrl_rs2_addr,
    ctrl_rs2_val,
    ctrl_rd_wr,
    ctrl_rd_addr,
    ctrl_rd_val
    );

    /// An example to create a clock for icarus:
    initial aclk = 0;
    always #2 aclk = ~aclk;

    /// An example to dump data for visualization
    initial begin
        $dumpfile("friscv_rv32i_control_latency_testbench.vcd");
        $dumpvars(0, friscv_rv32i_control_latency_testbench);
    end

    task setup(msg="");
    begin
        aresetn = 1'b0;
        srst = 1'b0;
        alu_ready = 1'b0;
        inst_rdata = {XLEN{1'b0}};
        inst_ready = 1'b0;
        ctrl_rs1_val <= {XLEN{1'b0}};
        ctrl_rs2_val <= {XLEN{1'b0}};
        #10;
        aresetn = 1'b1;
    end
    endtask

    task teardown(msg="");
    begin
        /// teardown() runs when a test ends
        #10;
    end
    endtask

    `TEST_SUITE("Control Testsuite")

    `UNIT_TEST("Fill FIFO fully then check instructions are well passed");

        alu_ready = 0;

        while (inst_en == 1'b0) @(posedge aclk);

        inst_ready = 1'b1;
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            inst_rdata = {17'b0, i[2:0], 5'b0, 7'b0000011};
            @(posedge aclk);
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            inst_rdata = {17'b0, i[2:0], 5'b0, 7'b0100011};
            @(posedge aclk);
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            inst_rdata = {17'b0, i[2:0], 5'b0, 7'b0010011};
            @(posedge aclk);
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            inst_rdata = {17'b0, i[2:0], 5'b0, 7'b0110011};
            @(posedge aclk);
        end

        inst_ready = 1'b0;
        @(posedge aclk);
        `ASSERT((inst_en==1'b0), "Control unit shouldn't assert anymore inst_en");

            // msg = {"expect funct3=", i[2:0], " opcode=", 7'b0000011};
        @(negedge aclk);
        alu_ready = 1;
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            @(negedge aclk);
            `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0000011));
            `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == i[2:0]));
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            @(negedge aclk);
            `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0100011));
            `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == i[2:0]));
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            @(negedge aclk);
            `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0010011));
            `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == i[2:0]));
        end
        for (integer i=0; i<`ALU_FIFO_DEPTH/4; i=i+1) begin
            @(negedge aclk);
            `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0110011));
            `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == i[2:0]));
        end

    `UNIT_TEST_END

    `UNIT_TEST("Fill FIFO fully then check instructions are well buffered");

        alu_ready = 0;

        while (inst_en == 1'b0) @(posedge aclk);

        inst_ready = 1'b1;
        for (integer i=0; i<`ALU_FIFO_DEPTH; i=i+1) begin
            inst_rdata = {17'b0, i[2:0], 5'b0, 7'b0000011};
            @(posedge aclk);
        end

        inst_rdata = {17'b0, 3'h6, 5'b0, 7'b0000011};
        @(posedge aclk);
        `ASSERT((inst_en==1'b0), "Control unit shouldn't assert anymore inst_en");

        inst_ready = 1'b0;
        @(posedge aclk);
        `ASSERT((dut.load_stored==1'b1), "control has to store the last instruction");
        `ASSERT(dut.stored_inst== inst_rdata, "control didn't store correctly the last instruction");

        @(negedge aclk);
        alu_ready = 1;
        for (integer i=0; i<`ALU_FIFO_DEPTH; i=i+1) begin
            @(negedge aclk);
            `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0000011), "OPCODE received is wrong");
            `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == i[2:0]), "FUNCT3 received is wrong");
        end

        @(negedge aclk);
        `ASSERT((alu_instbus[`OPCODE+:`OPCODE_W] == 7'b0000011), "Last OPCODE sent during en=0 is wrong");
        `ASSERT((alu_instbus[`FUNCT3+:`FUNCT3_W] == 3'h6), "Last FUNCT3 sent during en=0 is wrong");

    `UNIT_TEST_END

    `UNIT_TEST("Check control switching between ALU and system/branch/jump ops")

        `MSG("TODO 1: test with ALU and RAM ready");
        `MSG("TODO 2: test with ALU ready and RAM throttling");
        `MSG("TODO 3: test with ALU throttling and RAM ready");
        `MSG("TODO 3: test with ALU and RAM throttling");
        alu_ready = 1'b0;

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
