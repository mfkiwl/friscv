`timescale 1 ns / 1 ps
`default_nettype none

module friscv_stats

    #(
    parameter XLEN = 32
    )(
    input  logic        aclk,
    input  logic        aresetn,
    input  logic        srst,
    input  logic        enable,
    input  logic        inst_en,
    input  logic        inst_ready,
    output logic        debug
    );

    logic [XLEN-1:0] uptime;
    logic [XLEN-1:0] inst_wait;
    logic [XLEN-1:0] inst_served;

    always @ (posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            uptime <= {XLEN{1'b0}};
        end else if (srst) begin
            uptime <= {XLEN{1'b0}};
        end else begin
            uptime <= uptime + 1;
        end
    end

    always @ (posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            inst_wait <= {XLEN{1'b0}};
        end else if (srst) begin
            inst_wait <= {XLEN{1'b0}};
        end else begin
            if (inst_en && ~inst_ready)
                inst_wait <= inst_wait + 1;
        end
    end

    always @ (posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            inst_served <= {XLEN{1'b0}};
        end else if (srst) begin
            inst_served <= {XLEN{1'b0}};
        end else begin
            if (inst_en && inst_ready)
                inst_served <= inst_served + 1;
        end
    end

    assign debug = 1'b0;

endmodule

`resetall
