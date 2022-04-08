// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package clkmgr_reg_pkg;

  // Param list
  parameter int NumGroups = 7;
  parameter int NumSwGateableClocks = 4;
  parameter int NumHintableClocks = 4;
  parameter int NumAlerts = 2;

  // Address widths within the block
  parameter int BlockAw = 6;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } recov_fault;
    struct packed {
      logic        q;
      logic        qe;
    } fatal_fault;
  } clkmgr_reg2hw_alert_test_reg_t;

  typedef struct packed {
    struct packed {
      logic [3:0]  q;
    } sel;
    struct packed {
      logic [3:0]  q;
    } hi_speed_sel;
  } clkmgr_reg2hw_extclk_ctrl_reg_t;

  typedef struct packed {
    logic [3:0]  q;
  } clkmgr_reg2hw_jitter_enable_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } clk_io_div4_peri_en;
    struct packed {
      logic        q;
    } clk_io_div2_peri_en;
    struct packed {
      logic        q;
    } clk_usb_peri_en;
    struct packed {
      logic        q;
    } clk_io_peri_en;
  } clkmgr_reg2hw_clk_enables_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } clk_main_aes_hint;
    struct packed {
      logic        q;
    } clk_main_hmac_hint;
    struct packed {
      logic        q;
    } clk_main_kmac_hint;
    struct packed {
      logic        q;
    } clk_main_otbn_hint;
  } clkmgr_reg2hw_clk_hints_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [9:0] q;
    } hi;
    struct packed {
      logic [9:0] q;
    } lo;
  } clkmgr_reg2hw_io_meas_ctrl_shadowed_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [8:0]  q;
    } hi;
    struct packed {
      logic [8:0]  q;
    } lo;
  } clkmgr_reg2hw_io_div2_meas_ctrl_shadowed_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [7:0]  q;
    } hi;
    struct packed {
      logic [7:0]  q;
    } lo;
  } clkmgr_reg2hw_io_div4_meas_ctrl_shadowed_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [9:0] q;
    } hi;
    struct packed {
      logic [9:0] q;
    } lo;
  } clkmgr_reg2hw_main_meas_ctrl_shadowed_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [8:0]  q;
    } hi;
    struct packed {
      logic [8:0]  q;
    } lo;
  } clkmgr_reg2hw_usb_meas_ctrl_shadowed_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } reg_intg;
    struct packed {
      logic        q;
    } idle_cnt;
    struct packed {
      logic        q;
    } shadow_storage_err;
  } clkmgr_reg2hw_fatal_err_code_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } clk_main_aes_val;
    struct packed {
      logic        d;
      logic        de;
    } clk_main_hmac_val;
    struct packed {
      logic        d;
      logic        de;
    } clk_main_kmac_val;
    struct packed {
      logic        d;
      logic        de;
    } clk_main_otbn_val;
  } clkmgr_hw2reg_clk_hints_status_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } shadow_update_err;
    struct packed {
      logic        d;
      logic        de;
    } io_measure_err;
    struct packed {
      logic        d;
      logic        de;
    } io_div2_measure_err;
    struct packed {
      logic        d;
      logic        de;
    } io_div4_measure_err;
    struct packed {
      logic        d;
      logic        de;
    } main_measure_err;
    struct packed {
      logic        d;
      logic        de;
    } usb_measure_err;
    struct packed {
      logic        d;
      logic        de;
    } io_timeout_err;
    struct packed {
      logic        d;
      logic        de;
    } io_div2_timeout_err;
    struct packed {
      logic        d;
      logic        de;
    } io_div4_timeout_err;
    struct packed {
      logic        d;
      logic        de;
    } main_timeout_err;
    struct packed {
      logic        d;
      logic        de;
    } usb_timeout_err;
  } clkmgr_hw2reg_recov_err_code_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } reg_intg;
    struct packed {
      logic        d;
      logic        de;
    } idle_cnt;
    struct packed {
      logic        d;
      logic        de;
    } shadow_storage_err;
  } clkmgr_hw2reg_fatal_err_code_reg_t;

  // Register -> HW type
  typedef struct packed {
    clkmgr_reg2hw_alert_test_reg_t alert_test; // [123:120]
    clkmgr_reg2hw_extclk_ctrl_reg_t extclk_ctrl; // [119:112]
    clkmgr_reg2hw_jitter_enable_reg_t jitter_enable; // [111:108]
    clkmgr_reg2hw_clk_enables_reg_t clk_enables; // [107:104]
    clkmgr_reg2hw_clk_hints_reg_t clk_hints; // [103:100]
    clkmgr_reg2hw_io_meas_ctrl_shadowed_reg_t io_meas_ctrl_shadowed; // [99:79]
    clkmgr_reg2hw_io_div2_meas_ctrl_shadowed_reg_t io_div2_meas_ctrl_shadowed; // [78:60]
    clkmgr_reg2hw_io_div4_meas_ctrl_shadowed_reg_t io_div4_meas_ctrl_shadowed; // [59:43]
    clkmgr_reg2hw_main_meas_ctrl_shadowed_reg_t main_meas_ctrl_shadowed; // [42:22]
    clkmgr_reg2hw_usb_meas_ctrl_shadowed_reg_t usb_meas_ctrl_shadowed; // [21:3]
    clkmgr_reg2hw_fatal_err_code_reg_t fatal_err_code; // [2:0]
  } clkmgr_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    clkmgr_hw2reg_clk_hints_status_reg_t clk_hints_status; // [35:28]
    clkmgr_hw2reg_recov_err_code_reg_t recov_err_code; // [27:6]
    clkmgr_hw2reg_fatal_err_code_reg_t fatal_err_code; // [5:0]
  } clkmgr_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] CLKMGR_ALERT_TEST_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] CLKMGR_EXTCLK_CTRL_REGWEN_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] CLKMGR_EXTCLK_CTRL_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] CLKMGR_JITTER_REGWEN_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] CLKMGR_JITTER_ENABLE_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] CLKMGR_CLK_ENABLES_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] CLKMGR_CLK_HINTS_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] CLKMGR_CLK_HINTS_STATUS_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] CLKMGR_MEASURE_CTRL_REGWEN_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] CLKMGR_IO_MEAS_CTRL_SHADOWED_OFFSET = 6'h 24;
  parameter logic [BlockAw-1:0] CLKMGR_IO_DIV2_MEAS_CTRL_SHADOWED_OFFSET = 6'h 28;
  parameter logic [BlockAw-1:0] CLKMGR_IO_DIV4_MEAS_CTRL_SHADOWED_OFFSET = 6'h 2c;
  parameter logic [BlockAw-1:0] CLKMGR_MAIN_MEAS_CTRL_SHADOWED_OFFSET = 6'h 30;
  parameter logic [BlockAw-1:0] CLKMGR_USB_MEAS_CTRL_SHADOWED_OFFSET = 6'h 34;
  parameter logic [BlockAw-1:0] CLKMGR_RECOV_ERR_CODE_OFFSET = 6'h 38;
  parameter logic [BlockAw-1:0] CLKMGR_FATAL_ERR_CODE_OFFSET = 6'h 3c;

  // Reset values for hwext registers and their fields
  parameter logic [1:0] CLKMGR_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] CLKMGR_ALERT_TEST_RECOV_FAULT_RESVAL = 1'h 0;
  parameter logic [0:0] CLKMGR_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;

  // Register index
  typedef enum int {
    CLKMGR_ALERT_TEST,
    CLKMGR_EXTCLK_CTRL_REGWEN,
    CLKMGR_EXTCLK_CTRL,
    CLKMGR_JITTER_REGWEN,
    CLKMGR_JITTER_ENABLE,
    CLKMGR_CLK_ENABLES,
    CLKMGR_CLK_HINTS,
    CLKMGR_CLK_HINTS_STATUS,
    CLKMGR_MEASURE_CTRL_REGWEN,
    CLKMGR_IO_MEAS_CTRL_SHADOWED,
    CLKMGR_IO_DIV2_MEAS_CTRL_SHADOWED,
    CLKMGR_IO_DIV4_MEAS_CTRL_SHADOWED,
    CLKMGR_MAIN_MEAS_CTRL_SHADOWED,
    CLKMGR_USB_MEAS_CTRL_SHADOWED,
    CLKMGR_RECOV_ERR_CODE,
    CLKMGR_FATAL_ERR_CODE
  } clkmgr_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] CLKMGR_PERMIT [16] = '{
    4'b 0001, // index[ 0] CLKMGR_ALERT_TEST
    4'b 0001, // index[ 1] CLKMGR_EXTCLK_CTRL_REGWEN
    4'b 0001, // index[ 2] CLKMGR_EXTCLK_CTRL
    4'b 0001, // index[ 3] CLKMGR_JITTER_REGWEN
    4'b 0001, // index[ 4] CLKMGR_JITTER_ENABLE
    4'b 0001, // index[ 5] CLKMGR_CLK_ENABLES
    4'b 0001, // index[ 6] CLKMGR_CLK_HINTS
    4'b 0001, // index[ 7] CLKMGR_CLK_HINTS_STATUS
    4'b 0001, // index[ 8] CLKMGR_MEASURE_CTRL_REGWEN
    4'b 0111, // index[ 9] CLKMGR_IO_MEAS_CTRL_SHADOWED
    4'b 0111, // index[10] CLKMGR_IO_DIV2_MEAS_CTRL_SHADOWED
    4'b 0111, // index[11] CLKMGR_IO_DIV4_MEAS_CTRL_SHADOWED
    4'b 0111, // index[12] CLKMGR_MAIN_MEAS_CTRL_SHADOWED
    4'b 0111, // index[13] CLKMGR_USB_MEAS_CTRL_SHADOWED
    4'b 0011, // index[14] CLKMGR_RECOV_ERR_CODE
    4'b 0001  // index[15] CLKMGR_FATAL_ERR_CODE
  };

endpackage

