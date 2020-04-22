# -------------------------------------------------------------------------------
# -- This is free and unencumbered software released into the public domain.
# --
# -- Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# -- this software, either in source code form or as a compiled bitstream, for 
# -- any purpose, commercial or non-commercial, and by any means.
# --
# -- In jurisdictions that recognize copyright laws, the author or authors of 
# -- this software dedicate any and all copyright interest in the software to 
# -- the public domain. We make this dedication for the benefit of the public at
# -- large and to the detriment of our heirs and successors. We intend this 
# -- dedication to be an overt act of relinquishment in perpetuity of all present
# -- and future rights to this software under copyright law.
# --
# -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# -- AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
# -- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# -- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# --
# -- THIS DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES. 
# -------------------------------------------------------------------------------
set gt_udw 64b 
set fpga_ref xcku060-ffva1517-1-c
set project_name vivado_rx_aq600_64b
set path_file [ dict get [ info frame 0 ] file ]
set path_src [string trimright $path_file "/script_64b.tcl"]
set path_project C:/vw/xilinx_ku060_v2-2/$project_name
set path_src_ip $path_src/../src_ip
set path_src_common $path_src/../src_common
set path_src_pkg $path_src/../src_pkg
set path_src_rx $path_src/../src_rx
set path_src_rx_ip $path_src/../src_rx_ip
set path_src_tx $path_src/../src_tx
set path_src_tx_emulator $path_src/../src_tx_emulator
set path_src_tb_top $path_src/src_tb_top
set path_src_top $path_src/src_top
set path_xdc $path_src/xdc

# Create project
create_project -name $project_name -dir $path_project
set_property part $fpga_ref [current_project]
set_property target_language vhdl [current_project]

# Import ip:
set ip_files [list \
 gth_8lanes_64b\
 output_buffer\
 axi_uartlite_0\
 clk_wiz_0\
 add_u12\
]

foreach ip_file $ip_files {
 import_ip $path_src_ip/$ip_file.xci
 reset_target {all} [get_ips $ip_file]
 generate_target {all} [get_ips $ip_file]
}

# Add vhdl files 
add_files $path_src_top/
add_files $path_src_common/
add_files $path_src_rx/
add_files $path_src_rx_ip/rx_xcvr_wrapper_64b.vhd
add_files $path_src_rx_ip/rx_output_buffer_wrapper.vhd
add_files $path_src_pkg/esistream_pkg_64b.vhd
set_property top rx_esistream_top [current_fileset]

add_files -fileset sim_1 -norecurse $path_src_tb_top/
add_files -fileset sim_1 -norecurse $path_src_tx_emulator/
# Add xdc source file
add_files -fileset constrs_1 $path_xdc/rx_esistream_top_64b.xdc
