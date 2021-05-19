// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

interface pwm_if #(
  parameter NumPwmChannels = 6
);
  import uvm_pkg::*;
  import pwm_env_pkg::*;

  // core signals
  logic clk_core;
  logic rst_core_n;
  logic [NumPwmChannels-1:0] pwm;

  // config variable
  pwm_status_e check_en;
  pwm_regs_t   pwm_regs;

  function automatic void reset();
    check_en = Disable;
    pwm_regs = '{default: '0};
  endfunction : reset

  function automatic void property_check(pwm_status_e status);
    check_en = status;
  endfunction : property_check

  //-------------------------------------------------
  // DEFINE ASSERTION
  //-------------------------------------------------
  // Assert that signal is an active-high pulse with pulse length of __nclk clock cycle
  `define PWM_ASSERT_PULSE_HIGH(__name, __sig, __nclk,
                           __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
    __name: assert property(@(posedge __clk) disable iff(__rst !== 0)                \
      $rose(__sig)[->__nclk] |=> always(!$isunknown(__sig) && $stable(__sig));       \
      else begin                                                                     \
        `ASSERT_ERROR(__name)                                                        \
      end

  // Assert that signal is an active-low pulse with pulse length of __nclk clock cycle
  `define PWM_ASSERT_PULSE_LOW(__name, __sig, __nclk,
                           __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
    __name: assert property(@(posedge __clk) disable iff(__rst !== 0)                \
      $fell(__sig)[->__nclk] |=> always(!$isunknown(__sig) && $stable(__sig));       \
      else begin                                                                     \
        `ASSERT_ERROR(__name)                                                        \
      end

  //-------------------------------------------------
  // EXECUTE ASSERTION
  //-------------------------------------------------
  // COUNTER checks (TODO: should these asssertions be done at RTL level)
  logic [26:0] dut_beat_ctr_q;
  logic [15:0] dut_phase_ctr_q;

  assign dut_beat_ctr_q  = tb.dut.u_pwm_core.beat_ctr_q;
  assign dut_phase_ctr_q = tb.dut.u_pwm_core.phase_ctr_q;

  //`ASSERT(BeatCntNonOverflow,  dut_beat_ctr_q  <= pwm_regs.beat_period,   clk_core, !rst_core_n)
  //`ASSERT(PhaseCntNonOverflow, dut_phase_ctr_q <= pwm_regs.pulse_period, clk_core, !rst_core_n)

  /*
  for (genvar i = 0; i < NumPwmChannels; i++) begin: check_pulse_at_high
    string assert_name;
    assert_name = $sformatf("CheckPulseAtHighChannel%0d", i);
    `PWM_ASSERT_PULSE_HIGH(assert_name, pwm[i], int'(pwm_regs.pulse_high[i]), clk_core, !rst_core_n)
  end

  for (genvar i = 0; i < NumPwmChannels; i++) begin : check_pulse_at_low
    string assert_name;
    assert_name = $sformatf("CheckPulseAtLowChannel%0d", i);
    `PWM_ASSERT_PULSE_LOW(assert_name, pwm[i], int'(pwm_regs.pulse_low[i]), clk_core, !rst_core_n)
  end
  */
endinterface : pwm_if

