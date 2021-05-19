// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class pwm_env_cfg extends cip_base_env_cfg #(.RAL_T(pwm_reg_block));
  
  // flag indicates pwm stop
  bit pwm_stop_all_channels;

  // seq_cfg
  pwm_seq_cfg seq_cfg;

  // pwm virtual interface
  virtual pwm_if pwm_vif;

  // clk_rst_core_if
  virtual clk_rst_if clk_rst_core_vif;

  `uvm_object_utils_begin(pwm_env_cfg)
  `uvm_object_utils_end

  `uvm_object_new

  virtual function void initialize(bit [31:0] csr_base_addr = '1);
    super.initialize(csr_base_addr);

    // create seq_cfg
    seq_cfg = pwm_seq_cfg::type_id::create("seq_cfg");
  endfunction

  // clk_core_freq_mhz is assigned by
  // - a slower frequency in range [bus_clock*scale : bus_clock] if en_random is set (scale <= 1)
  // - bus_clock frequency otherwise
  virtual function int get_clk_core_freq(real core_clk_ratio, uint en_random = 1);
    int clk_core_min, clk_core_max, clk_core_mhz;

    if (en_random) begin
      `DV_CHECK_LE(core_clk_ratio, 1)
      clk_core_max = clk_rst_vif.clk_freq_mhz;
      clk_core_min = int'(core_clk_ratio * real'(clk_rst_vif.clk_freq_mhz));
      clk_core_mhz = $urandom_range(clk_core_min, clk_core_max);
    end else begin
      clk_core_mhz = clk_rst_vif.clk_freq_mhz;
    end
    `uvm_info(`gfn, $sformatf("clk_bus %0d Mhz, clk_core %0d Mhz",
        clk_rst_vif.clk_freq_mhz, clk_core_mhz), UVM_DEBUG)
    `DV_CHECK_LE(clk_core_mhz, clk_rst_vif.clk_freq_mhz)

    return clk_core_mhz;
  endfunction : get_clk_core_freq

  virtual function void print_pwm_regs(pwm_regs_t regs, int channel, bit en_print = 1'b1);
    if (en_print) begin
      string str;
      str = $sformatf("\n>>> Channel %0d configuration", channel);
      str = {str, $sformatf("\n  pwm_mode        %s",  regs.pwm_mode[channel].name())};
      str = {str, $sformatf("\n  clk_div         %0d", regs.clk_div)};
      str = {str, $sformatf("\n  dc_resn         %0d", regs.dc_resn)};
      str = {str, $sformatf("\n  num_pulses      %0d", regs.num_pulses)};
      str = {str, $sformatf("\n  beat_period     %0d", regs.beat_period)};
      str = {str, $sformatf("\n  pulse_period    %0d", regs.pulse_period)};
      str = {str, $sformatf("\n  pwm_en          %s",  regs.en[channel] ? "Enable" : "Disable")};
      str = {str, $sformatf("\n  invert          %b",  regs.invert[channel])};
      str = {str, $sformatf("\n  phase_delay     %0d", regs.phase_delay[channel])};
      str = {str, $sformatf("\n  duty_cycle_A    %0d", regs.duty_cycle_a[channel])};
      str = {str, $sformatf("\n  duty_cycle_B    %0d", regs.duty_cycle_b[channel])};
      str = {str, $sformatf("\n  blink_param_X   %0d", regs.blink_param_x[channel])};
      str = {str, $sformatf("\n  blink_param_Y   %0d", regs.blink_param_y[channel])};
      `uvm_info(`gfn, $sformatf("%s", str), UVM_LOW)
    end
  endfunction : print_pwm_regs

endclass : pwm_env_cfg
