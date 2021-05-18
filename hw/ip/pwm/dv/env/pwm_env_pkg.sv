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

  parameter PWM_NUM_CHANNELS = pwm_reg_pkg::NOutputs;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters

  // types
  // local types
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
    rand bit          en[PWM_NUM_CHANNELS];
    // invert multireg
    rand bit          invert[PWM_NUM_CHANNELS];
    // param multireg
    rand bit          blink_en[PWM_NUM_CHANNELS];
    rand bit          htbt_en[PWM_NUM_CHANNELS];
    rand bit [15:0]   phase_delay[PWM_NUM_CHANNELS];
    // duty_cycle multireg
    rand bit [15:0]   duty_cycle_a[PWM_NUM_CHANNELS];
    rand bit [15:0]   duty_cycle_b[PWM_NUM_CHANNELS];
    // blink_param multireg
    rand bit [15:0]   blink_param_x[PWM_NUM_CHANNELS];
    rand bit [15:0]   blink_param_y[PWM_NUM_CHANNELS];
    // mode multireg
    rand pwm_mode_e   pwm_mode[PWM_NUM_CHANNELS];
    rand int          pwm_num_pulses[PWM_NUM_CHANNELS];
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
