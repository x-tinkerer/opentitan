// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module otbn_reg_top (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  // Output port for window
  output tlul_pkg::tl_h2d_t tl_win_o  [2],
  input  tlul_pkg::tl_d2h_t tl_win_i  [2],

  // To HW
  output otbn_reg_pkg::otbn_reg2hw_t reg2hw, // Write
  input  otbn_reg_pkg::otbn_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o,

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import otbn_reg_pkg::* ;

  localparam int AW = 16;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;


  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );

  // also check for spurious write enables
  logic reg_we_err;
  logic [15:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(16)
  ) u_prim_reg_we_check (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .oh_i  (reg_we_check),
    .en_i  (reg_we && !addrmiss),
    .err_o (reg_we_err)
  );

  logic err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= '0;
    end else if (intg_err || reg_we_err) begin
      err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = err_q | intg_err | reg_we_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(0)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );

  tlul_pkg::tl_h2d_t tl_socket_h2d [3];
  tlul_pkg::tl_d2h_t tl_socket_d2h [3];

  logic [1:0] reg_steer;

  // socket_1n connection
  assign tl_reg_h2d = tl_socket_h2d[2];
  assign tl_socket_d2h[2] = tl_reg_d2h;

  assign tl_win_o[0] = tl_socket_h2d[0];
  assign tl_socket_d2h[0] = tl_win_i[0];
  assign tl_win_o[1] = tl_socket_h2d[1];
  assign tl_socket_d2h[1] = tl_win_i[1];

  // Create Socket_1n
  tlul_socket_1n #(
    .N            (3),
    .HReqPass     (1'b1),
    .HRspPass     (1'b1),
    .DReqPass     ({3{1'b1}}),
    .DRspPass     ({3{1'b1}}),
    .HReqDepth    (4'h0),
    .HRspDepth    (4'h0),
    .DReqDepth    ({3{4'h0}}),
    .DRspDepth    ({3{4'h0}}),
    .ExplicitErrs (1'b0)
  ) u_socket (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .tl_h_i (tl_i),
    .tl_h_o (tl_o_pre),
    .tl_d_o (tl_socket_h2d),
    .tl_d_i (tl_socket_d2h),
    .dev_select_i (reg_steer)
  );

  // Create steering logic
  always_comb begin
    reg_steer =
        tl_i.a_address[AW-1:0] inside {[16384:20479]} ? 2'd0 :
        tl_i.a_address[AW-1:0] inside {[32768:35839]} ? 2'd1 :
        // Default set to register
        2'd2;

    // Override this in case of an integrity error
    if (intg_err) begin
      reg_steer = 2'd2;
    end
  end

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(1)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );

  // cdc oversampling signals

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic [31:0] cip_id_qs;
  logic [7:0] revision_reserved_qs;
  logic [7:0] revision_subminor_qs;
  logic [7:0] revision_minor_qs;
  logic [7:0] revision_major_qs;
  logic [31:0] parameter_block_type_qs;
  logic [31:0] parameter_block_length_qs;
  logic [31:0] next_parameter_block_qs;
  logic intr_state_we;
  logic intr_state_qs;
  logic intr_state_wd;
  logic intr_enable_we;
  logic intr_enable_qs;
  logic intr_enable_wd;
  logic intr_test_we;
  logic intr_test_wd;
  logic alert_test_we;
  logic alert_test_fatal_wd;
  logic alert_test_recov_wd;
  logic cmd_we;
  logic [7:0] cmd_wd;
  logic ctrl_re;
  logic ctrl_we;
  logic ctrl_qs;
  logic ctrl_wd;
  logic [7:0] status_qs;
  logic err_bits_re;
  logic err_bits_we;
  logic err_bits_bad_data_addr_qs;
  logic err_bits_bad_data_addr_wd;
  logic err_bits_bad_insn_addr_qs;
  logic err_bits_bad_insn_addr_wd;
  logic err_bits_call_stack_qs;
  logic err_bits_call_stack_wd;
  logic err_bits_illegal_insn_qs;
  logic err_bits_illegal_insn_wd;
  logic err_bits_loop_qs;
  logic err_bits_loop_wd;
  logic err_bits_key_invalid_qs;
  logic err_bits_key_invalid_wd;
  logic err_bits_rnd_rep_chk_fail_qs;
  logic err_bits_rnd_rep_chk_fail_wd;
  logic err_bits_rnd_fips_chk_fail_qs;
  logic err_bits_rnd_fips_chk_fail_wd;
  logic err_bits_imem_intg_violation_qs;
  logic err_bits_imem_intg_violation_wd;
  logic err_bits_dmem_intg_violation_qs;
  logic err_bits_dmem_intg_violation_wd;
  logic err_bits_reg_intg_violation_qs;
  logic err_bits_reg_intg_violation_wd;
  logic err_bits_bus_intg_violation_qs;
  logic err_bits_bus_intg_violation_wd;
  logic err_bits_bad_internal_state_qs;
  logic err_bits_bad_internal_state_wd;
  logic err_bits_illegal_bus_access_qs;
  logic err_bits_illegal_bus_access_wd;
  logic err_bits_lifecycle_escalation_qs;
  logic err_bits_lifecycle_escalation_wd;
  logic err_bits_fatal_software_qs;
  logic err_bits_fatal_software_wd;
  logic fatal_alert_cause_imem_intg_violation_qs;
  logic fatal_alert_cause_dmem_intg_violation_qs;
  logic fatal_alert_cause_reg_intg_violation_qs;
  logic fatal_alert_cause_bus_intg_violation_qs;
  logic fatal_alert_cause_bad_internal_state_qs;
  logic fatal_alert_cause_illegal_bus_access_qs;
  logic fatal_alert_cause_lifecycle_escalation_qs;
  logic fatal_alert_cause_fatal_software_qs;
  logic insn_cnt_re;
  logic insn_cnt_we;
  logic [31:0] insn_cnt_qs;
  logic [31:0] insn_cnt_wd;
  logic load_checksum_re;
  logic load_checksum_we;
  logic [31:0] load_checksum_qs;
  logic [31:0] load_checksum_wd;

  // Register instances
  // R[cip_id]: V(False)
  // constant-only read
  assign cip_id_qs = 32'hf;


  // R[revision]: V(False)
  //   F[reserved]: 7:0
  // constant-only read
  assign revision_reserved_qs = 8'h0;

  //   F[subminor]: 15:8
  // constant-only read
  assign revision_subminor_qs = 8'h0;

  //   F[minor]: 23:16
  // constant-only read
  assign revision_minor_qs = 8'h0;

  //   F[major]: 31:24
  // constant-only read
  assign revision_major_qs = 8'h2;


  // R[parameter_block_type]: V(False)
  // constant-only read
  assign parameter_block_type_qs = 32'h0;


  // R[parameter_block_length]: V(False)
  // constant-only read
  assign parameter_block_length_qs = 32'hc;


  // R[next_parameter_block]: V(False)
  // constant-only read
  assign next_parameter_block_qs = 32'h0;


  // R[intr_state]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0)
  ) u_intr_state (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.de),
    .d      (hw2reg.intr_state.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_state_qs)
  );


  // R[intr_enable]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0)
  ) u_intr_enable (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_enable_we),
    .wd     (intr_enable_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_enable.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_enable_qs)
  );


  // R[intr_test]: V(True)
  logic intr_test_qe;
  logic [0:0] intr_test_flds_we;
  assign intr_test_qe = &intr_test_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[0]),
    .q      (reg2hw.intr_test.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.qe = intr_test_qe;


  // R[alert_test]: V(True)
  logic alert_test_qe;
  logic [1:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  //   F[fatal]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_fatal (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_fatal_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.fatal.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.fatal.qe = alert_test_qe;

  //   F[recov]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_recov (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_recov_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[1]),
    .q      (reg2hw.alert_test.recov.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.recov.qe = alert_test_qe;


  // R[cmd]: V(True)
  logic cmd_qe;
  logic [0:0] cmd_flds_we;
  assign cmd_qe = &cmd_flds_we;
  prim_subreg_ext #(
    .DW    (8)
  ) u_cmd (
    .re     (1'b0),
    .we     (cmd_we),
    .wd     (cmd_wd),
    .d      ('0),
    .qre    (),
    .qe     (cmd_flds_we[0]),
    .q      (reg2hw.cmd.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.cmd.qe = cmd_qe;


  // R[ctrl]: V(True)
  logic ctrl_qe;
  logic [0:0] ctrl_flds_we;
  assign ctrl_qe = &ctrl_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl (
    .re     (ctrl_re),
    .we     (ctrl_we),
    .wd     (ctrl_wd),
    .d      (hw2reg.ctrl.d),
    .qre    (),
    .qe     (ctrl_flds_we[0]),
    .q      (reg2hw.ctrl.q),
    .ds     (),
    .qs     (ctrl_qs)
  );
  assign reg2hw.ctrl.qe = ctrl_qe;


  // R[status]: V(False)
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (8'h4)
  ) u_status (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.de),
    .d      (hw2reg.status.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (status_qs)
  );


  // R[err_bits]: V(True)
  logic err_bits_qe;
  logic [15:0] err_bits_flds_we;
  assign err_bits_qe = &err_bits_flds_we;
  //   F[bad_data_addr]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_bad_data_addr (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_bad_data_addr_wd),
    .d      (hw2reg.err_bits.bad_data_addr.d),
    .qre    (),
    .qe     (err_bits_flds_we[0]),
    .q      (reg2hw.err_bits.bad_data_addr.q),
    .ds     (),
    .qs     (err_bits_bad_data_addr_qs)
  );
  assign reg2hw.err_bits.bad_data_addr.qe = err_bits_qe;

  //   F[bad_insn_addr]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_bad_insn_addr (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_bad_insn_addr_wd),
    .d      (hw2reg.err_bits.bad_insn_addr.d),
    .qre    (),
    .qe     (err_bits_flds_we[1]),
    .q      (reg2hw.err_bits.bad_insn_addr.q),
    .ds     (),
    .qs     (err_bits_bad_insn_addr_qs)
  );
  assign reg2hw.err_bits.bad_insn_addr.qe = err_bits_qe;

  //   F[call_stack]: 2:2
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_call_stack (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_call_stack_wd),
    .d      (hw2reg.err_bits.call_stack.d),
    .qre    (),
    .qe     (err_bits_flds_we[2]),
    .q      (reg2hw.err_bits.call_stack.q),
    .ds     (),
    .qs     (err_bits_call_stack_qs)
  );
  assign reg2hw.err_bits.call_stack.qe = err_bits_qe;

  //   F[illegal_insn]: 3:3
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_illegal_insn (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_illegal_insn_wd),
    .d      (hw2reg.err_bits.illegal_insn.d),
    .qre    (),
    .qe     (err_bits_flds_we[3]),
    .q      (reg2hw.err_bits.illegal_insn.q),
    .ds     (),
    .qs     (err_bits_illegal_insn_qs)
  );
  assign reg2hw.err_bits.illegal_insn.qe = err_bits_qe;

  //   F[loop]: 4:4
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_loop (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_loop_wd),
    .d      (hw2reg.err_bits.loop.d),
    .qre    (),
    .qe     (err_bits_flds_we[4]),
    .q      (reg2hw.err_bits.loop.q),
    .ds     (),
    .qs     (err_bits_loop_qs)
  );
  assign reg2hw.err_bits.loop.qe = err_bits_qe;

  //   F[key_invalid]: 5:5
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_key_invalid (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_key_invalid_wd),
    .d      (hw2reg.err_bits.key_invalid.d),
    .qre    (),
    .qe     (err_bits_flds_we[5]),
    .q      (reg2hw.err_bits.key_invalid.q),
    .ds     (),
    .qs     (err_bits_key_invalid_qs)
  );
  assign reg2hw.err_bits.key_invalid.qe = err_bits_qe;

  //   F[rnd_rep_chk_fail]: 6:6
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_rnd_rep_chk_fail (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_rnd_rep_chk_fail_wd),
    .d      (hw2reg.err_bits.rnd_rep_chk_fail.d),
    .qre    (),
    .qe     (err_bits_flds_we[6]),
    .q      (reg2hw.err_bits.rnd_rep_chk_fail.q),
    .ds     (),
    .qs     (err_bits_rnd_rep_chk_fail_qs)
  );
  assign reg2hw.err_bits.rnd_rep_chk_fail.qe = err_bits_qe;

  //   F[rnd_fips_chk_fail]: 7:7
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_rnd_fips_chk_fail (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_rnd_fips_chk_fail_wd),
    .d      (hw2reg.err_bits.rnd_fips_chk_fail.d),
    .qre    (),
    .qe     (err_bits_flds_we[7]),
    .q      (reg2hw.err_bits.rnd_fips_chk_fail.q),
    .ds     (),
    .qs     (err_bits_rnd_fips_chk_fail_qs)
  );
  assign reg2hw.err_bits.rnd_fips_chk_fail.qe = err_bits_qe;

  //   F[imem_intg_violation]: 16:16
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_imem_intg_violation (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_imem_intg_violation_wd),
    .d      (hw2reg.err_bits.imem_intg_violation.d),
    .qre    (),
    .qe     (err_bits_flds_we[8]),
    .q      (reg2hw.err_bits.imem_intg_violation.q),
    .ds     (),
    .qs     (err_bits_imem_intg_violation_qs)
  );
  assign reg2hw.err_bits.imem_intg_violation.qe = err_bits_qe;

  //   F[dmem_intg_violation]: 17:17
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_dmem_intg_violation (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_dmem_intg_violation_wd),
    .d      (hw2reg.err_bits.dmem_intg_violation.d),
    .qre    (),
    .qe     (err_bits_flds_we[9]),
    .q      (reg2hw.err_bits.dmem_intg_violation.q),
    .ds     (),
    .qs     (err_bits_dmem_intg_violation_qs)
  );
  assign reg2hw.err_bits.dmem_intg_violation.qe = err_bits_qe;

  //   F[reg_intg_violation]: 18:18
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_reg_intg_violation (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_reg_intg_violation_wd),
    .d      (hw2reg.err_bits.reg_intg_violation.d),
    .qre    (),
    .qe     (err_bits_flds_we[10]),
    .q      (reg2hw.err_bits.reg_intg_violation.q),
    .ds     (),
    .qs     (err_bits_reg_intg_violation_qs)
  );
  assign reg2hw.err_bits.reg_intg_violation.qe = err_bits_qe;

  //   F[bus_intg_violation]: 19:19
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_bus_intg_violation (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_bus_intg_violation_wd),
    .d      (hw2reg.err_bits.bus_intg_violation.d),
    .qre    (),
    .qe     (err_bits_flds_we[11]),
    .q      (reg2hw.err_bits.bus_intg_violation.q),
    .ds     (),
    .qs     (err_bits_bus_intg_violation_qs)
  );
  assign reg2hw.err_bits.bus_intg_violation.qe = err_bits_qe;

  //   F[bad_internal_state]: 20:20
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_bad_internal_state (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_bad_internal_state_wd),
    .d      (hw2reg.err_bits.bad_internal_state.d),
    .qre    (),
    .qe     (err_bits_flds_we[12]),
    .q      (reg2hw.err_bits.bad_internal_state.q),
    .ds     (),
    .qs     (err_bits_bad_internal_state_qs)
  );
  assign reg2hw.err_bits.bad_internal_state.qe = err_bits_qe;

  //   F[illegal_bus_access]: 21:21
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_illegal_bus_access (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_illegal_bus_access_wd),
    .d      (hw2reg.err_bits.illegal_bus_access.d),
    .qre    (),
    .qe     (err_bits_flds_we[13]),
    .q      (reg2hw.err_bits.illegal_bus_access.q),
    .ds     (),
    .qs     (err_bits_illegal_bus_access_qs)
  );
  assign reg2hw.err_bits.illegal_bus_access.qe = err_bits_qe;

  //   F[lifecycle_escalation]: 22:22
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_lifecycle_escalation (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_lifecycle_escalation_wd),
    .d      (hw2reg.err_bits.lifecycle_escalation.d),
    .qre    (),
    .qe     (err_bits_flds_we[14]),
    .q      (reg2hw.err_bits.lifecycle_escalation.q),
    .ds     (),
    .qs     (err_bits_lifecycle_escalation_qs)
  );
  assign reg2hw.err_bits.lifecycle_escalation.qe = err_bits_qe;

  //   F[fatal_software]: 23:23
  prim_subreg_ext #(
    .DW    (1)
  ) u_err_bits_fatal_software (
    .re     (err_bits_re),
    .we     (err_bits_we),
    .wd     (err_bits_fatal_software_wd),
    .d      (hw2reg.err_bits.fatal_software.d),
    .qre    (),
    .qe     (err_bits_flds_we[15]),
    .q      (reg2hw.err_bits.fatal_software.q),
    .ds     (),
    .qs     (err_bits_fatal_software_qs)
  );
  assign reg2hw.err_bits.fatal_software.qe = err_bits_qe;


  // R[fatal_alert_cause]: V(False)
  //   F[imem_intg_violation]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_imem_intg_violation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.imem_intg_violation.de),
    .d      (hw2reg.fatal_alert_cause.imem_intg_violation.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_imem_intg_violation_qs)
  );

  //   F[dmem_intg_violation]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_dmem_intg_violation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.dmem_intg_violation.de),
    .d      (hw2reg.fatal_alert_cause.dmem_intg_violation.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_dmem_intg_violation_qs)
  );

  //   F[reg_intg_violation]: 2:2
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_reg_intg_violation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.reg_intg_violation.de),
    .d      (hw2reg.fatal_alert_cause.reg_intg_violation.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_reg_intg_violation_qs)
  );

  //   F[bus_intg_violation]: 3:3
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_bus_intg_violation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.bus_intg_violation.de),
    .d      (hw2reg.fatal_alert_cause.bus_intg_violation.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_bus_intg_violation_qs)
  );

  //   F[bad_internal_state]: 4:4
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_bad_internal_state (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.bad_internal_state.de),
    .d      (hw2reg.fatal_alert_cause.bad_internal_state.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_bad_internal_state_qs)
  );

  //   F[illegal_bus_access]: 5:5
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_illegal_bus_access (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.illegal_bus_access.de),
    .d      (hw2reg.fatal_alert_cause.illegal_bus_access.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_illegal_bus_access_qs)
  );

  //   F[lifecycle_escalation]: 6:6
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_lifecycle_escalation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.lifecycle_escalation.de),
    .d      (hw2reg.fatal_alert_cause.lifecycle_escalation.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_lifecycle_escalation_qs)
  );

  //   F[fatal_software]: 7:7
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_fatal_alert_cause_fatal_software (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.fatal_alert_cause.fatal_software.de),
    .d      (hw2reg.fatal_alert_cause.fatal_software.d),

    // to internal hardware
    .qe     (),
    .q      (),
    .ds     (),

    // to register interface (read)
    .qs     (fatal_alert_cause_fatal_software_qs)
  );


  // R[insn_cnt]: V(True)
  logic insn_cnt_qe;
  logic [0:0] insn_cnt_flds_we;
  assign insn_cnt_qe = &insn_cnt_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_insn_cnt (
    .re     (insn_cnt_re),
    .we     (insn_cnt_we),
    .wd     (insn_cnt_wd),
    .d      (hw2reg.insn_cnt.d),
    .qre    (),
    .qe     (insn_cnt_flds_we[0]),
    .q      (reg2hw.insn_cnt.q),
    .ds     (),
    .qs     (insn_cnt_qs)
  );
  assign reg2hw.insn_cnt.qe = insn_cnt_qe;


  // R[load_checksum]: V(True)
  logic load_checksum_qe;
  logic [0:0] load_checksum_flds_we;
  assign load_checksum_qe = &load_checksum_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_load_checksum (
    .re     (load_checksum_re),
    .we     (load_checksum_we),
    .wd     (load_checksum_wd),
    .d      (hw2reg.load_checksum.d),
    .qre    (),
    .qe     (load_checksum_flds_we[0]),
    .q      (reg2hw.load_checksum.q),
    .ds     (),
    .qs     (load_checksum_qs)
  );
  assign reg2hw.load_checksum.qe = load_checksum_qe;



  logic [15:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == OTBN_CIP_ID_OFFSET);
    addr_hit[ 1] = (reg_addr == OTBN_REVISION_OFFSET);
    addr_hit[ 2] = (reg_addr == OTBN_PARAMETER_BLOCK_TYPE_OFFSET);
    addr_hit[ 3] = (reg_addr == OTBN_PARAMETER_BLOCK_LENGTH_OFFSET);
    addr_hit[ 4] = (reg_addr == OTBN_NEXT_PARAMETER_BLOCK_OFFSET);
    addr_hit[ 5] = (reg_addr == OTBN_INTR_STATE_OFFSET);
    addr_hit[ 6] = (reg_addr == OTBN_INTR_ENABLE_OFFSET);
    addr_hit[ 7] = (reg_addr == OTBN_INTR_TEST_OFFSET);
    addr_hit[ 8] = (reg_addr == OTBN_ALERT_TEST_OFFSET);
    addr_hit[ 9] = (reg_addr == OTBN_CMD_OFFSET);
    addr_hit[10] = (reg_addr == OTBN_CTRL_OFFSET);
    addr_hit[11] = (reg_addr == OTBN_STATUS_OFFSET);
    addr_hit[12] = (reg_addr == OTBN_ERR_BITS_OFFSET);
    addr_hit[13] = (reg_addr == OTBN_FATAL_ALERT_CAUSE_OFFSET);
    addr_hit[14] = (reg_addr == OTBN_INSN_CNT_OFFSET);
    addr_hit[15] = (reg_addr == OTBN_LOAD_CHECKSUM_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(OTBN_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(OTBN_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(OTBN_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(OTBN_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(OTBN_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(OTBN_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(OTBN_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(OTBN_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(OTBN_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(OTBN_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(OTBN_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(OTBN_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(OTBN_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(OTBN_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(OTBN_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(OTBN_PERMIT[15] & ~reg_be)))));
  end

  // Generate write-enables
  assign intr_state_we = addr_hit[5] & reg_we & !reg_error;

  assign intr_state_wd = reg_wdata[0];
  assign intr_enable_we = addr_hit[6] & reg_we & !reg_error;

  assign intr_enable_wd = reg_wdata[0];
  assign intr_test_we = addr_hit[7] & reg_we & !reg_error;

  assign intr_test_wd = reg_wdata[0];
  assign alert_test_we = addr_hit[8] & reg_we & !reg_error;

  assign alert_test_fatal_wd = reg_wdata[0];

  assign alert_test_recov_wd = reg_wdata[1];
  assign cmd_we = addr_hit[9] & reg_we & !reg_error;

  assign cmd_wd = reg_wdata[7:0];
  assign ctrl_re = addr_hit[10] & reg_re & !reg_error;
  assign ctrl_we = addr_hit[10] & reg_we & !reg_error;

  assign ctrl_wd = reg_wdata[0];
  assign err_bits_re = addr_hit[12] & reg_re & !reg_error;
  assign err_bits_we = addr_hit[12] & reg_we & !reg_error;

  assign err_bits_bad_data_addr_wd = reg_wdata[0];

  assign err_bits_bad_insn_addr_wd = reg_wdata[1];

  assign err_bits_call_stack_wd = reg_wdata[2];

  assign err_bits_illegal_insn_wd = reg_wdata[3];

  assign err_bits_loop_wd = reg_wdata[4];

  assign err_bits_key_invalid_wd = reg_wdata[5];

  assign err_bits_rnd_rep_chk_fail_wd = reg_wdata[6];

  assign err_bits_rnd_fips_chk_fail_wd = reg_wdata[7];

  assign err_bits_imem_intg_violation_wd = reg_wdata[16];

  assign err_bits_dmem_intg_violation_wd = reg_wdata[17];

  assign err_bits_reg_intg_violation_wd = reg_wdata[18];

  assign err_bits_bus_intg_violation_wd = reg_wdata[19];

  assign err_bits_bad_internal_state_wd = reg_wdata[20];

  assign err_bits_illegal_bus_access_wd = reg_wdata[21];

  assign err_bits_lifecycle_escalation_wd = reg_wdata[22];

  assign err_bits_fatal_software_wd = reg_wdata[23];
  assign insn_cnt_re = addr_hit[14] & reg_re & !reg_error;
  assign insn_cnt_we = addr_hit[14] & reg_we & !reg_error;

  assign insn_cnt_wd = reg_wdata[31:0];
  assign load_checksum_re = addr_hit[15] & reg_re & !reg_error;
  assign load_checksum_we = addr_hit[15] & reg_we & !reg_error;

  assign load_checksum_wd = reg_wdata[31:0];

  // Assign write-enables to checker logic vector.
  always_comb begin
    reg_we_check = '0;
    reg_we_check[0] = 1'b0;
    reg_we_check[1] = 1'b0;
    reg_we_check[2] = 1'b0;
    reg_we_check[3] = 1'b0;
    reg_we_check[4] = 1'b0;
    reg_we_check[5] = intr_state_we;
    reg_we_check[6] = intr_enable_we;
    reg_we_check[7] = intr_test_we;
    reg_we_check[8] = alert_test_we;
    reg_we_check[9] = cmd_we;
    reg_we_check[10] = ctrl_we;
    reg_we_check[11] = 1'b0;
    reg_we_check[12] = err_bits_we;
    reg_we_check[13] = 1'b0;
    reg_we_check[14] = insn_cnt_we;
    reg_we_check[15] = load_checksum_we;
  end

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[31:0] = cip_id_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[7:0] = revision_reserved_qs;
        reg_rdata_next[15:8] = revision_subminor_qs;
        reg_rdata_next[23:16] = revision_minor_qs;
        reg_rdata_next[31:24] = revision_major_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = parameter_block_type_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = parameter_block_length_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = next_parameter_block_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[0] = intr_state_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[0] = intr_enable_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[0] = '0;
      end

      addr_hit[8]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      addr_hit[9]: begin
        reg_rdata_next[7:0] = '0;
      end

      addr_hit[10]: begin
        reg_rdata_next[0] = ctrl_qs;
      end

      addr_hit[11]: begin
        reg_rdata_next[7:0] = status_qs;
      end

      addr_hit[12]: begin
        reg_rdata_next[0] = err_bits_bad_data_addr_qs;
        reg_rdata_next[1] = err_bits_bad_insn_addr_qs;
        reg_rdata_next[2] = err_bits_call_stack_qs;
        reg_rdata_next[3] = err_bits_illegal_insn_qs;
        reg_rdata_next[4] = err_bits_loop_qs;
        reg_rdata_next[5] = err_bits_key_invalid_qs;
        reg_rdata_next[6] = err_bits_rnd_rep_chk_fail_qs;
        reg_rdata_next[7] = err_bits_rnd_fips_chk_fail_qs;
        reg_rdata_next[16] = err_bits_imem_intg_violation_qs;
        reg_rdata_next[17] = err_bits_dmem_intg_violation_qs;
        reg_rdata_next[18] = err_bits_reg_intg_violation_qs;
        reg_rdata_next[19] = err_bits_bus_intg_violation_qs;
        reg_rdata_next[20] = err_bits_bad_internal_state_qs;
        reg_rdata_next[21] = err_bits_illegal_bus_access_qs;
        reg_rdata_next[22] = err_bits_lifecycle_escalation_qs;
        reg_rdata_next[23] = err_bits_fatal_software_qs;
      end

      addr_hit[13]: begin
        reg_rdata_next[0] = fatal_alert_cause_imem_intg_violation_qs;
        reg_rdata_next[1] = fatal_alert_cause_dmem_intg_violation_qs;
        reg_rdata_next[2] = fatal_alert_cause_reg_intg_violation_qs;
        reg_rdata_next[3] = fatal_alert_cause_bus_intg_violation_qs;
        reg_rdata_next[4] = fatal_alert_cause_bad_internal_state_qs;
        reg_rdata_next[5] = fatal_alert_cause_illegal_bus_access_qs;
        reg_rdata_next[6] = fatal_alert_cause_lifecycle_escalation_qs;
        reg_rdata_next[7] = fatal_alert_cause_fatal_software_qs;
      end

      addr_hit[14]: begin
        reg_rdata_next[31:0] = insn_cnt_qs;
      end

      addr_hit[15]: begin
        reg_rdata_next[31:0] = load_checksum_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // shadow busy
  logic shadow_busy;
  assign shadow_busy = 1'b0;

  // register busy
  assign reg_busy = shadow_busy;

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule
