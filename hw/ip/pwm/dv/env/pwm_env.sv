// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class pwm_env extends cip_base_env #(
    .CFG_T              (pwm_env_cfg),
    .COV_T              (pwm_env_cov),
    .VIRTUAL_SEQUENCER_T(pwm_virtual_sequencer),
    .SCOREBOARD_T       (pwm_scoreboard)
  );
  `uvm_component_utils(pwm_env)
  `uvm_component_new

  function void build_phase(uvm_phase phase);
    int core_clk_freq_mhz;

    super.build_phase(phase);

    // check if pwm_vif generated
    if (!uvm_config_db#(virtual pwm_if)::get(this, "", "pwm_vif", cfg.pwm_vif)) begin
      `uvm_fatal(`gfn, "failed to get pwm_vif from uvm_config_db")
    end
    
    // generate core clock (must slower than bus clock)
    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "clk_rst_core_vif",
        cfg.clk_rst_core_vif)) begin
      `uvm_fatal(get_full_name(), "failed to get clk_rst_core_vif from uvm_config_db")
    end
    core_clk_freq_mhz = cfg.get_clk_core_freq(cfg.seq_cfg.pwm_core_clk_ratio);
    cfg.clk_rst_core_vif.set_freq_mhz(core_clk_freq_mhz);
  endfunction : build_phase

endclass : pwm_env
