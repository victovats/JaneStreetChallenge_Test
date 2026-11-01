/*
 * Copyright (c) 2026 victovats
 * SPDX-License-Identifier: Apache-2.0
 *
 * Simple registered 8x7 unsigned multiplier for exercising the LibreLane flow.
 *
 *   A        = ui_in[7:0]     (8-bit operand)
 *   B        = uio_in[6:0]    (7-bit operand)
 *   byte_sel = uio_in[7]      (0 = low byte of product, 1 = high byte)
 *
 * The 15-bit product A*B is registered on every rising clock edge.
 * uo_out shows the selected byte of the registered product, so the result
 * appears one clock cycle after the inputs are applied.
 */

`default_nettype none

module tt_um_victovats_multiplier (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [7:0] a        = ui_in;
  wire [6:0] b        = uio_in[6:0];
  wire       byte_sel = uio_in[7];

  reg [14:0] product;
  reg        sel_q;

  always @(posedge clk) begin
    if (!rst_n) begin
      product <= 15'd0;
      sel_q   <= 1'b0;
    end else begin
      product <= a * b;
      sel_q   <= byte_sel;
    end
  end

  assign uo_out  = sel_q ? {1'b0, product[14:8]} : product[7:0];
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;  // all bidirectional pins are inputs

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
