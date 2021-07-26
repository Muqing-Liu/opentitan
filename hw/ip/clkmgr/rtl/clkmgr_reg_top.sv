// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module clkmgr_reg_top (
  input clk_i,
  input rst_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output clkmgr_reg_pkg::clkmgr_reg2hw_t reg2hw, // Write
  input  clkmgr_reg_pkg::clkmgr_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o,

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import clkmgr_reg_pkg::* ;

  localparam int AW = 4;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;

  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i,
    .err_o(intg_err)
  );

  logic intg_err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      intg_err_q <= '0;
    end else if (intg_err) begin
      intg_err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = intg_err_q | intg_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o
  );

  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i,
    .rst_ni,

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic clk_enables_we;
  logic clk_enables_clk_fixed_peri_en_qs;
  logic clk_enables_clk_fixed_peri_en_wd;
  logic clk_enables_clk_usb_48mhz_peri_en_qs;
  logic clk_enables_clk_usb_48mhz_peri_en_wd;
  logic clk_hints_we;
  logic clk_hints_clk_main_aes_hint_qs;
  logic clk_hints_clk_main_aes_hint_wd;
  logic clk_hints_clk_main_hmac_hint_qs;
  logic clk_hints_clk_main_hmac_hint_wd;
  logic clk_hints_status_clk_main_aes_val_qs;
  logic clk_hints_status_clk_main_hmac_val_qs;

  // Register instances
  // R[clk_enables]: V(False)

  //   F[clk_fixed_peri_en]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1)
  ) u_clk_enables_clk_fixed_peri_en (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (clk_enables_we),
    .wd     (clk_enables_clk_fixed_peri_en_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.clk_enables.clk_fixed_peri_en.q),

    // to register interface (read)
    .qs     (clk_enables_clk_fixed_peri_en_qs)
  );


  //   F[clk_usb_48mhz_peri_en]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1)
  ) u_clk_enables_clk_usb_48mhz_peri_en (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (clk_enables_we),
    .wd     (clk_enables_clk_usb_48mhz_peri_en_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.clk_enables.clk_usb_48mhz_peri_en.q),

    // to register interface (read)
    .qs     (clk_enables_clk_usb_48mhz_peri_en_qs)
  );


  // R[clk_hints]: V(False)

  //   F[clk_main_aes_hint]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1)
  ) u_clk_hints_clk_main_aes_hint (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (clk_hints_we),
    .wd     (clk_hints_clk_main_aes_hint_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.clk_hints.clk_main_aes_hint.q),

    // to register interface (read)
    .qs     (clk_hints_clk_main_aes_hint_qs)
  );


  //   F[clk_main_hmac_hint]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1)
  ) u_clk_hints_clk_main_hmac_hint (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (clk_hints_we),
    .wd     (clk_hints_clk_main_hmac_hint_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.clk_hints.clk_main_hmac_hint.q),

    // to register interface (read)
    .qs     (clk_hints_clk_main_hmac_hint_qs)
  );


  // R[clk_hints_status]: V(False)

  //   F[clk_main_aes_val]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h1)
  ) u_clk_hints_status_clk_main_aes_val (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.clk_hints_status.clk_main_aes_val.de),
    .d      (hw2reg.clk_hints_status.clk_main_aes_val.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (clk_hints_status_clk_main_aes_val_qs)
  );


  //   F[clk_main_hmac_val]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h1)
  ) u_clk_hints_status_clk_main_hmac_val (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.clk_hints_status.clk_main_hmac_val.de),
    .d      (hw2reg.clk_hints_status.clk_main_hmac_val.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (clk_hints_status_clk_main_hmac_val_qs)
  );




  logic [2:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == CLKMGR_CLK_ENABLES_OFFSET);
    addr_hit[1] = (reg_addr == CLKMGR_CLK_HINTS_OFFSET);
    addr_hit[2] = (reg_addr == CLKMGR_CLK_HINTS_STATUS_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(CLKMGR_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(CLKMGR_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(CLKMGR_PERMIT[2] & ~reg_be)))));
  end
  assign clk_enables_we = addr_hit[0] & reg_we & !reg_error;

  assign clk_enables_clk_fixed_peri_en_wd = reg_wdata[0];

  assign clk_enables_clk_usb_48mhz_peri_en_wd = reg_wdata[1];
  assign clk_hints_we = addr_hit[1] & reg_we & !reg_error;

  assign clk_hints_clk_main_aes_hint_wd = reg_wdata[0];

  assign clk_hints_clk_main_hmac_hint_wd = reg_wdata[1];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = clk_enables_clk_fixed_peri_en_qs;
        reg_rdata_next[1] = clk_enables_clk_usb_48mhz_peri_en_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = clk_hints_clk_main_aes_hint_qs;
        reg_rdata_next[1] = clk_hints_clk_main_hmac_hint_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = clk_hints_status_clk_main_aes_val_qs;
        reg_rdata_next[1] = clk_hints_status_clk_main_hmac_val_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we)
  `ASSERT_PULSE(rePulse, reg_re)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o.d_valid)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit))

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule
