// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package csrng_reg_pkg;

  // Param list
  parameter int NumAlerts = 1;

  // Address widths within the block
  parameter int BlockAw = 7;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    struct packed {
      logic        q;
    } cs_cmd_req_done;
    struct packed {
      logic        q;
    } cs_entropy_req;
    struct packed {
      logic        q;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
    } cs_fatal_err;
  } csrng_reg2hw_intr_state_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } cs_cmd_req_done;
    struct packed {
      logic        q;
    } cs_entropy_req;
    struct packed {
      logic        q;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
    } cs_fatal_err;
  } csrng_reg2hw_intr_enable_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } cs_cmd_req_done;
    struct packed {
      logic        q;
      logic        qe;
    } cs_entropy_req;
    struct packed {
      logic        q;
      logic        qe;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
      logic        qe;
    } cs_fatal_err;
  } csrng_reg2hw_intr_test_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } csrng_reg2hw_alert_test_reg_t;

  typedef struct packed {
    logic        q;
  } csrng_reg2hw_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } csrng_reg2hw_cmd_req_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } csrng_reg2hw_genbits_reg_t;

  typedef struct packed {
    logic [3:0]  q;
    logic        qe;
  } csrng_reg2hw_int_state_num_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } csrng_reg2hw_int_state_val_reg_t;

  typedef struct packed {
    logic [4:0]  q;
    logic        qe;
  } csrng_reg2hw_err_code_test_reg_t;

  typedef struct packed {
    logic [1:0]  q;
  } csrng_reg2hw_sel_tracking_sm_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } cs_cmd_req_done;
    struct packed {
      logic        d;
      logic        de;
    } cs_entropy_req;
    struct packed {
      logic        d;
      logic        de;
    } cs_hw_inst_exc;
    struct packed {
      logic        d;
      logic        de;
    } cs_fatal_err;
  } csrng_hw2reg_intr_state_reg_t;

  typedef struct packed {
    logic        d;
  } csrng_hw2reg_regwen_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } cmd_rdy;
    struct packed {
      logic        d;
      logic        de;
    } cmd_sts;
  } csrng_hw2reg_sw_cmd_sts_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } genbits_vld;
    struct packed {
      logic        d;
    } genbits_fips;
  } csrng_hw2reg_genbits_vld_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } csrng_hw2reg_genbits_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } csrng_hw2reg_int_state_val_reg_t;

  typedef struct packed {
    logic [14:0] d;
    logic        de;
  } csrng_hw2reg_hw_exc_sts_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } sfifo_cmd_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_genbits_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_cmdreq_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_rcstage_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_keyvrc_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_updreq_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_bencreq_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_bencack_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_pdata_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_final_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_gbencack_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_grcstage_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_ggenreq_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_gadstage_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_ggenbits_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_blkenc_err;
    struct packed {
      logic        d;
      logic        de;
    } cmd_stage_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } main_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } drbg_gen_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } drbg_updbe_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } drbg_updob_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } aes_cipher_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } fifo_write_err;
    struct packed {
      logic        d;
      logic        de;
    } fifo_read_err;
    struct packed {
      logic        d;
      logic        de;
    } fifo_state_err;
  } csrng_hw2reg_err_code_reg_t;

  typedef struct packed {
    struct packed {
      logic [7:0]  d;
      logic        de;
    } tracking_sm_obs0;
    struct packed {
      logic [7:0]  d;
      logic        de;
    } tracking_sm_obs1;
    struct packed {
      logic [7:0]  d;
      logic        de;
    } tracking_sm_obs2;
    struct packed {
      logic [7:0]  d;
      logic        de;
    } tracking_sm_obs3;
  } csrng_hw2reg_tracking_sm_obs_reg_t;

  // Register -> HW type
  typedef struct packed {
    csrng_reg2hw_intr_state_reg_t intr_state; // [135:132]
    csrng_reg2hw_intr_enable_reg_t intr_enable; // [131:128]
    csrng_reg2hw_intr_test_reg_t intr_test; // [127:120]
    csrng_reg2hw_alert_test_reg_t alert_test; // [119:118]
    csrng_reg2hw_ctrl_reg_t ctrl; // [117:112]
    csrng_reg2hw_cmd_req_reg_t cmd_req; // [111:79]
    csrng_reg2hw_genbits_reg_t genbits; // [78:46]
    csrng_reg2hw_int_state_num_reg_t int_state_num; // [45:41]
    csrng_reg2hw_int_state_val_reg_t int_state_val; // [40:8]
    csrng_reg2hw_err_code_test_reg_t err_code_test; // [7:2]
    csrng_reg2hw_sel_tracking_sm_reg_t sel_tracking_sm; // [1:0]
  } csrng_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    csrng_hw2reg_intr_state_reg_t intr_state; // [202:195]
    csrng_hw2reg_regwen_reg_t regwen; // [194:194]
    csrng_hw2reg_sum_sts_reg_t sum_sts; // [193:169]
    csrng_hw2reg_sw_cmd_sts_reg_t sw_cmd_sts; // [168:165]
    csrng_hw2reg_genbits_vld_reg_t genbits_vld; // [164:163]
    csrng_hw2reg_genbits_reg_t genbits; // [162:131]
    csrng_hw2reg_hw_exc_sts_reg_t hw_exc_sts; // [101:86]
    csrng_hw2reg_err_code_reg_t err_code; // [85:36]
    csrng_hw2reg_tracking_sm_obs_reg_t tracking_sm_obs; // [35:0]
  } csrng_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] CSRNG_INTR_STATE_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] CSRNG_INTR_ENABLE_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] CSRNG_INTR_TEST_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] CSRNG_ALERT_TEST_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] CSRNG_REGWEN_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] CSRNG_CTRL_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] CSRNG_CMD_REQ_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] CSRNG_SW_CMD_STS_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] CSRNG_GENBITS_VLD_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] CSRNG_GENBITS_OFFSET = 7'h 24;
  parameter logic [BlockAw-1:0] CSRNG_HALT_MAIN_SM_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_NUM_OFFSET = 7'h 2c;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_VAL_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] CSRNG_HW_EXC_STS_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] CSRNG_ERR_CODE_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] CSRNG_ERR_CODE_TEST_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] CSRNG_SEL_TRACKING_SM_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] CSRNG_TRACKING_SM_OBS_OFFSET = 7'h 44;

  // Reset values for hwext registers and their fields
  parameter logic [3:0] CSRNG_INTR_TEST_RESVAL = 4'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_CMD_REQ_DONE_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_ENTROPY_REQ_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_HW_INST_EXC_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_FATAL_ERR_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_ALERT_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_ALERT_TEST_FATAL_ALERT_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_REGWEN_RESVAL = 1'h 1;
  parameter logic [0:0] CSRNG_REGWEN_REGWEN_RESVAL = 1'h 1;
  parameter logic [1:0] CSRNG_GENBITS_VLD_RESVAL = 2'h 0;
  parameter logic [31:0] CSRNG_GENBITS_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_INT_STATE_VAL_RESVAL = 32'h 0;

  // Register index
  typedef enum int {
    CSRNG_INTR_STATE,
    CSRNG_INTR_ENABLE,
    CSRNG_INTR_TEST,
    CSRNG_ALERT_TEST,
    CSRNG_REGWEN,
    CSRNG_CTRL,
    CSRNG_CMD_REQ,
    CSRNG_SW_CMD_STS,
    CSRNG_GENBITS_VLD,
    CSRNG_GENBITS,
    CSRNG_INT_STATE_NUM,
    CSRNG_INT_STATE_VAL,
    CSRNG_HW_EXC_STS,
    CSRNG_ERR_CODE,
    CSRNG_ERR_CODE_TEST,
    CSRNG_SEL_TRACKING_SM,
    CSRNG_TRACKING_SM_OBS
  } csrng_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] CSRNG_PERMIT [18] = '{
    4'b 0001, // index[ 0] CSRNG_INTR_STATE
    4'b 0001, // index[ 1] CSRNG_INTR_ENABLE
    4'b 0001, // index[ 2] CSRNG_INTR_TEST
    4'b 0001, // index[ 3] CSRNG_ALERT_TEST
    4'b 0001, // index[ 4] CSRNG_REGWEN
    4'b 0001, // index[ 5] CSRNG_CTRL
    4'b 1111, // index[ 6] CSRNG_CMD_REQ
    4'b 0001, // index[ 7] CSRNG_SW_CMD_STS
    4'b 0001, // index[ 8] CSRNG_GENBITS_VLD
    4'b 1111, // index[ 9] CSRNG_GENBITS
    4'b 0001, // index[10] CSRNG_HALT_MAIN_SM
    4'b 0001, // index[11] CSRNG_INT_STATE_NUM
    4'b 1111, // index[12] CSRNG_INT_STATE_VAL
    4'b 0011, // index[13] CSRNG_HW_EXC_STS
    4'b 1111, // index[14] CSRNG_ERR_CODE
    4'b 0001, // index[15] CSRNG_ERR_CODE_TEST
    4'b 0001, // index[16] CSRNG_SEL_TRACKING_SM
    4'b 1111  // index[17] CSRNG_TRACKING_SM_OBS
  };

endpackage

