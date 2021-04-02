// copyright damien pretet 2021
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 100 ps
`default_nettype none

/// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
`include "friscv_h.sv"

module friscv_rv32i_control_testbench();

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
        $dumpfile("friscv_rv32i_control_testbench.vcd");
        $dumpvars(0, friscv_rv32i_control_testbench);
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
    end
    endtask

    `TEST_SUITE("FIRST_ONE")

    ///    Available macros:"
    ///
    ///    - `MSG("message"):       Print a raw white message
    ///    - `INFO("message"):      Print a blue message with INFO: prefix
    ///    - `SUCCESS("message"):   Print a green message if SUCCESS: prefix
    ///    - `WARNING("message"):   Print an orange message with WARNING: prefix and increment warning counter
    ///    - `CRITICAL("message"):  Print a purple message with CRITICAL: prefix and increment critical counter
    ///    - `ERROR("message"):     Print a red message with ERROR: prefix and increment error counter
    ///
    ///    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    ///    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    ///    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    ///    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    ///    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    ///    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    ///
    ///    Available flag:
    ///
    ///    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("Verify the ISA's opcodes")

        inst_rdata = 7'b0010111;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b1101111;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b1100111;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b1100011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0000000;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0000011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0110111;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0100011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0010011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b0110011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

        @(posedge aclk);

        inst_rdata = 7'b1110011;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b0));

    `UNIT_TEST_END

    `UNIT_TEST("Verify invalid opcodes lead to failure")

        inst_rdata = 7'b0000001;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b1), "should detect an issue");

        inst_rdata = 7'b0101001;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b1), "should detect an issue");

        inst_rdata = 7'b1111111;
        @(posedge aclk);
        `ASSERT((dut.inst_error==1'b1), "should detect an issue");

    `UNIT_TEST_END

    `UNIT_TEST("Check ALU FIFO is activated with valid opcodes")

        while (inst_en == 1'b0) @(posedge aclk);
        inst_ready = 1'b1;
        alu_ready = 1'b1;

        inst_rdata = 7'b0000011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b0110111;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b0100011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b0010011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b0110011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b0010011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

        inst_rdata = 7'b1110011;
        @(posedge aclk);
        `ASSERT((dut.alu_inst_wr==1'b1));

    `UNIT_TEST_END

    `UNIT_TEST("Check ALU FIFO contains the expected maximum instruction number")

        alu_ready = 0;

        while (inst_en == 1'b0) @(posedge aclk);

        inst_rdata = 7'b1110011;
        inst_ready = 1'b1;
        for (integer i=0; i<`ALU_FIFO_DEPTH; i=i+1) begin
            @(posedge aclk);
        end
        inst_ready = 1'b0;
        @(posedge aclk);
        `ASSERT((inst_en==1'b0), "Control unit shouldn't assert anymore inst_en");

    `UNIT_TEST_END

    `UNIT_TEST("Check control switching between ALU and system/branch/jump ops")

        `MSG("TODO 1: test with ALU and RAM ready");
        `MSG("TODO 2: test with ALU ready and RAM throttling");
        `MSG("TODO 3: test with ALU throttling and RAM ready");
        `MSG("TODO 3: test with ALU and RAM throttling");
        alu_ready = 1'b0;

    `UNIT_TEST_END
    
    `UNIT_TEST("Check AUIPC opcode")

        while (inst_en == 1'b0) @(posedge aclk);
        @(negedge aclk);

        `MSG("Zero move");
        inst_ready = 1'b1;
        inst_rdata = {25'b0, 7'b0010111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must keep 0 value");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h0));
        `ASSERT((dut.ctrl_rd_val == dut.pc));

        `MSG("move forward by 4 KB");
        inst_ready = 1'b1;
        inst_rdata = {20'h00001, 5'h0, 7'b0010111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h1000), "program counter must be 4KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h0));
        `ASSERT((dut.ctrl_rd_val == dut.pc));

        `MSG("move forward by 4 KB");
        inst_ready = 1'b1;
        inst_rdata = {20'h00001, 5'h3, 7'b0010111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h2000), "program counter must be 8KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h3));
        `ASSERT((dut.ctrl_rd_val == dut.pc));

        `MSG("move backward by 4 KB");
        inst_ready = 1'b1;
        inst_rdata = {20'hFFFFF, 5'h18, 7'b0010111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h1000), "program counter must be 4KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h18));
        `ASSERT((dut.ctrl_rd_val == dut.pc));

        #10;

    `UNIT_TEST_END

    `UNIT_TEST("Check JAL opcode")

        while (inst_en == 1'b0) @(posedge aclk);
        @(negedge aclk);

        `MSG("Jump +0, rd=x0");
        inst_ready = 1'b1;
        inst_rdata = {25'b0, 7'b1101111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must keep 0 value");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h0), "rd must target x0");

        `MSG("Jump +0, rd=x3");
        inst_ready = 1'b1;
        inst_rdata = {25'h3, 7'b1101111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must keep 0 value");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h3), "rd must target x3");

        `MSG("Jump +2048, rd=x5");
        inst_ready = 1'b1;
        inst_rdata = {{1'b0, 10'b0, 1'b1, 8'b0}, 5'h5, 7'b1101111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h800), "program counter must be 2KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h5));

    `UNIT_TEST_END

    `UNIT_TEST("Check JALR opcode")

        while (inst_en == 1'b0) @(posedge aclk);
        @(negedge aclk);

        `MSG("Jump +0, rd=x0");
        inst_ready = 1'b1;
        inst_rdata = {25'b0, 7'b1100111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must keep 0 value");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h0));

        `MSG("Jump +0, rd=x1");
        inst_ready = 1'b1;
        inst_rdata = {12'h0, 5'h0, 3'h0, 5'h1, 7'b1100111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must be 4KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h1), "rd must target x1");

        `MSG("Jump +0, rd=x2");
        inst_ready = 1'b1;
        inst_rdata = {12'h1, 5'h0, 3'h0, 5'h2, 7'b1100111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h0), "program counter must be 4KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h2), "rd must target x2");

        `MSG("Jump +0, rd=x2");
        inst_ready = 1'b1;
        inst_rdata = {12'h2, 5'h0, 3'h0, 5'h2, 7'b1100111};
        @(negedge aclk);
        `ASSERT((dut.pc == 32'h2), "program counter must be 4KB");
        `ASSERT((dut.ctrl_rd_wr == 1'b1), "rd is not under write");
        `ASSERT((dut.ctrl_rd_addr == 32'h2), "rd must target x2");

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
