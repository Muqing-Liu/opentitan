// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Implements functional coverage for entropy_src.
interface entropy_src_cov_if
  import entropy_src_pkg::*;
  import prim_mubi_pkg::*;
(
  input logic clk_i,
  mubi8_t     otp_en_entropy_src_fw_read_i,
  mubi8_t     otp_en_entropy_src_fw_over_i
);

  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import entropy_src_reg_pkg::*;
  import entropy_src_env_pkg::*;
  `include "dv_fcov_macros.svh"

  bit en_full_cov = 1'b1;
  bit en_intg_cov = 1'b1;

  // If en_full_cov is set, then en_intg_cov must also be set since it is a subset.
  bit en_intg_cov_loc;

  // Resolution to use when converting real sigma values to integers for binning
  real sigma_res = 0.5;

  assign en_intg_cov_loc = en_full_cov | en_intg_cov;

  covergroup entropy_src_err_test_cg with function sample(bit[4:0] bit_num);
    option.name         = "entropy_src_err_test_cg";
    option.per_instance = 1;

     cp_test_bit: coverpoint bit_num {
       bins valid[] = {0, 1, 2, 20, 21, 22, 28, 29, 30};
     }

  endgroup : entropy_src_err_test_cg

  covergroup entropy_src_mubi_err_cg with function sample(invalid_mubi_e which_mubi);
    option.name         = "entropy_src_mubi_err_cg";
    option.per_instance = 1;

    cp_which_mubi: coverpoint which_mubi;

  endgroup : entropy_src_mubi_err_cg

  covergroup entropy_src_sm_err_cg with function sample(bit ack_sm_err,
                                                        bit main_sm_err);
    option.name         = "entropy_src_sm_err_cg";
    option.per_instance = 1;

    cp_ack_sm: coverpoint ack_sm_err {
      bins ack_sm = {1};
    }

    cp_main_sm: coverpoint main_sm_err {
      bins main_sm = {1};
    }

  endgroup : entropy_src_sm_err_cg

  covergroup entropy_src_fifo_err_cg with function sample(which_fifo_err_e which_fifo_err,
                                                          which_fifo_e which_fifo);
    option.name         = "entropy_src_fifo_err_cg";
    option.per_instance = 1;

    cp_which_fifo: coverpoint which_fifo;

    cp_which_err: coverpoint which_fifo_err;

    cr_fifo_err: cross cp_which_fifo, cp_which_err;

  endgroup : entropy_src_fifo_err_cg

  covergroup entropy_src_cntr_err_cg with function sample(cntr_e which_cntr,
                                                          int which_line,
                                                          int which_bucket);
    option.name         = "entropy_src_cntr_err_cg";
    option.per_instance = 1;

    // coverpoint for counters with only one instance
    cp_which_cntr: coverpoint which_cntr {
       bins single_cntrs[] = {window_cntr, repcnts_ht_cntr};
    }

    cp_which_repcnt_line: coverpoint which_line iff(which_cntr == repcnt_ht_cntr) {
      bins repcnt_cntrs[] = { [0:3] };
    }

    cp_which_adaptp_line: coverpoint which_line iff(which_cntr == adaptp_ht_cntr) {
      bins adaptp_cntrs[] = { [0:3] };
    }

    cp_which_markov_line: coverpoint which_line iff(which_cntr == markov_ht_cntr) {
      bins markov_cntrs[] = { [0:3] };
    }

    cp_which_bucket: coverpoint which_bucket iff(which_cntr == bucket_ht_cntr) {
      bins bucket_cntrs[] = { [0:15] };
    }

  endgroup : entropy_src_cntr_err_cg

  // Covergroup to confirm that the entropy_data CSR interface works
  // for all configurations
  covergroup entropy_src_seed_output_csr_cg with function sample(mubi4_t   fips_enable,
                                                                 mubi4_t   threshold_scope,
                                                                 mubi4_t   rng_bit_enable,
                                                                 bit [1:0] rng_bit_sel,
                                                                 mubi4_t   es_route,
                                                                 mubi4_t   es_type,
                                                                 mubi4_t   entropy_data_reg_enable,
                                                                 mubi8_t   otp_en_es_fw_read,
                                                                 mubi4_t   fw_ov_mode,
                                                                 mubi4_t   entropy_insert,
                                                                 bit       full_seed);

    option.name         = "entropy_src_seed_output_csr_cg";
    option.per_instance = 1;

    // For the purposes of this CG, ignore coverage of invalid MuBi values
    cp_fips_enable: coverpoint fips_enable iff(full_seed) {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_threshold_scope: coverpoint threshold_scope iff(full_seed) {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_enable: coverpoint rng_bit_enable iff(full_seed) {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_sel: coverpoint rng_bit_sel iff(full_seed);

    // Signal an error if data is observed when es_route is false.
    // Sample this even if we don't have a full seed, to detect partial seed
    // leakage.
    cp_es_route: coverpoint es_route {
      bins         mubi_true  = { MuBi4True };
      illegal_bins mubi_false = { MuBi4False };
    }

    cp_es_type: coverpoint es_type iff(full_seed) {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // Signal an error if data is observed when entropy_data_reg_enable is false
    // Sample this even if we don't have a full seed, to detect partial seed
    // leakage.
    cp_entropy_data_reg_enable: coverpoint entropy_data_reg_enable {
      bins         mubi_true  = { MuBi4True };
      illegal_bins mubi_false = { MuBi4False };
    }

    // Signal an error if data is observed when otp_en_es_fw_read is false.
    // Sample this even if we don't have a full seed, to detect partial seed
    // leakage.
    cp_otp_en_es_fw_read: coverpoint otp_en_es_fw_read {
      bins         mubi_true  = { MuBi8True };
      illegal_bins mubi_false = { MuBi8False };
    }

    // Sample the FW_OV parameters, just to be sure that they
    // don't interfere with the entropy_data interface.
    cp_fw_ov_mode: coverpoint fw_ov_mode {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_entropy_insert: coverpoint entropy_insert {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // Cross coverage points

    // Entropy data interface is tested with all valid configurations
    cr_config: cross cp_fips_enable, cp_threshold_scope, cp_rng_bit_enable,
        cp_rng_bit_sel, cp_es_type, cp_otp_en_es_fw_read;

    // Entropy data interface functions despite any changes to the fw_ov settings
    cr_fw_ov: cross cp_fw_ov_mode, cp_entropy_insert;

  endgroup : entropy_src_seed_output_csr_cg

  // Covergroup to confirm that the CSRNG HW interface works
  // for all configurations
  covergroup entropy_src_csrng_hw_cg with function sample(bit [3:0] fips_enable,
                                                          bit [3:0] threshold_scope,
                                                          bit [3:0] rng_bit_enable,
                                                          bit [1:0] rng_bit_sel,
                                                          bit [3:0] es_route,
                                                          bit [3:0] es_type,
                                                          bit [3:0] entropy_data_reg_enable,
                                                          bit [7:0] otp_en_es_fw_read,
                                                          bit [3:0] fw_ov_mode,
                                                          bit [3:0] entropy_insert);

    option.name         = "entropy_src_csrng_hw_cg";
    option.per_instance = 1;

    // For the purposes of this CG, ignore coverage of invalid MuBi values
    cp_fips_enable: coverpoint fips_enable {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_threshold_scope: coverpoint threshold_scope {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_enable: coverpoint rng_bit_enable {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_sel: coverpoint rng_bit_sel;

    // Signal an error if data is observed when es_route is true.
    cp_es_route: coverpoint es_route {
      illegal_bins mubi_true  = { MuBi4True };
      bins         mubi_false = { MuBi4False };
    }

    // This should have no effect on the CSRNG HW IF
    // but we should cover it anyway.
    cp_es_type: coverpoint es_type {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // This should have no effect on the CSRNG HW IF
    // but we should cover it anyway.
    cp_entropy_data_reg_enable: coverpoint entropy_data_reg_enable {
      bins         mubi_true  = { MuBi4True };
      bins         mubi_false = { MuBi4False };
    }

    // This should have no effect on the CSRNG HW IF
    // but we should cover it anyway.
    cp_otp_en_es_fw_read: coverpoint otp_en_es_fw_read {
      bins         mubi_true  = { MuBi8True };
      bins         mubi_false = { MuBi8False };
    }

    // Sample the FW_OV parameters, just to be sure that they
    // don't interfere with the entropy_data interface.
    cp_fw_ov_mode: coverpoint fw_ov_mode {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_entropy_insert: coverpoint entropy_insert {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // Cross coverage points

    // CSRNG HW interface is tested with all valid configurations
    cr_config: cross cp_fips_enable, cp_threshold_scope, cp_rng_bit_enable,
        cp_rng_bit_sel, cp_es_type, cp_otp_en_es_fw_read;

    // CSRNG HW interface functions despite any changes to the fw_ov settings
    cr_fw_ov: cross cp_fw_ov_mode, cp_entropy_insert;

  endgroup : entropy_src_csrng_hw_cg

  // Covergroup to confirm that the Observe FIFO interface works
  // for all configurations
  covergroup entropy_src_observe_fifo_cg with function sample(mubi4_t   fips_enable,
                                                              mubi4_t   threshold_scope,
                                                              mubi4_t   rng_bit_enable,
                                                              bit [1:0] rng_bit_sel,
                                                              mubi4_t   es_route,
                                                              mubi4_t   es_type,
                                                              mubi4_t   entropy_data_reg_enable,
                                                              mubi8_t   otp_en_es_fw_read,
                                                              mubi4_t   fw_ov_mode,
                                                              mubi4_t   entropy_insert);

    option.name         = "entropy_src_seed_observe_fifo_cg";
    option.per_instance = 1;

    // For the purposes of this CG, ignore coverage of invalid MuBi values

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_fips_enable: coverpoint fips_enable {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
     }

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_threshold_scope: coverpoint threshold_scope {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_enable: coverpoint rng_bit_enable {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    cp_rng_bit_sel: coverpoint rng_bit_sel;

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_es_route: coverpoint es_route {
      bins         mubi_true  = { MuBi4True };
      bins         mubi_false = { MuBi4False };
    }

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_es_type: coverpoint es_type {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_entropy_data_reg_enable: coverpoint entropy_data_reg_enable {
      bins         mubi_true  = { MuBi4True };
      bins         mubi_false = { MuBi4False };
    }

    // This should have no effect on the Observe FIFO IF
    // but we should cover it anyway.
    cp_otp_en_es_fw_read: coverpoint otp_en_es_fw_read {
      bins         mubi_true  = { MuBi8True };
      bins         mubi_false = { MuBi8False };
    }

    // No data should emerge from the Observe FIFO when disabled
    cp_fw_ov_mode: coverpoint fw_ov_mode {
      bins         mubi_true  = { MuBi4True };
      illegal_bins mubi_false = { MuBi4False };
    }

    cp_entropy_insert: coverpoint entropy_insert {
      bins        mubi_true  = { MuBi4True };
      bins        mubi_false = { MuBi4False };
    }

    // Cross coverage points

    // Entropy data interface is tested with all valid configurations
    cr_config: cross cp_fips_enable, cp_threshold_scope, cp_rng_bit_enable,
        cp_rng_bit_sel, cp_es_type;

    // Entropy data interface functions despite any changes to the fw_ov settings
    cr_fw_ov: cross cp_fw_ov_mode, cp_entropy_insert;

  endgroup : entropy_src_observe_fifo_cg

  covergroup entropy_src_sw_update_cg with function sample(uvm_reg_addr_t offset,
                                                           bit sw_regupd,
                                                           bit module_enable);

    option.name         = "entropy_src_sw_update_cg";
    option.per_instance = 1;

    cp_lock_state: coverpoint {sw_regupd, module_enable} {
      bins locked_states[] = {2'b00, 2'b01, 2'b11};
    }

    cp_offset: coverpoint offset {
      bins lockable_offsets[] = {
          entropy_src_reg_pkg::ENTROPY_SRC_CONF_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_ENTROPY_CONTROL_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_HEALTH_TEST_WINDOWS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_REPCNT_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_REPCNTS_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_ADAPTP_HI_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_ADAPTP_LO_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_BUCKET_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_MARKOV_HI_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_MARKOV_LO_THRESHOLDS_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_FW_OV_CONTROL_OFFSET,
          entropy_src_reg_pkg::ENTROPY_SRC_OBSERVE_FIFO_THRESH_OFFSET
      };
    }

    cr_cross: cross cp_lock_state, cp_offset;

  endgroup : entropy_src_sw_update_cg

  // "Shallow" covergroup to validate that the windowed health checks are passing and failing for
  // all possible window sizes
  covergroup entropy_src_win_ht_cg with function sample(health_test_e test_type,
                                                        which_ht_e hi_lo,
                                                        int window_size,
                                                        bit fail);

    option.name         = "entropy_src_win_ht_cg";
    option.per_instance = 1;

    cp_winsize : coverpoint window_size {
      bins common[] = {384, 512, 1024, 2048, 4096};
      bins larger = {8192, 16384, 32768};
    }

    cp_type : coverpoint test_type {
      bins types[] = {adaptp_ht, bucket_ht, markov_ht};
    }

    cp_hi_lo : coverpoint hi_lo;

    cp_fail : coverpoint fail;

    cr_cross : cross cp_winsize, cp_type, cp_hi_lo, cp_fail {
      // bucket_ht does not have a low threshold
      ignore_bins ignore = binsof(cp_type) intersect { bucket_ht } &&
                           binsof(cp_hi_lo) intersect { low_test };
    }

  endgroup : entropy_src_win_ht_cg

  // "Deep" covergroup definition to confirm that the threshold performance has been
  // properly tested for a practical range of thresholds for all windowed tests.
  //
  // Covering a range of thesholds for the windowed tests is challenging as the
  // results of the test values are generally expected to be centered around the average
  // value.  Many threshold values will require directed tests to obtain a pass or fail value,
  // if they are even testable at all.
  //
  // Rather than trying to cover all possible threshold ranges with directed tests
  // we focus on a well defined set of bins corresponding to threshold aggressiveness.
  //
  // The most aggressive threshold bin (0-2 sigma) would be most likely to have frequent false
  // positives (at least once every 20 window samples) and HT alerts even when dealing with
  // an ideal stream of RNG inputs.
  //
  // The least aggressive threshold bin (> 6 sigma) more accurately corresponds to the functional
  // mode of operation, with a low rate of false postives, which will require some directed
  // tests to trigger a HT failure.
  //
  // The definition of these practical ranges depends on the size of the windows
  // and the threshold mode (i.e. are statistics accumulated over all RNG lines, or are the
  // thresholds applied on a per-line basis?).  Furthermore, this relationship between the
  // window size and the threshold bins (2-sigma, 4-sigma, 6-sigma, 12-sigma) is non-trivial.
  // That said this covergroup is parameterized in terms of the window size and mode,
  // so unique threshold bins can be constructed for the desired window size.
  // Several instances are then created for a targetted handful of window sizes.
  //

  function automatic unsigned sigma_to_int(real sigma);
    return unsigned'($rtoi($floor(sigma/sigma_res)));
  endfunction

  covergroup entropy_src_win_ht_deep_threshold_cg()
      with function sample(health_test_e test_type,
                           which_ht_e hi_lo,
                           int window_size,
                           bit by_line,
                           real sigma,
                           bit fail);

    option.name         = "entropy_src_win_ht_deep_threshold_cg";
    option.per_instance = 1;

    cp_type : coverpoint test_type {
      bins types[] = {adaptp_ht, bucket_ht, markov_ht};
    }

    // Sharp focus on most important window sizes
    // for this covergroup
    cp_winsize : coverpoint window_size {
      bins sizes[] = {384, 1024, 2048};
    }

    cp_by_line : coverpoint by_line;

    cp_hi_lo : coverpoint hi_lo;

    cp_fail : coverpoint fail;

    // TODO CP for alert count
    // TODO Ignore bins for thresholds when tests are not applied
    //      (i.e. in open threshold configuration or FW Override modes)

    cp_threshold : coverpoint sigma_to_int(sigma) {
      // Very frequent false positive rates 1 in 6 for single-sided test
      // (good for testing frequent alert scenarios)
      bins extremely_tight = { [0 : sigma_to_int(1.0) - 1]};
      // False positive rate > 2.5% (for testing frequent single failures)
      bins very_tight      = { [sigma_to_int(1.0) : sigma_to_int(2.0) - 1] };
      // False positive rate > 3ppm (almost covers up to SP 800-90B's minimum suggested 1 in 2^20)
      bins tight           = { [sigma_to_int(2.0) : sigma_to_int(4.5) - 1] };
      // False positive rate > 1.25 in 1e12 (covers to most of SP 800-90B range down to 1 in 2^40)
      bins typical         = { [sigma_to_int(4.5) : sigma_to_int(7.0) - 1] };
      // All other possible sigma values
      bins loose           = { [sigma_to_int(7.0) : 32'hffff_ffff]};
    }

    cr_cross : cross cp_winsize, cp_by_line, cp_type, cp_hi_lo, cp_fail, cp_threshold {
      // bucket_ht does not have a low threshold
      ignore_bins ignore_a = binsof(cp_type) intersect { bucket_ht } &&
                             binsof(cp_hi_lo) intersect { low_test };
      // by_line mode does not apply to bucket_ht
      ignore_bins ignore_b = binsof(cp_type) intersect { bucket_ht } &&
                             binsof(cp_by_line) intersect { 1 };
    }

  endgroup : entropy_src_win_ht_deep_threshold_cg

  // TODO: Covergroup for non-windowed tests.

  `DV_FCOV_INSTANTIATE_CG(entropy_src_err_test_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_mubi_err_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_sm_err_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_fifo_err_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_cntr_err_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_seed_output_csr_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_csrng_hw_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_observe_fifo_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_sw_update_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_win_ht_cg, en_full_cov)
  `DV_FCOV_INSTANTIATE_CG(entropy_src_win_ht_deep_threshold_cg, en_full_cov)

  // Sample functions needed for xcelium
  function automatic void cg_err_test_sample(bit [4:0] err_code);
    entropy_src_err_test_cg_inst.sample(err_code);
  endfunction

  function automatic void cg_mubi_err_sample(invalid_mubi_e which_mubi);
    entropy_src_mubi_err_cg_inst.sample(which_mubi);
  endfunction

  function automatic void cg_sm_err_sample(bit ack_sm_err, bit main_sm_err);
    entropy_src_sm_err_cg_inst.sample(ack_sm_err, main_sm_err);
  endfunction

  function automatic void cg_fifo_err_sample(which_fifo_err_e which_fifo_err,
                                             which_fifo_e which_fifo);
    entropy_src_fifo_err_cg_inst.sample(which_fifo_err, which_fifo);
  endfunction

  function automatic void cg_cntr_err_sample(cntr_e which_cntr,
                                             int which_line,
                                             int which_bucket);
    entropy_src_cntr_err_cg_inst.sample(which_cntr, which_line, which_bucket);
  endfunction



  function automatic void cg_seed_output_csr_sample(mubi4_t   fips_enable,
                                                    mubi4_t   threshold_scope,
                                                    mubi4_t   rng_bit_enable,
                                                    bit [1:0] rng_bit_sel,
                                                    mubi4_t   es_route,
                                                    mubi4_t   es_type,
                                                    mubi4_t   entropy_data_reg_enable,
                                                    mubi8_t   otp_en_es_fw_read,
                                                    mubi4_t   fw_ov_mode,
                                                    mubi4_t   entropy_insert,
                                                    bit       full_seed);
    entropy_src_seed_output_csr_cg_inst.sample(fips_enable, threshold_scope, rng_bit_enable,
                                               rng_bit_sel, es_route, es_type,
                                               entropy_data_reg_enable, otp_en_es_fw_read,
                                               fw_ov_mode, entropy_insert, full_seed);
  endfunction

  function automatic void cg_csrng_hw_sample(bit [3:0] fips_enable,
                                             bit [3:0] threshold_scope,
                                             bit [3:0] rng_bit_enable,
                                             bit [1:0] rng_bit_sel,
                                             bit [3:0] es_route,
                                             bit [3:0] es_type,
                                             bit [3:0] entropy_data_reg_enable,
                                             bit [7:0] otp_en_es_fw_read,
                                             bit [3:0] fw_ov_mode,
                                             bit [3:0] entropy_insert);
    entropy_src_csrng_hw_cg_inst.sample(fips_enable, threshold_scope, rng_bit_enable,
                                        rng_bit_sel, es_route, es_type,
                                        entropy_data_reg_enable, otp_en_es_fw_read,
                                        fw_ov_mode, entropy_insert);
  endfunction

  function automatic void cg_observe_fifo_sample(mubi4_t   fips_enable,
                                                 mubi4_t   threshold_scope,
                                                 mubi4_t   rng_bit_enable,
                                                 bit [1:0] rng_bit_sel,
                                                 mubi4_t   es_route,
                                                 mubi4_t   es_type,
                                                 mubi4_t   entropy_data_reg_enable,
                                                 mubi8_t   otp_en_es_fw_read,
                                                 mubi4_t   fw_ov_mode,
                                                 mubi4_t   entropy_insert);
    entropy_src_observe_fifo_cg_inst.sample(fips_enable, threshold_scope, rng_bit_enable,
                                            rng_bit_sel, es_route, es_type,
                                            entropy_data_reg_enable, otp_en_es_fw_read,
                                            fw_ov_mode, entropy_insert);
  endfunction

  function automatic void cg_sw_update_sample(uvm_pkg::uvm_reg_addr_t offset,
                                              bit sw_regupd,
                                              bit module_enable);
     string msg, fmt;

     fmt = "offset: %01d, regupd: %01d, mod_en: %01d";
     msg = $sformatf(fmt, offset, sw_regupd, module_enable);
    `uvm_info("", msg, UVM_LOW)
    entropy_src_sw_update_cg_inst.sample(offset, sw_regupd, module_enable);

  endfunction

  function automatic void cg_win_ht_sample(health_test_e test_type,
                                           which_ht_e hi_low,
                                           int window_size,
                                           bit fail);
    entropy_src_win_ht_cg_inst.sample(test_type,
                                      hi_low,
                                      window_size,
                                      fail);
  endfunction

  function automatic void cg_win_ht_deep_threshold_sample(health_test_e test_type,
                                                         which_ht_e hi_low,
                                                         int window_size,
                                                         bit by_line,
                                                         real sigma,
                                                         bit fail);
    entropy_src_win_ht_deep_threshold_cg_inst.sample(test_type,
                                                     hi_low,
                                                     window_size,
                                                     by_line,
                                                     sigma,
                                                     fail);
  endfunction


  // Sample the csrng_hw_cg whenever data is output on the csrng pins
  logic csrng_if_req, csrng_if_ack;
  mubi4_t fips_enable_csr, threshold_scope_csr, rng_bit_enable_csr, rng_bit_sel_csr, es_route_csr,
          es_type_csr, entropy_data_reg_enable_csr, fw_ov_mode_csr, entropy_insert_csr;
  mubi8_t otp_en_es_fw_read_val;

  assign csrng_if_req = tb.dut.entropy_src_hw_if_i.es_req;
  assign csrng_if_ack = tb.dut.entropy_src_hw_if_o.es_ack;

  always @(posedge clk_i) begin
    if(csrng_if_req && csrng_if_ack) begin
      cg_csrng_hw_sample(tb.dut.reg2hw.conf.fips_enable.q,
                         tb.dut.reg2hw.conf.threshold_scope.q,
                         tb.dut.reg2hw.conf.rng_bit_enable.q,
                         tb.dut.reg2hw.conf.rng_bit_sel.q,
                         tb.dut.reg2hw.entropy_control.es_route.q,
                         tb.dut.reg2hw.entropy_control.es_type.q,
                         tb.dut.reg2hw.conf.entropy_data_reg_enable.q,
                         otp_en_entropy_src_fw_read_i,
                         tb.dut.reg2hw.fw_ov_control.fw_ov_mode.q,
                         tb.dut.reg2hw.fw_ov_control.fw_ov_entropy_insert.q);
    end
  end

endinterface : entropy_src_cov_if
