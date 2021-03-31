// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package pwm_agent_pkg;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import dv_lib_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters
  parameter uint PWM_NUM_CHANNELS = 6;

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

  // forward declare classes to allow typedefs below
  typedef class pwm_item;
  typedef class pwm_agent_cfg;

  // reuse dv_base_sequencer as is with the right parameter set
  typedef dv_base_sequencer #(.ITEM_T(pwm_item),
                              .CFG_T (pwm_agent_cfg)) pwm_sequencer;

  // functions

  // package sources
  `include "pwm_item.sv"
  `include "pwm_agent_cfg.sv"
  `include "pwm_agent_cov.sv"
  `include "pwm_driver.sv"
  `include "pwm_monitor.sv"
  `include "pwm_agent.sv"

endpackage: pwm_agent_pkg
