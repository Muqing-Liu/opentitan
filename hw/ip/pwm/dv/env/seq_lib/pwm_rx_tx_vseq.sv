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
    cfg.pwm_stop_all_channels = 1'b0;

    for (uint i = 0; i < num_trans; i++) begin
      `uvm_info(`gfn, $sformatf("\n\n--> start transaction %0d/%0d", i + 1, num_trans), UVM_LOW)
      `DV_CHECK_RANDOMIZE_FATAL(this)
      // program single registers out of the loop
      if (!cfg.under_reset) program_pwm_cfg_reg();
      // program multi registers with the loop
      program_pwm_invert_regs();
      fork
        for (int channel = 0; channel < PWM_NUM_CHANNELS; channel++) begin
          fork
            automatic int ch = channel;
            program_channel_regs(ch);
          join_none
        end
      join
      update_pwm_config();
      start_pwm_channels();   // start channels
      run_pwm_channels();     // run then stop channels
      cfg.pwm_vif.property_check(Disable);
      cfg.pwm_vif.reset();
    end
    // flag indicate all channels stopped then test is finished in phase_ready_to_end
    cfg.pwm_stop_all_channels = 1'b1;
  endtask : body

  // program pwm mode (including programming duty_cycle and pwm_param multiregs)
  virtual task program_channel_regs(int channel);
    if (pwm_regs.en[channel] == Enable) begin
      dv_base_reg base_reg;

      key_prog_regs.get(1);
      set_dv_base_reg_field_by_name("pwm_param", "phase_delay",
          pwm_regs.phase_delay[channel], channel, channel);
      `uvm_info(`gfn, $sformatf("\n  txrx_vseq: program pwm_param[%0d] to mode %s",
          channel, pwm_regs.pwm_mode[channel].name()), UVM_DEBUG)
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
      key_prog_regs.put(1);
    end
  endtask : program_channel_regs

endclass : pwm_rx_tx_vseq