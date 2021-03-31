// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class pwm_base_vseq extends cip_base_vseq #(
  .RAL_T              (pwm_reg_block),
  .CFG_T              (pwm_env_cfg),
  .COV_T              (pwm_env_cov),
  .VIRTUAL_SEQUENCER_T(pwm_virtual_sequencer)
);
  `uvm_object_utils(pwm_base_vseq)
  `uvm_object_new

  // random variables
  rand uint          num_runs;
  rand uint          num_pulses;
  rand bit [26:0]    clk_div;
  rand bit [3:0]     dc_resn;
  // pwm channel configs
  rand pwm_regs_t    pwm_regs;

  semaphore key_en_reg     =  new(1);
  semaphore key_invert_reg =  new(1);

  // constraints
  constraint num_trans_c {
    num_trans inside {[cfg.seq_cfg.pwm_min_num_trans : cfg.seq_cfg.pwm_max_num_trans]};
  }
  constraint num_runs_c {
    num_runs inside {[cfg.seq_cfg.pwm_min_num_runs : cfg.seq_cfg.pwm_max_num_runs]};
  }

  constraint pwm_regs_c {
    // constraints for single regs
    pwm_regs.dc_resn inside {[cfg.seq_cfg.pwm_min_dc_resn :
                              cfg.seq_cfg.pwm_max_dc_resn]};
    pwm_regs.clk_div inside {[cfg.seq_cfg.pwm_min_clk_div :
                              cfg.seq_cfg.pwm_max_clk_div]};

    // constraints for multi regs
    foreach (pwm_regs.en[i]) {
      pwm_regs.en[i] dist {1'b0 :/ 1, 1'b1 :/ 1};
    }
    foreach (pwm_regs.invert[i]) {
      pwm_regs.invert[i] dist {1'b0 :/ 1, 1'b1 :/ 1};
    }
    foreach (pwm_regs.phase_delay[i]) {
      pwm_regs.phase_delay[i]   inside {[cfg.seq_cfg.pwm_min_phase_delay :
                                         cfg.seq_cfg.pwm_max_phase_delay]};
    }
    foreach (pwm_regs.blink_param_x[i]) {
      pwm_regs.blink_param_x[i] inside {[cfg.seq_cfg.pwm_min_blink_param :
                                         cfg.seq_cfg.pwm_max_blink_param]};
    }
    foreach (pwm_regs.blink_param_y[i]) {
      pwm_regs.blink_param_y[i] inside {[cfg.seq_cfg.pwm_min_blink_param :
                                         cfg.seq_cfg.pwm_max_blink_param]};
    }
    foreach (pwm_regs.duty_cycle_a[i]) {
      pwm_regs.duty_cycle_a[i]  inside {[cfg.seq_cfg.pwm_min_duty_cycle :
                                         cfg.seq_cfg.pwm_max_duty_cycle]};
    }
    foreach (pwm_regs.duty_cycle_b[i]) {
      pwm_regs.duty_cycle_b[i]  inside {[cfg.seq_cfg.pwm_min_duty_cycle :
                                         cfg.seq_cfg.pwm_max_duty_cycle]};
    }
    // TODO: temporaly set to Standard mode for debug purpose
    foreach (pwm_regs.pwm_mode[i]) {
      pwm_regs.pwm_mode[i] dist {Standard :/ 1, Blinking :/ 0, Heartbeat :/ 0};
    }
    foreach (pwm_regs.pwm_num_pulses[i]) {
      pwm_regs.pwm_num_pulses[i] inside {[cfg.seq_cfg.pwm_min_num_pulses :
                                          cfg.seq_cfg.pwm_max_num_pulses]};
    }
  }

  //================================
  virtual task pre_start();
    cfg.m_pwm_agent_cfg.en_monitor = cfg.en_scb;
    `uvm_info(`gfn, $sformatf("\n--> %s monitor and scoreboard",
        cfg.en_scb ? "enable" : "disable"), UVM_LOW)
    num_runs.rand_mode(0);
    // unset to disable intr test because pwm does not have intr pins
    do_clear_all_interrupts = 1'b0;
    super.pre_start();
  endtask : pre_start

  virtual task initialization();
    wait(cfg.clk_rst_vif.rst_n && cfg.clk_rst_core_vif.rst_n);
    `uvm_info(`gfn, "\n  base vseq: out of reset", UVM_LOW)
    csr_spinwait(.ptr(ral.regen), .exp_data(1'b1));
    `uvm_info(`gfn, "\n  base vseq: clear regen to allow programming channel registers", UVM_LOW)
  endtask : initialization

  //=== tasks for programming single registers
  // clear regen after initialization to allow programming registers
  virtual task program_pwm_regen_reg(pwm_status_e status);
    csr_wr(.ptr(ral.regen), .value(status));
    `uvm_info(`gfn, $sformatf("\n  base vseq: program regen %s", status.name()), UVM_LOW)
  endtask : program_pwm_regen_reg

  virtual task program_pwm_cfg_reg();
    ral.cfg.cntr_en.set(1'b0);      // reset counting
    ral.cfg.clk_div.set(pwm_regs.clk_div);
    ral.cfg.dc_resn.set(pwm_regs.dc_resn);
    ral.cfg.cntr_en.set(1'b1);      // start counting
    csr_update(ral.cfg);
    `uvm_info(`gfn, "\n  base vseq: clear counter and program clk_div and dc_resn", UVM_LOW)
  endtask : program_pwm_cfg_reg

  //=== tasks for programming multi registers
  virtual task program_pwm_en_regs(pwm_status_e status, int channel);
    key_en_reg.get(1);
    set_dv_base_reg_field_by_name("pwm_en", "en", pwm_regs.en[channel], channel);
    `uvm_info(`gfn, $sformatf("\n  base vseq: %s channel %0d",
        status.name(), channel), UVM_LOW)
    key_en_reg.put(1);
  endtask : program_pwm_en_regs

  virtual task program_pwm_invert_regs(int channel);
    key_invert_reg.get(1);
    set_dv_base_reg_field_by_name("invert", "invert", pwm_regs.invert[channel], channel);
    key_invert_reg.put(1);
  endtask : program_pwm_invert_regs

  virtual task program_pwm_duty_cycle_regs(int channel);
    dv_base_reg base_reg = get_dv_base_reg_by_name("duty_cycle", channel);

    // set reg fields but not update
    set_dv_base_reg_field_by_name("duty_cycle", "a",
      pwm_regs.duty_cycle_a[channel], channel, channel, 1'b0);
    set_dv_base_reg_field_by_name("duty_cycle", "b",
      pwm_regs.duty_cycle_b[channel], channel, channel, 1'b0);
    // update fields in same cycle
    csr_update(base_reg);
  endtask : program_pwm_duty_cycle_regs

  virtual task program_pwm_blink_param_regs(int channel);
    dv_base_reg base_reg = get_dv_base_reg_by_name("blink_param", channel);
    // set reg fields but not update
    set_dv_base_reg_field_by_name("blink_param", "x",
        pwm_regs.blink_param_x[channel], channel, channel, 1'b0);
    set_dv_base_reg_field_by_name("blink_param", "y",
        pwm_regs.blink_param_y[channel], channel, channel, 1'b0);
    // update fields in same cycle
    csr_update(base_reg);
  endtask : program_pwm_blink_param_regs

  // override apply_reset to handle reset for bus and core domain
  virtual task apply_reset(string kind = "HARD");
    fork
      if (kind == "HARD" || kind == "TL_IF") begin
        super.apply_reset("HARD");
      end
      if (kind == "HARD" || kind == "CORE_IF") begin
        cfg.clk_rst_core_vif.apply_reset();
      end
    join
  endtask : apply_reset

  // phase alignment for resets signal of core and bus domain
  virtual task do_phase_align_reset(bit do_phase_align = 1'b0);
    if (do_phase_align) begin
      fork
        cfg.clk_rst_vif.wait_clks($urandom_range(5, 10));
        cfg.clk_rst_core_vif.wait_clks($urandom_range(5, 10));
      join
    end
  endtask : do_phase_align_reset

  // functions
  virtual function void update_agent_config(int channel, bit en_print = 1'b1);
    // single regs
    cfg.m_pwm_agent_cfg.pwm_regs.dc_resn = pwm_regs.dc_resn;
    cfg.m_pwm_agent_cfg.pwm_regs.clk_div = pwm_regs.clk_div;
    // multi regs
    cfg.m_pwm_agent_cfg.pwm_regs.pwm_mode[channel]       = pwm_regs.pwm_mode[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.pwm_num_pulses[channel] = pwm_regs.pwm_num_pulses[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.invert[channel]         = pwm_regs.invert[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.blink_en[channel]       = pwm_regs.blink_en[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.htbt_en[channel]        = pwm_regs.htbt_en[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.phase_delay[channel]    = pwm_regs.phase_delay[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.duty_cycle_a[channel]   = pwm_regs.duty_cycle_a[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.duty_cycle_b[channel]   = pwm_regs.duty_cycle_b[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.blink_param_x[channel]  = pwm_regs.blink_param_x[channel];
    cfg.m_pwm_agent_cfg.pwm_regs.blink_param_y[channel]  = pwm_regs.blink_param_y[channel];
    // print agent config
    print_pwm_regs(cfg.m_pwm_agent_cfg.pwm_regs, channel, en_print);
  endfunction : update_agent_config

  // set field of reg/mreg using name and index, need to call csr_update after setting
  virtual task set_dv_base_reg_field_by_name(string  csr_name,
                                             string  field_name,
                                             uint    field_value,
                                             int     field_idx = -1,
                                             int     csr_idx = -1,
                                             bit     update  = 1'b1);
    string        reg_name;
    uvm_reg_field reg_field;
    dv_base_reg   base_reg;

    base_reg = get_dv_base_reg_by_name(csr_name, csr_idx);
    reg_name = (field_idx == -1) ? field_name : $sformatf("%s_%0d", field_name, field_idx);
    reg_field = base_reg.get_field_by_name(reg_name);
    `DV_CHECK_NE_FATAL(reg_field, null, reg_name)
    reg_field.set(field_value);
    if (update) csr_update(base_reg);
  endtask : set_dv_base_reg_field_by_name

  virtual function void print_pwm_regs(pwm_regs_t regs, int channel, bit en_print = 1'b1);
    if (en_print) begin
      string str;
      str = $sformatf("\n>>> Channel %0d configuration", channel);
      str = {str, $sformatf("\n  pwm_mode        %s",  regs.pwm_mode[channel].name())};
      str = {str, $sformatf("\n  invert          %b",  regs.invert[channel])};
      str = {str, $sformatf("\n  clk_div         %0d", regs.clk_div[channel])};
      str = {str, $sformatf("\n  dc_resn         %0d", regs.dc_resn[channel])};
      str = {str, $sformatf("\n  phase_delay     %0d", regs.phase_delay[channel])};
      str = {str, $sformatf("\n  duty_cycle_A    %0d", regs.duty_cycle_a[channel])};
      str = {str, $sformatf("\n  duty_cycle_B    %0d", regs.duty_cycle_b[channel])};
      str = {str, $sformatf("\n  blink_param_X   %0d", regs.blink_param_x[channel])};
      str = {str, $sformatf("\n  blink_param_Y   %0d", regs.blink_param_y[channel])};
      `uvm_info(`gfn, $sformatf("%s", str), UVM_LOW)
    end
  endfunction : print_pwm_regs
  
  // set reg/mreg using name and index
  virtual function dv_base_reg get_dv_base_reg_by_name(string csr_name,
                                                       int    csr_idx = -1);
    string  reg_name;
    uvm_reg reg_uvm;

    reg_name = (csr_idx == -1) ? csr_name : $sformatf("%s_%0d", csr_name, csr_idx);
    reg_uvm  = ral.get_reg_by_name(reg_name);
    `DV_CHECK_NE_FATAL(reg_uvm, null, reg_name)
    `downcast(get_dv_base_reg_by_name, reg_uvm)
  endfunction : get_dv_base_reg_by_name

endclass : pwm_base_vseq
