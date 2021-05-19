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
  // pwm registers
  rand pwm_regs_t    pwm_regs;

  semaphore          key_prog_regs;

  // constraints
  constraint num_trans_c {
    //num_trans inside {[cfg.seq_cfg.pwm_min_num_trans : cfg.seq_cfg.pwm_max_num_trans]};
    num_trans == 8;
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
    pwm_regs.num_pulses inside {[cfg.seq_cfg.pwm_min_num_pulses :
                                 cfg.seq_cfg.pwm_max_num_pulses]};
  }

  //================================
  virtual task pre_start();
    num_runs.rand_mode(0);
    // unset to disable intr test because pwm does not have intr pins
    do_clear_all_interrupts = 1'b0;
    cfg.pwm_stop_all_channels = 1'b0;
    cfg.pwm_vif.reset();
    key_prog_regs  = new(1);
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
  virtual task start_pwm_channels();
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: start channels (%b)", pwm_regs.en), UVM_LOW)
    csr_wr(.ptr(ral.pwm_en), .value(pwm_regs.en));
  endtask : start_pwm_channels

  virtual task run_pwm_channels();
    uint runtime;

    runtime = pwm_regs.num_pulses * pwm_regs.pulse_period;
    `DV_CHECK_NE(runtime, 0)
    cfg.clk_rst_vif.wait_clks(runtime);
    csr_wr(.ptr(ral.pwm_en), .value({PWM_NUM_CHANNELS{1'b0}}));
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: stop channels after %0d cycles", runtime), UVM_LOW)
  endtask : run_pwm_channels

  virtual task program_pwm_invert_regs();
    for (int i = 0; i < PWM_NUM_CHANNELS; i++) begin
      set_dv_base_reg_field_by_name("invert", "invert", pwm_regs.invert[i], i);
    end
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
  virtual function void update_pwm_config(bit en_print = 1'b0);
    // derived params
    pwm_regs.beat_period  = pwm_regs.clk_div + 1;
    pwm_regs.pulse_period = (1 << (pwm_regs.dc_resn + 1)) * pwm_regs.beat_period;

    cfg.pwm_vif.pwm_regs.beat_period  = pwm_regs.beat_period;
    cfg.pwm_vif.pwm_regs.pulse_period = pwm_regs.pulse_period;
    cfg.pwm_vif.pwm_regs.num_pulses   = pwm_regs.num_pulses;
    // single regs
    cfg.pwm_vif.pwm_regs.dc_resn = pwm_regs.dc_resn;
    cfg.pwm_vif.pwm_regs.clk_div = pwm_regs.clk_div;
    for (int channel = 0; channel < PWM_NUM_CHANNELS; channel++) begin
      // multi regs
      cfg.pwm_vif.pwm_regs.en[channel]            = pwm_regs.en[channel];
      cfg.pwm_vif.pwm_regs.pwm_mode[channel]      = pwm_regs.pwm_mode[channel];
      cfg.pwm_vif.pwm_regs.invert[channel]        = pwm_regs.invert[channel];
      cfg.pwm_vif.pwm_regs.blink_en[channel]      = pwm_regs.blink_en[channel];
      cfg.pwm_vif.pwm_regs.htbt_en[channel]       = pwm_regs.htbt_en[channel];
      cfg.pwm_vif.pwm_regs.phase_delay[channel]   = pwm_regs.phase_delay[channel];
      cfg.pwm_vif.pwm_regs.duty_cycle_a[channel]  = pwm_regs.duty_cycle_a[channel];
      cfg.pwm_vif.pwm_regs.duty_cycle_b[channel]  = pwm_regs.duty_cycle_b[channel];
      cfg.pwm_vif.pwm_regs.blink_param_x[channel] = pwm_regs.blink_param_x[channel];
      cfg.pwm_vif.pwm_regs.blink_param_y[channel] = pwm_regs.blink_param_y[channel];
      // print pwm config
      cfg.print_pwm_regs(cfg.pwm_vif.pwm_regs, channel, en_print);
    end
    `uvm_info(`gfn, "\n  base_vseq: update pwm_vif", UVM_LOW)
  endfunction : update_pwm_config

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
