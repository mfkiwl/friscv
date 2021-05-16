// copyright damien pretet 2021
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

`include "friscv_h.sv"

module friscv_uart

    #(
        parameter ADDRW     = 16,
        parameter XLEN      = 32
    )(
        // clock & reset
        input  logic                        aclk,
        input  logic                        aresetn,
        input  logic                        srst,
        // APB Master
        input  logic                        mst_en,
        input  logic                        mst_wr,
        input  logic [ADDRW           -1:0] mst_addr,
        input  logic [XLEN            -1:0] mst_wdata,
        input  logic [XLEN/8          -1:0] mst_strb,
        output logic [XLEN            -1:0] mst_rdata,
        output logic                        mst_ready,
        // UART interface
        input  logic                        uart_rx,
        output logic                        uart_tx
    );

    assign uart_tx = 1'b0;

    always @ (posedge aclk or negedge aresetn) begin

        if (~aresetn) begin
            mst_rdata <= {XLEN{1'b0}};
            mst_ready <= 1'b0;
        end else if (srst) begin
            mst_rdata <= {XLEN{1'b0}};
            mst_ready <= 1'b0;
        end else begin
            // READY assertion
            if (mst_en && ~mst_ready) begin
                mst_ready <= 1'b1;
            end else begin
                mst_ready <= 1'b0;
            end
        end
    end

endmodule

`resetall
