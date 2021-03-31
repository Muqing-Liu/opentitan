// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class pwm_rx_tx_vseq extends pwm_base_vseq;
  `uvm_object_utils(pwm_rx_tx_vseq)
  `uvm_object_new

  virtual task body();
    `uvm_info(`gfn, "\n--> start of sequence", UVM_LOW)
    `uvm_info(`gfn, $sformatf("\n--> require simulating %0d transactions", num_trans), UVM_LOW)

    initialization();
    //for (uint i = 0; i < num_trans; i++) begin
    for (uint i = 0; i < 1; i++) begin
      `uvm_info(`gfn, $sformatf("\n\n--> start transaction %0d", i), UVM_LOW)
      `DV_CHECK_RANDOMIZE_FATAL(this)
      // program single registers out of the loop
      program_pwm_cfg_reg();
      // program multi registers with the loop
      for (int channel = 0; channel < PWM_NUM_CHANNELS; channel++) begin
        fork
          automatic int ch = channel;
          run_pwm_channel(ch);
        join_none
      end
    end
  endtask : body

  // run pwm channels
  virtual task run_pwm_channel(int channel);
    // update agent config
    update_agent_config(channel);
    // program pwm channel
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: disable channel %0d to start config ", channel), UVM_LOW)
    program_pwm_en_regs(Disable, channel);
    program_pwm_invert_regs(channel);
    program_pwm_operate_mode(channel);
    program_pwm_en_regs(Enable, channel);
    stop_pwm_channel(channel);
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: start channel %0d to generate pulses ", channel), UVM_LOW)
  endtask : run_pwm_channel

  virtual task stop_pwm_channel(int channel);
    // update agent config
    cfg.clk_rst_vif.wait_clks(1 << (pwm_regs.pwm_num_pulses[channel] + 1));
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: stop %od channel", channel), UVM_LOW)
  endtask : stop_pwm_channel

  // program pwm mode
  virtual task program_pwm_operate_mode(int channel);
    dv_base_reg base_reg;

    set_dv_base_reg_field_by_name("pwm_param", "phase_delay",
        pwm_regs.phase_delay[channel], channel, channel);
    `uvm_info(`gfn, $sformatf("\n  txrx_vseq: program param to mode %s",
        pwm_regs.pwm_mode[channel].name()), UVM_LOW)
    case (pwm_regs.pwm_mode[channel])
      Standard: begin
        set_dv_base_reg_field_by_name("pwm_param", "blink_en", Disable, channel, channel);
        // Standard mode requires setting only duty_cycle_a
        set_dv_base_reg_field_by_name("duty_cycle", "a",
            pwm_regs.duty_cycle_a[channel], channel, channel);
      end
      Blinking: begin
        // program duty_cycle_a and duty_cycle_b in same cycle
        program_pwm_duty_cycle_regs(channel);
        // disable blink_en
        set_dv_base_reg_field_by_name("pwm_param", "blink_en", Disable, channel, channel);
        // program blink_param_x and blink_param_y in same cycle
        program_pwm_blink_param_regs(channel);
        // enable blink_en
        set_dv_base_reg_field_by_name("pwm_param", "blink_en", Enable, channel, channel);
      end
      Heartbeat: begin
        // program duty_cycle_a and duty_cycle_b in same cycle
        program_pwm_duty_cycle_regs(channel);
        // disable blink_en
        set_dv_base_reg_field_by_name("pwm_param", "blink_en", Disable, channel, channel);
        // program blink_param_x and blink_param_y in same cycle
        program_pwm_blink_param_regs(channel);
        base_reg = get_dv_base_reg_by_name("pwm_param", channel);
        // enable blink_en and htbt_en in same cycle
        set_dv_base_reg_field_by_name("pwm_param", "blink_en", Enable, channel, channel, 1'b0);
        set_dv_base_reg_field_by_name("pwm_param", "htbt_en",  Enable, channel, channel, 1'b0);
        csr_update(base_reg);
      end
      default: begin
        `uvm_fatal(`gfn, "\n  txrx_vseq: invalid pwm mode")
      end
    endcase
  endtask : program_pwm_operate_mode

endclass : pwm_rx_tx_vseq