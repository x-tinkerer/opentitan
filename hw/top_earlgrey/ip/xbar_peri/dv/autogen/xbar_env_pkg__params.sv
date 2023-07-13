// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `tlgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"uart0", '{
        '{32'h40000000, 32'h4000007f}
    }},
    '{"uart1", '{
        '{32'h40010000, 32'h4001007f}
    }},
    '{"uart2", '{
        '{32'h40020000, 32'h4002007f}
    }},
    '{"uart3", '{
        '{32'h40030000, 32'h4003007f}
    }},
    '{"i2c0", '{
        '{32'h40080000, 32'h400800ff}
    }},
    '{"i2c1", '{
        '{32'h40090000, 32'h400900ff}
    }},
    '{"i2c2", '{
        '{32'h400a0000, 32'h400a00ff}
    }},
    '{"pattgen", '{
        '{32'h400e0000, 32'h400e007f}
    }},
    '{"pwm_aon", '{
        '{32'h40450000, 32'h404500ff}
    }},
    '{"gpio", '{
        '{32'h40040000, 32'h4004007f}
    }},
    '{"spi_device", '{
        '{32'h40050000, 32'h40051fff}
    }},
    '{"rv_timer", '{
        '{32'h40100000, 32'h401001ff}
    }},
    '{"pwrmgr_aon", '{
        '{32'h40400000, 32'h404000ff}
    }},
    '{"rstmgr_aon", '{
        '{32'h40410000, 32'h404100ff}
    }},
    '{"clkmgr_aon", '{
        '{32'h40420000, 32'h404200ff}
    }},
    '{"pinmux_aon", '{
        '{32'h40460000, 32'h40460fff}
    }},
    '{"otp_ctrl__core", '{
        '{32'h40130000, 32'h40131fff}
    }},
    '{"otp_ctrl__prim", '{
        '{32'h40132000, 32'h4013201f}
    }},
    '{"lc_ctrl", '{
        '{32'h40140000, 32'h401400ff}
    }},
    '{"sensor_ctrl_aon", '{
        '{32'h40490000, 32'h4049007f}
    }},
    '{"alert_handler", '{
        '{32'h40150000, 32'h401507ff}
    }},
    '{"sram_ctrl_ret_aon__regs", '{
        '{32'h40500000, 32'h4050007f}
    }},
    '{"sram_ctrl_ret_aon__ram", '{
        '{32'h40600000, 32'h40600fff}
    }},
    '{"aon_timer_aon", '{
        '{32'h40470000, 32'h4047007f}
    }},
    '{"sysrst_ctrl_aon", '{
        '{32'h40430000, 32'h404300ff}
    }},
    '{"adc_ctrl_aon", '{
        '{32'h40440000, 32'h404400ff}
    }},
    '{"ast", '{
        '{32'h40480000, 32'h404803ff}
}}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"main", 0, '{
        "uart0",
        "uart1",
        "uart2",
        "uart3",
        "i2c0",
        "i2c1",
        "i2c2",
        "pattgen",
        "gpio",
        "spi_device",
        "rv_timer",
        "pwrmgr_aon",
        "rstmgr_aon",
        "clkmgr_aon",
        "pinmux_aon",
        "otp_ctrl__core",
        "otp_ctrl__prim",
        "lc_ctrl",
        "sensor_ctrl_aon",
        "alert_handler",
        "ast",
        "sram_ctrl_ret_aon__ram",
        "sram_ctrl_ret_aon__regs",
        "aon_timer_aon",
        "adc_ctrl_aon",
        "sysrst_ctrl_aon",
        "pwm_aon"}}
};
