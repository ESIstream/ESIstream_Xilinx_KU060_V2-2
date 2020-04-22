###############################################################################
# Alpha data board & bitstream configuration
###############################################################################
# Configuration from SPI Flash as per XAPP1233
# Enable bitstream compression
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

# Don't pull unused pins up or down
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullnone [current_design]

# Set CFGBVS to GND to match schematics
set_property CFGBVS GND [current_design]

# Set CONFIG_VOLTAGE to 1.8V to match schematics
set_property CONFIG_VOLTAGE 1.8 [current_design]

# Set safety trigger to power down FPGA at 125degC
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable [current_design]

###############################################################################
# Timings
###############################################################################
create_clock -period 5.120 -name clk_mgtref -waveform {0.000 2.560} [get_ports sso_p]

###############################################################################
# IOs constraints
###############################################################################

set_property PACKAGE_PIN AH9 [get_ports sso_n]
set_property PACKAGE_PIN AH10 [get_ports sso_p]

# AQ600 HSSL Mapping:
#set_property PACKAGE_PIN AJ4 [get_ports {ASLp[0]}]
#set_property PACKAGE_PIN AJ3 [get_ports {ASLn[0]}]
#set_property PACKAGE_PIN AH2 [get_ports {ASLp[1]}]
#set_property PACKAGE_PIN AH1 [get_ports {ASLn[1]}]
#set_property PACKAGE_PIN AL4 [get_ports {BSLp[0]}]
#set_property PACKAGE_PIN AL3 [get_ports {BSLn[0]}]
#set_property PACKAGE_PIN AK2 [get_ports {BSLp[1]}]
#set_property PACKAGE_PIN AK1 [get_ports {BSLn[1]}]
#set_property PACKAGE_PIN AD2 [get_ports {CSLp[0]}]
#set_property PACKAGE_PIN AD1 [get_ports {CSLn[0]}]
#set_property PACKAGE_PIN AF2 [get_ports {CSLp[1]}]
#set_property PACKAGE_PIN AF1 [get_ports {CSLn[1]}]
#set_property PACKAGE_PIN AG4 [get_ports {DSLp[0]}]
#set_property PACKAGE_PIN AG3 [get_ports {DSLn[0]}]
#set_property PACKAGE_PIN AC4 [get_ports {DSLp[1]}]
#set_property PACKAGE_PIN AC3 [get_ports {DSLn[1]}]

set_property PACKAGE_PIN AJ4 [get_ports {rxp[2]}]
set_property PACKAGE_PIN AJ3 [get_ports {rxn[2]}]
set_property PACKAGE_PIN AH2 [get_ports {rxp[3]}]
set_property PACKAGE_PIN AH1 [get_ports {rxn[3]}]
set_property PACKAGE_PIN AL4 [get_ports {rxp[0]}]
set_property PACKAGE_PIN AL3 [get_ports {rxn[0]}]
set_property PACKAGE_PIN AK2 [get_ports {rxp[1]}]
set_property PACKAGE_PIN AK1 [get_ports {rxn[1]}]
set_property PACKAGE_PIN AD2 [get_ports {rxp[6]}]
set_property PACKAGE_PIN AD1 [get_ports {rxn[6]}]
set_property PACKAGE_PIN AF2 [get_ports {rxp[5]}]
set_property PACKAGE_PIN AF1 [get_ports {rxn[5]}]
set_property PACKAGE_PIN AG4 [get_ports {rxp[4]}]
set_property PACKAGE_PIN AG3 [get_ports {rxn[4]}]
set_property PACKAGE_PIN AC4 [get_ports {rxp[7]}]
set_property PACKAGE_PIN AC3 [get_ports {rxn[7]}]

#set_property package_pin AL3 [get_ports gthrxn_in[0]]
#set_property package_pin AL4 [get_ports gthrxp_in[0]]
#set_property package_pin AL7 [get_ports gthtxn_out[0]]
#set_property package_pin AL8 [get_ports gthtxp_out[0]]

#set_property package_pin AK1 [get_ports gthrxn_in[1]]
#set_property package_pin AK2 [get_ports gthrxp_in[1]]
#set_property package_pin AK5 [get_ports gthtxn_out[1]]
#set_property package_pin AK6 [get_ports gthtxp_out[1]]

#set_property package_pin AJ3 [get_ports gthrxn_in[2]]
#set_property package_pin AJ4 [get_ports gthrxp_in[2]]
#set_property package_pin AJ7 [get_ports gthtxn_out[2]]
#set_property package_pin AJ8 [get_ports gthtxp_out[2]]

#set_property package_pin AH1 [get_ports gthrxn_in[3]]
#set_property package_pin AH2 [get_ports gthrxp_in[3]]
#set_property package_pin AH5 [get_ports gthtxn_out[3]]
#set_property package_pin AH6 [get_ports gthtxp_out[3]]

#set_property package_pin AG3 [get_ports gthrxn_in[4]]
#set_property package_pin AG4 [get_ports gthrxp_in[4]]
#set_property package_pin AG7 [get_ports gthtxn_out[4]]
#set_property package_pin AG8 [get_ports gthtxp_out[4]]

#set_property package_pin AF1 [get_ports gthrxn_in[5]]
#set_property package_pin AF2 [get_ports gthrxp_in[5]]
#set_property package_pin AF5 [get_ports gthtxn_out[5]]
#set_property package_pin AF6 [get_ports gthtxp_out[5]]

#set_property package_pin AD1 [get_ports gthrxn_in[6]]
#set_property package_pin AD2 [get_ports gthrxp_in[6]]
#set_property package_pin AE3 [get_ports gthtxn_out[6]]
#set_property package_pin AE4 [get_ports gthtxp_out[6]]

#set_property package_pin AC3 [get_ports gthrxn_in[7]]
#set_property package_pin AC4 [get_ports gthrxp_in[7]]
#set_property package_pin AD5 [get_ports gthtxn_out[7]]
#set_property package_pin AD6 [get_ports gthtxp_out[7]]

set_property IOSTANDARD LVDS [get_ports aq600_synco_p]
set_property PACKAGE_PIN G37 [get_ports aq600_synco_p]
set_property PACKAGE_PIN F37 [get_ports aq600_synco_n]
set_property IOSTANDARD LVDS [get_ports aq600_synctrig_p]
set_property PACKAGE_PIN K28 [get_ports aq600_synctrig_p]
set_property PACKAGE_PIN J28 [get_ports aq600_synctrig_n]

set_property PACKAGE_PIN AM34 [get_ports aq600_rstn]
set_property PACKAGE_PIN AM35 [get_ports spi_sclk]
set_property PACKAGE_PIN AL34 [get_ports spi_csn]
set_property PACKAGE_PIN AR33 [get_ports CSN_PLL]
set_property PACKAGE_PIN AL35 [get_ports spi_mosi]
set_property PACKAGE_PIN P26 [get_ports spi_miso]
set_property PACKAGE_PIN AK37 [get_ports PLL_LOCK]

set_property IOSTANDARD LVCMOS18 [get_ports aq600_rstn]
set_property IOSTANDARD LVCMOS18 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS18 [get_ports spi_csn]
set_property IOSTANDARD LVCMOS18 [get_ports CSN_PLL]
set_property IOSTANDARD LVCMOS18 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS18 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS18 [get_ports PLL_LOCK]

# PL system clock:
set_property IOSTANDARD DIFF_HSTL_I [get_ports FABRIC_CLK_P]

set_property PACKAGE_PIN H19 [get_ports FABRIC_CLK_P]
set_property PACKAGE_PIN G19 [get_ports FABRIC_CLK_N]
set_property IOSTANDARD DIFF_HSTL_I [get_ports FABRIC_CLK_N]

create_clock -period 5.000 -name FABRIC_CLK_P [get_ports FABRIC_CLK_P]

set_property IOSTANDARD LVCMOS18 [get_ports {led_usr[*]}]
set_property PACKAGE_PIN AR25 [get_ports {led_usr[0]}]
set_property PACKAGE_PIN AP25 [get_ports {led_usr[1]}]
set_property PACKAGE_PIN AG25 [get_ports {led_usr[2]}]
set_property PACKAGE_PIN AF25 [get_ports {led_usr[3]}]
set_property PACKAGE_PIN AD26 [get_ports {led_usr[4]}]
set_property PACKAGE_PIN AE26 [get_ports {led_usr[5]}]
set_property PACKAGE_PIN AE27 [get_ports {led_usr[6]}]
set_property PACKAGE_PIN AF27 [get_ports {led_usr[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS18 [get_ports UART_TX]
set_property PACKAGE_PIN AR28 [get_ports UART_RX]
set_property PACKAGE_PIN AT28 [get_ports UART_TX]

set_property IOSTANDARD LVCMOS18 [get_ports gpio_j20_2]
set_property IOSTANDARD LVCMOS18 [get_ports gpio_j20_4]
set_property IOSTANDARD LVCMOS18 [get_ports gpio_j20_6]
set_property IOSTANDARD LVCMOS18 [get_ports gpio_j20_8]
set_property IOSTANDARD LVCMOS18 [get_ports gpio_j20_10]
set_property PACKAGE_PIN AU25 [get_ports gpio_j20_2]
set_property PACKAGE_PIN AU26 [get_ports gpio_j20_4]
set_property PACKAGE_PIN AJ25 [get_ports gpio_j20_6]
set_property PACKAGE_PIN AK25 [get_ports gpio_j20_8]
set_property PACKAGE_PIN AH26 [get_ports gpio_j20_10]

set_false_path -from [get_clocks clk_out1_clk_wiz_frame_clk] -to [get_clocks clk_out1_clk_wiz_0]
set_false_path -from [get_clocks clk_out1_clk_wiz_0] -to [get_clocks clk_out1_clk_wiz_frame_clk]
set_false_path -from [get_clocks {rxoutclk_out[3]_1}] -to [get_clocks clk_out1_clk_wiz_0]
set_false_path -from [get_clocks clk_out1_clk_wiz_0] -to [get_clocks {rxoutclk_out[3]_1}]
set_false_path -from [get_clocks {rxoutclk_out[3]_1}] -to [get_clocks clk_out1_clk_wiz_frame_clk]
set_false_path -from [get_clocks clk_out1_clk_wiz_frame_clk] -to [get_clocks {rxoutclk_out[3]_1}]

#set_false_path -from [get_clocks rx_usrclk] -to [get_clocks clk_out1_clk_wiz_0]
#set_false_path -from [get_clocks clk_out1_clk_wiz_0] -to [get_clocks rx_usrclk]
#set_false_path -from [get_clocks clk_out1_clk_wiz_frame_clk] -to [get_clocks rx_usrclk]
#set_false_path -from [get_clocks rx_usrclk] -to [get_clocks clk_out1_clk_wiz_frame_clk]

# Path clk_out1_clk_wiz_frame_clk to rx_usrclk:
# #################################
# Path 1 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[0].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 2 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[1].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 3 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[2].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 4 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[3].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 5 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[4].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 6 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[5].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 7 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[6].rx_lane_decoding_1/rst_logic_2d_reg/D 6
# Path 8 sync_generator_1/synctrig_re_o_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[7].rx_lane_decoding_1/sync_d_reg/D 3
# Path 9 gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/i_rx_control/rst_esistream_reg/C gen_esistream_hdl.rx_esistream_inst/i_rx_esistream/lane_decoding_gen[7].rx_lane_decoding_1/rst_logic_2d_reg/D 6


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list gen_esistream_hdl.rx_esistream_inst/i_rx_xcvr_wrapper/i_mmcm_frame_clk/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 12 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {data_out_12b[2][0][0]} {data_out_12b[2][0][1]} {data_out_12b[2][0][2]} {data_out_12b[2][0][3]} {data_out_12b[2][0][4]} {data_out_12b[2][0][5]} {data_out_12b[2][0][6]} {data_out_12b[2][0][7]} {data_out_12b[2][0][8]} {data_out_12b[2][0][9]} {data_out_12b[2][0][10]} {data_out_12b[2][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 12 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {data_out_12b[0][0][0]} {data_out_12b[0][0][1]} {data_out_12b[0][0][2]} {data_out_12b[0][0][3]} {data_out_12b[0][0][4]} {data_out_12b[0][0][5]} {data_out_12b[0][0][6]} {data_out_12b[0][0][7]} {data_out_12b[0][0][8]} {data_out_12b[0][0][9]} {data_out_12b[0][0][10]} {data_out_12b[0][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 12 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {data_out_12b[3][0][0]} {data_out_12b[3][0][1]} {data_out_12b[3][0][2]} {data_out_12b[3][0][3]} {data_out_12b[3][0][4]} {data_out_12b[3][0][5]} {data_out_12b[3][0][6]} {data_out_12b[3][0][7]} {data_out_12b[3][0][8]} {data_out_12b[3][0][9]} {data_out_12b[3][0][10]} {data_out_12b[3][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 12 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {data_out_12b[3][1][0]} {data_out_12b[3][1][1]} {data_out_12b[3][1][2]} {data_out_12b[3][1][3]} {data_out_12b[3][1][4]} {data_out_12b[3][1][5]} {data_out_12b[3][1][6]} {data_out_12b[3][1][7]} {data_out_12b[3][1][8]} {data_out_12b[3][1][9]} {data_out_12b[3][1][10]} {data_out_12b[3][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 12 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {data_out_12b[2][1][0]} {data_out_12b[2][1][1]} {data_out_12b[2][1][2]} {data_out_12b[2][1][3]} {data_out_12b[2][1][4]} {data_out_12b[2][1][5]} {data_out_12b[2][1][6]} {data_out_12b[2][1][7]} {data_out_12b[2][1][8]} {data_out_12b[2][1][9]} {data_out_12b[2][1][10]} {data_out_12b[2][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 12 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {data_out_12b[4][0][0]} {data_out_12b[4][0][1]} {data_out_12b[4][0][2]} {data_out_12b[4][0][3]} {data_out_12b[4][0][4]} {data_out_12b[4][0][5]} {data_out_12b[4][0][6]} {data_out_12b[4][0][7]} {data_out_12b[4][0][8]} {data_out_12b[4][0][9]} {data_out_12b[4][0][10]} {data_out_12b[4][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 12 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {data_out_12b[5][1][0]} {data_out_12b[5][1][1]} {data_out_12b[5][1][2]} {data_out_12b[5][1][3]} {data_out_12b[5][1][4]} {data_out_12b[5][1][5]} {data_out_12b[5][1][6]} {data_out_12b[5][1][7]} {data_out_12b[5][1][8]} {data_out_12b[5][1][9]} {data_out_12b[5][1][10]} {data_out_12b[5][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 12 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {data_out_12b[1][0][0]} {data_out_12b[1][0][1]} {data_out_12b[1][0][2]} {data_out_12b[1][0][3]} {data_out_12b[1][0][4]} {data_out_12b[1][0][5]} {data_out_12b[1][0][6]} {data_out_12b[1][0][7]} {data_out_12b[1][0][8]} {data_out_12b[1][0][9]} {data_out_12b[1][0][10]} {data_out_12b[1][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 12 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {data_out_12b[6][0][0]} {data_out_12b[6][0][1]} {data_out_12b[6][0][2]} {data_out_12b[6][0][3]} {data_out_12b[6][0][4]} {data_out_12b[6][0][5]} {data_out_12b[6][0][6]} {data_out_12b[6][0][7]} {data_out_12b[6][0][8]} {data_out_12b[6][0][9]} {data_out_12b[6][0][10]} {data_out_12b[6][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 12 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {data_out_12b[6][1][0]} {data_out_12b[6][1][1]} {data_out_12b[6][1][2]} {data_out_12b[6][1][3]} {data_out_12b[6][1][4]} {data_out_12b[6][1][5]} {data_out_12b[6][1][6]} {data_out_12b[6][1][7]} {data_out_12b[6][1][8]} {data_out_12b[6][1][9]} {data_out_12b[6][1][10]} {data_out_12b[6][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 12 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {data_out_12b[5][0][0]} {data_out_12b[5][0][1]} {data_out_12b[5][0][2]} {data_out_12b[5][0][3]} {data_out_12b[5][0][4]} {data_out_12b[5][0][5]} {data_out_12b[5][0][6]} {data_out_12b[5][0][7]} {data_out_12b[5][0][8]} {data_out_12b[5][0][9]} {data_out_12b[5][0][10]} {data_out_12b[5][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 12 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {data_out_12b[7][0][0]} {data_out_12b[7][0][1]} {data_out_12b[7][0][2]} {data_out_12b[7][0][3]} {data_out_12b[7][0][4]} {data_out_12b[7][0][5]} {data_out_12b[7][0][6]} {data_out_12b[7][0][7]} {data_out_12b[7][0][8]} {data_out_12b[7][0][9]} {data_out_12b[7][0][10]} {data_out_12b[7][0][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 12 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {data_out_12b[7][1][0]} {data_out_12b[7][1][1]} {data_out_12b[7][1][2]} {data_out_12b[7][1][3]} {data_out_12b[7][1][4]} {data_out_12b[7][1][5]} {data_out_12b[7][1][6]} {data_out_12b[7][1][7]} {data_out_12b[7][1][8]} {data_out_12b[7][1][9]} {data_out_12b[7][1][10]} {data_out_12b[7][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 12 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {data_out_12b[0][1][0]} {data_out_12b[0][1][1]} {data_out_12b[0][1][2]} {data_out_12b[0][1][3]} {data_out_12b[0][1][4]} {data_out_12b[0][1][5]} {data_out_12b[0][1][6]} {data_out_12b[0][1][7]} {data_out_12b[0][1][8]} {data_out_12b[0][1][9]} {data_out_12b[0][1][10]} {data_out_12b[0][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 12 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {data_out_12b[1][1][0]} {data_out_12b[1][1][1]} {data_out_12b[1][1][2]} {data_out_12b[1][1][3]} {data_out_12b[1][1][4]} {data_out_12b[1][1][5]} {data_out_12b[1][1][6]} {data_out_12b[1][1][7]} {data_out_12b[1][1][8]} {data_out_12b[1][1][9]} {data_out_12b[1][1][10]} {data_out_12b[1][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 12 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {data_out_12b[4][1][0]} {data_out_12b[4][1][1]} {data_out_12b[4][1][2]} {data_out_12b[4][1][3]} {data_out_12b[4][1][4]} {data_out_12b[4][1][5]} {data_out_12b[4][1][6]} {data_out_12b[4][1][7]} {data_out_12b[4][1][8]} {data_out_12b[4][1][9]} {data_out_12b[4][1][10]} {data_out_12b[4][1][11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 8 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {valid_out[0]} {valid_out[1]} {valid_out[2]} {valid_out[3]} {valid_out[4]} {valid_out[5]} {valid_out[6]} {valid_out[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list ber_status]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list cb_status]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list lanes_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list sync_in]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets p_3_out]
