/// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"

`timescale 1 ns / 100 ps

module friscv_io_interfaces_testbench();

    `SVUT_SETUP

    parameter ADDRW     = 16;
    parameter XLEN      = 32;
    parameter BASE_ADDR = 0;
    parameter SLV0_ADDR = 0;
    parameter SLV0_SIZE = 8;
    parameter SLV1_ADDR = 1024;
    parameter SLV1_SIZE = 1024;

    logic               aclk;
    logic               aresetn;
    logic               srst;
    logic               mst_en;
    logic               mst_wr;
    logic [ADDRW  -1:0] mst_addr;
    logic [XLEN   -1:0] mst_wdata;
    logic [XLEN/8 -1:0] mst_strb;
    logic [XLEN   -1:0] mst_rdata;
    logic               mst_ready;
    logic [XLEN   -1:0] gpio_in;
    logic [XLEN   -1:0] gpio_out;
    logic               uart_rx;
    logic               uart_tx;

    friscv_io_interfaces
    #(
    ADDRW,
    XLEN,
    BASE_ADDR,
    SLV0_ADDR,
    SLV0_SIZE,
    SLV1_ADDR,
    SLV1_SIZE
    )
    dut
    (
    aclk,
    aresetn,
    srst,
    mst_en,
    mst_wr,
    mst_addr,
    mst_wdata,
    mst_strb,
    mst_rdata,
    mst_ready,
    gpio_in,
    gpio_out,
    uart_rx,
    uart_tx
    );

    /// to create a clock:
    /// initial aclk = 0;
    /// always #2 aclk = ~aclk;

    /// to dump data for visualization:
    /// initial begin
    ///     $dumpfile("waveform.vcd");
    ///     $dumpvars(0, friscv_io_interfaces_testbench);
    /// end

    task setup(msg="");
    begin
        /// setup() runs when a test begins
    end
    endtask

    task teardown(msg="");
    begin
        /// teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("SUITE_NAME")

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

    `UNIT_TEST("TEST_NAME")

        /// Describe here the testcase scenario
        ///
        /// Because SVUT uses long nested macros, it's possible
        /// some local variable declaration leads to compilation issue.
        /// You should declare your variables after the IOs declaration to avoid that.

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
