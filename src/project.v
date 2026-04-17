/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tdc_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};


  localparam TDC_SIZE = 4;

  wire [TDC_SIZE:0]   l_delay_stages; 
  wire [TDC_SIZE-1:0] l_internal_delay; 
  reg  [TDC_SIZE-1:0] l_captured_signal;

  assign l_delay_stages[0] = ui_in[0];

  genvar i;
  generate
    for (i=0; i< TDC_SIZE; i=i+1) begin
      sky130_fd_sc_hd__inv_2 dly1 ( .A(l_delay_stages[i]),   .Y(l_internal_delay[i]) );
      sky130_fd_sc_hd__inv_2 dly2 ( .A(l_internal_delay[i]), .Y(l_delay_stages[i+1]) );
    end
  endgenerate

  always @(posedge clk) begin
    if(!rst_n) begin
      l_captured_signal <= 0;
    end else begin
      l_captured_signal <= l_delay_stages[TDC_SIZE:1];
    end
  end

  assign uo_out = {4'd0, l_captured_signal};

endmodule
