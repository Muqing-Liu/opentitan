// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

interface pwm_if #(
  parameter NumPwmChannels = 6
);
  // core clock
  logic clk_core;
  logic rst_core_n;

  logic [NumPwmChannels-1:0] pwm;

endinterface : pwm_if
