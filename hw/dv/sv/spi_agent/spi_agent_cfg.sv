// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class spi_agent_cfg extends dv_base_agent_cfg;

  // enable checkers in monitor
  bit en_monitor_checks = 1'b1;

  // byte order (configured by vseq)
  bit byte_order        = 1'b1;

  // host mode cfg knobs
  time sck_period_ps    = 50_000; // 20MHz
  bit host_bit_dir;               // 0 - msb -> lsb, 1 - lsb -> msb (not support)
  bit device_bit_dir;             // 0 - msb -> lsb, 1 - lsb -> msb
  bit sck_on;                     // keep sck on

  //-------------------------
  // spi_host regs
  //-------------------------
  // csid reg
  bit [31:0]   csid;
  // configopts register fields
  bit          sck_polarity[MAX_CS-1:0];       // aka CPOL
  bit          sck_phase[MAX_CS-1:0];          // aka CPHA
  bit          fullcyc[MAX_CS-1:0];
  bit [3:0]    csnlead[MAX_CS-1:0];
  bit [3:0]    csntrail[MAX_CS-1:0];
  bit [3:0]    csnidle[MAX_CS-1:0];
  bit [15:0]   clkdiv[MAX_CS-1:0];
  // command register fields
  spi_dir_e    direction;
  spi_mode_e   spi_mode;
  bit          csaat;
  bit [8:0]    len;

  // how many bytes monitor samples per transaction
  int num_bytes_per_trans_in_mon = 4;

  // enable randomly injecting extra delay between 2 sck/word
  bit  en_extra_dly_btw_sck;
  uint min_extra_dly_ns_btw_sck     = 1;
  uint max_extra_dly_ns_btw_sck     = 100;  // small delay to avoid transfer timeout
  uint extra_dly_chance_pc_btw_sck  = 5;    // percentage of extra delay btw each spi clock edge
  // Note: can't handle word delay, if a word is splitted into multiple csb.
  // In that case, control delay in seq level
  bit  en_extra_dly_btw_word;
  uint min_extra_dly_ns_btw_word    = 1;
  uint max_extra_dly_ns_btw_word    = 1000; // no timeout btw word
  uint extra_dly_chance_pc_btw_word = 5;    // percentage of extra delay btw each word

  // interface handle used by driver, monitor & the sequencer
  virtual spi_if vif;

  `uvm_object_utils_begin(spi_agent_cfg)
    `uvm_field_int (sck_period_ps,  UVM_DEFAULT)
    `uvm_field_int (host_bit_dir,   UVM_DEFAULT)
    `uvm_field_int (device_bit_dir, UVM_DEFAULT)
    `uvm_field_int (en_extra_dly_btw_sck,         UVM_DEFAULT)
    `uvm_field_int (max_extra_dly_ns_btw_sck,     UVM_DEFAULT)
    `uvm_field_int (extra_dly_chance_pc_btw_sck,  UVM_DEFAULT)
    `uvm_field_int (en_extra_dly_btw_word,        UVM_DEFAULT)
    `uvm_field_int (max_extra_dly_ns_btw_word,    UVM_DEFAULT)
    `uvm_field_int (extra_dly_chance_pc_btw_word, UVM_DEFAULT)

    `uvm_field_sarray_int(sck_polarity,   UVM_DEFAULT)
    `uvm_field_sarray_int(sck_phase,      UVM_DEFAULT)
    `uvm_field_sarray_int(fullcyc,        UVM_DEFAULT)
    `uvm_field_sarray_int(csnlead,        UVM_DEFAULT)
    `uvm_field_sarray_int(csntrail,       UVM_DEFAULT)
    `uvm_field_sarray_int(csnidle,        UVM_DEFAULT)
    `uvm_field_sarray_int(clkdiv,         UVM_DEFAULT)
    `uvm_field_enum(spi_mode_e, spi_mode, UVM_DEFAULT)
    `uvm_field_enum(spi_dir_e, direction, UVM_DEFAULT)
    `uvm_field_int(csaat,                 UVM_DEFAULT)
    `uvm_field_int(len,                   UVM_DEFAULT)

  `uvm_object_utils_end

  `uvm_object_new

  virtual task wait_sck_edge(sck_edge_type_e sck_edge_type);
    bit       wait_posedge;
    bit [1:0] sck_mode = {sck_polarity[int'(csid)], sck_phase[int'(csid)]};

    // sck pola   sck_pha   mode
    //        0         0      0: sample at leading  podedge_sck (drive @ prev negedge_sck)
    //        1         0      2: sample at leading  negedge_sck (drive @ prev posedge_sck)
    //        0         1      1: sample at trailing negedge_sck (drive @ curr posedge_sck)
    //        1         1      3: sample at trailing posedge_sck (drive @ curr negedge_sck)
    case (sck_edge_type)
      LeadingEdge: begin
        // wait for leading edge applies to mode 1 and 3 only
        if (sck_mode inside {2'b00, 2'b10}) return;
        if (sck_mode == 2'b01) wait_posedge = 1'b1;
      end
      DrivingEdge:  wait_posedge = (sck_mode inside {2'b01, 2'b10});
      SamplingEdge: wait_posedge = (sck_mode inside {2'b00, 2'b11});
    endcase
    if (wait_posedge) @(posedge vif.sck);
    else              @(negedge vif.sck);

    `uvm_info(`gfn, $sformatf("\n  spi_agent_cfg, %s at %s clock, sck_mode %b",
        sck_edge_type.name(), wait_posedge ? "posedge" : "negedge", sck_mode), UVM_DEBUG)
  endtask

  virtual function void swap_byte_order(ref bit [7:0] data[$]);
    bit [7:0] data_arr[];
    data_arr = data;
    `uvm_info(`gfn, $sformatf("\n  spi_agent_cfg, data_q_baseline: %p", data), UVM_DEBUG)
    dv_utils_pkg::endian_swap_byte_arr(data_arr);
    `uvm_info(`gfn, $sformatf("\n  spi_agent_cfg, data_q_swapped:  %p", data_arr), UVM_DEBUG)
    data = data_arr;
  endfunction : swap_byte_order

  virtual function int get_num_sck_edges();
    case (spi_mode)
      Standard: return (len + 1)*8;
      Dual:     return (len + 1)*4;
      Quad:     return (len + 1)*2;
      default:  return 0;
    endcase
  endfunction : get_num_sck_edges

  virtual function int get_sio_size();
    case (spi_mode)
      Standard: return 1;
      Dual:     return 2;
      Quad:     return 4;
      default:  return 0;
    endcase
  endfunction : get_sio_size

endclass : spi_agent_cfg
