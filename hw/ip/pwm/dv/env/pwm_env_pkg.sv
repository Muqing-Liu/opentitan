// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package pwm_env_pkg;
  // dep packages
  import uvm_pkg::*;
  import top_pkg::*;
  import dv_utils_pkg::*;
  import dv_lib_pkg::*;
  import tl_agent_pkg::*;
  import cip_base_pkg::*;
  import dv_base_reg_pkg::*;
  import csr_utils_pkg::*;
  import pwm_reg_pkg::*;
  import pwm_ral_pkg::*;

  parameter uint PWM_NUM_CHANNELS = pwm_reg_pkg::NOutputs;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters
  typedef enum int {
    Standard   = 0,
    Blinking   = 1,
    Heartbeat  = 2
  } pwm_mode_e;

  typedef enum bit {
    Enable     = 1'b1,
    Disable    = 1'b0
  } pwm_status_e;

  typedef struct {
    // cfg reg
    rand bit [3:0]    dc_resn;
    rand bit [26:0]   clk_div;
    // en reg
    rand bit [PWM_NUM_CHANNELS-1:0]         en;
    // invert multireg
    rand bit [PWM_NUM_CHANNELS-1:0]         invert;
    // param multireg
    rand bit [PWM_NUM_CHANNELS-1:0]         blink_en;
    rand bit [PWM_NUM_CHANNELS-1:0]         htbt_en;
    rand bit [PWM_NUM_CHANNELS-1:0][15:0]   phase_delay;
    // duty_cycle multireg
    rand bit [PWM_NUM_CHANNELS-1:0][15:0]   duty_cycle_a;
    rand bit [PWM_NUM_CHANNELS-1:0][15:0]   duty_cycle_b;
    // blink_param multireg
    rand bit [PWM_NUM_CHANNELS-1:0][15:0]   blink_param_x;
    rand bit [PWM_NUM_CHANNELS-1:0][15:0]   blink_param_y;
    // mode multireg
    rand pwm_mode_e [PWM_NUM_CHANNELS-1:0]  pwm_mode;
    rand bit [PWM_NUM_CHANNELS-1:0][31:0]   num_pulses;
    // derived params
    bit [31:0] beat_period;   // 2^(clk_div+1) core cycles
    bit [31:0] pulse_period;  // 2^(dc_resn+1)*beat_period core cycles
  } pwm_regs_t;

  // functions

  // package sources
  `include "pwm_seq_cfg.sv"
  `include "pwm_env_cfg.sv"
  `include "pwm_env_cov.sv"
  `include "pwm_virtual_sequencer.sv"
  `include "pwm_scoreboard.sv"
  `include "pwm_env.sv"
  `include "pwm_vseq_list.sv"

endpackage : pwm_env_pkg
