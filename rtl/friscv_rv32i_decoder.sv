// copyright damien pretet 2021
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

module friscv_rv32i_decoder

    #(
        parameter XLEN = 32
    )(
        input  logic [XLEN -1:0] instruction,
        output logic [7    -1:0] opcode,
        output logic [3    -1:0] funct3,
        output logic [7    -1:0] funct7,
        output logic [5    -1:0] rs1,
        output logic [5    -1:0] rs2,
        output logic [5    -1:0] rd,
        output logic [5    -1:0] zimm,
        output logic [12   -1:0] imm12,
        output logic [20   -1:0] imm20,
        output logic [12   -1:0] csr,
        output logic [6    -1:0] shamt,
        output logic [2    -1:0] fence,
        output logic             lui,
        output logic             auipc,
        output logic             jal,
        output logic             jalr,
        output logic             branching,
        output logic [3    -1:0] env,
        output logic             processing,
        output logic             inst_error,
        output logic [4    -1:0] pred,
        output logic [4    -1:0] succ
    );

    always @ (*) begin

        // First instruction part to filter the type
        case (instruction[6:0])

            // LUI
            7'b0110111: begin
                lui = 1'b1;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = instruction[31:12];
            end

            // AUIPC
            7'b0010111: begin
                lui = 1'b0;
                auipc = 1'b1;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = instruction[31:12];
            end

            // JAL
            7'b1101111: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b1;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = {instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[21+:10]};
            end

            // JALR
            7'b1100111: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b1;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = instruction[20+:12];
                imm20 = 20'b0;
            end

            // Branch
            7'b1100011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b1;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = {instruction[31],
                         instruction[7],
                         instruction[25+:6],
                         instruction[8+:4]};
                imm20 = 20'b0;
            end

            // Emvironment
            // - ecall  : env[0]
            // - ebreak : env[1]
            // - CSR    : env[2]
            7'b1110011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                if (instruction[14:12]==3'b000) begin
                    // ebreak
                    if (instruction[20]==1'b1) begin
                        env = 3'b010;
                    // ecall
                    end else begin
                        env = 3'b001;
                    end
                // CSR
                end else begin
                    env = 3'b100;
                end
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = 20'b0;
            end

            // Fence
            7'b0001111: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                // fence.i
                if (instruction[12]) begin
                    fence = 2'b10;
                // fence
                end else begin
                    fence = 2'b01;
                end
                processing = 1'b0;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = 20'b0;
            end

            // Load
            7'b0000011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b1;
                inst_error = 1'b0;
                imm12 = instruction[20+:12];
                imm20 = 20'b0;
            end

            // Store
            7'b0100011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b1;
                inst_error = 1'b0;
                imm12 = {instruction[25+:7], instruction[7+:5]};
                imm20 = 20'b0;
            end

            // Arithmetic
            7'b0010011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b1;
                inst_error = 1'b0;
                imm12 = instruction[20+:12];
                imm20 = 20'b0;
            end

            // Arithmetic
            7'b0110011: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b1;
                inst_error = 1'b0;
                imm12 = 12'b0;
                imm20 = 20'b0;
            end

            // All others, unsupported/undefined
            default: begin
                lui = 1'b0;
                auipc = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                branching = 1'b0;
                env = 3'b0;
                fence = 2'b0;
                processing = 1'b0;
                inst_error = 1'b1;
                imm12 = 12'b0;
                imm20 = 20'b0;
            end

        endcase

        opcode = instruction[6:0];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd = instruction[11:7];
        zimm = instruction[19:15];
        csr = instruction[31:20];
        shamt = instruction[25:20];
        pred = instruction[23:20];
        succ = instruction[27:24];

    end

endmodule

`resetall
