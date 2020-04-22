-------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or distribute
-- this software, either in source code form or as a compiled bitstream, for 
-- any purpose, commercial or non-commercial, and by any means.
--
-- In jurisdictions that recognize copyright laws, the author or authors of 
-- this software dedicate any and all copyright interest in the software to 
-- the public domain. We make this dedication for the benefit of the public at
-- large and to the detriment of our heirs and successors. We intend this 
-- dedication to be an overt act of relinquishment in perpetuity of all present
-- and future rights to this software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- THIS DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES. 
-------------------------------------------------------------------------------
-- Version      Date            Author       Description
-- 1.0          2019            Teledyne e2v Creation
-- 1.1          2019            REFLEXCES    FPGA target migration, 64-bit data path
-------------------------------------------------------------------------------
-- Description :
-- Manages and monitors sync, transceiver PLL(s) lock, reset, reset
-- done, user ready and ip ready signals. 
-------------------------------------------------------------------------------

library work;
use work.esistream_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_control is
  generic(
    NB_LANES   : natural := 4
    );
  port (
    rst             : in  std_logic;                              -- Reset asked by user, asynchronous active on falling edge
    clk_acq         : in  std_logic;
    rx_usrclk       : in  std_logic;
    pll_lock        : in  std_logic_vector(NB_LANES-1 downto 0);  -- Indicates whether GTH CPLL is locked
    rst_done        : in  std_logic_vector(NB_LANES-1 downto 0);  -- Indicates that GTH is ready
    sync_in         : in  std_logic;                              -- Pulse start synchronization demand
    sync_esistream  : out std_logic;
    rst_esistream   : out std_logic;                              -- Reset logic FPGA, active high
    rst_transceiver : out std_logic;                              -- Reset GTH, active high
    ip_ready        : out std_logic                               -- Indicates that IP is ready if driven high
    );
end entity rx_control;

architecture rtl of rx_control is

  constant ALL_ONE_RISING_EDGE  : std_logic_vector(1 downto 0)          := "01";
  constant SLV_NB_LANES_ALL_ONE : std_logic_vector(NB_LANES-1 downto 0) := (others => '1');
  signal rst_rs                 : std_logic                             := '0';
  signal lock                   : std_logic                             := '0';
  signal lock_sr                : std_logic_vector(1 downto 0)          := "00";
  signal sync_d                 : std_logic                             := '0';
  signal sync_esistream_t       : std_logic                             := '0';
  signal rst_esistream_t        : std_logic                             := '0';

begin

  -- clk_acq domain
  
  process(clk_acq)
  begin
    if rising_edge(clk_acq) then
      sync_d           <= sync_in;
      sync_esistream_t <= sync_d or sync_in;
    end if;
  end process;

  -- rx_usrclk domain
  
  ff_synchronizer_array_1 : entity work.ff_synchronizer_array
    generic map (
      REG_WIDTH => 2)
    port map (
      clk          => rx_usrclk,
      reg_async(0) => sync_esistream_t,  -- acq_clk domain
      reg_async(1) => rst,
      reg_sync(0)  => sync_esistream,    -- clk domain rx_usrclk
      reg_sync(1)  => rst_rs);           -- clk domain rx_usrclk

  -- rx_usrclk domain
  
  lock            <= '1' when pll_lock = SLV_NB_LANES_ALL_ONE                                     else '0';
  ip_ready        <= '1' when rst_done = SLV_NB_LANES_ALL_ONE and pll_lock = SLV_NB_LANES_ALL_ONE else '0';
  rst_transceiver <= rst_rs or (not lock);

  p_transceiver_pll_lock : process(rx_usrclk)
  begin
    if rising_edge(rx_usrclk) then
      if lock = '1' then
        lock_sr(0) <= '1';
      else
        lock_sr(0) <= '0';
      end if;
      lock_sr(1) <= lock_sr(0);
    end if;
  end process;

  process(rx_usrclk)
  begin
    if rising_edge(rx_usrclk) then
      if lock_sr = ALL_ONE_RISING_EDGE then
        rst_esistream <= '1';
      else
        rst_esistream <= '0';
      end if;
    end if;
  end process;

end architecture rtl;
