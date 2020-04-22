-------------------------------------------------------------------------------
-- This-------------------------------------------------------------------------------
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
------------------------------------------------------------------------------- 
library work;
use work.esistream_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_check_aq600 is
  generic(
    NB_LANES : natural
    );
  port (
    rst        : in  std_logic;                              -- Active high reset. Allow to start test after lanes synchronized.
    clk        : in  std_logic;                              -- Receiver clock output.
    frame_out  : in  rx_frame_array(NB_LANES-1 downto 0);    -- Decoded output data + clk bit + disparity bit array
    --data_out   : in  rx_data_array(NB_LANES-1 downto 0);     -- Decoded output data only array
    valid_out  : in  std_logic_vector(NB_LANES-1 downto 0);  -- Active high when frame_out and data_out are valid
    ber_status : out std_logic;                              -- Active high bit error detected.
    cb_status  : out std_logic                               -- Active high clock bit error detected.
    );
end entity rx_check_aq600;

architecture rtl of rx_check_aq600 is

  constant BER_NO_ERROR    : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  constant CB_NO_ERROR     : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  constant RAMP_DATA_WIDTH : natural                                      := 12;
  constant STEP            : std_logic_vector(RAMP_DATA_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(DESER_WIDTH/8, RAMP_DATA_WIDTH));
  --
  type ramp_array is array (natural range <>) of slv_12_array_n(DESER_WIDTH/16-1 downto 0);
  type ramp_uarray is array (natural range <>) of uns_12_array_n(DESER_WIDTH/16-1 downto 0);
  --
  signal valid_d           : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  signal valid_q           : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  signal ber               : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  signal cb                : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  signal frame_out_d       : rx_frame_array(NB_LANES-1 downto 0)          := (others => (others => (others => '0')));
  --signal data_out_d        : rx_data_array(NB_LANES-1 downto 0)           := (others => (others => (others => '0')));
  signal valid_out_d       : std_logic_vector(NB_LANES-1 downto 0)        := (others => '0');
  -- unsigned array:
  signal u_data_d          : ramp_uarray(NB_LANES-1 downto 0)             := (others => (others => (others => '0')));
  -- std_logic_vector array:
  signal data_out_qdl      : ramp_array(NB_lANES-1 downto 0)              := (others => (others => (others => '0')));
  signal data_a            : ramp_array(NB_lANES-1 downto 0)              := (others => (others => (others => '0')));
  --signal data_s            : ramp_array(NB_lANES-1 downto 0)              := (others => (others => (others => '0')));
  signal u_data_out_qdl    : ramp_uarray(NB_LANES-1 downto 0)             := (others => (others => (others => '0')));
  signal u_data_a          : ramp_uarray(NB_LANES-1 downto 0)             := (others => (others => (others => '0')));
  --signal u_data_s          : ramp_uarray(NB_LANES-1 downto 0)             := (others => (others => (others => '0')));

--
begin

  process(clk)
  begin
    if rising_edge(clk) then
      frame_out_d <= frame_out;
      --data_out_d  <= data_out;
      valid_out_d <= valid_out;
    end if;
  end process;

  delay_slv_1 : entity work.delay_slv
    generic map (
      DATA_WIDTH => NB_LANES,
      LATENCY    => 2)
    port map (
      clk => clk,
      d   => valid_out,
      q   => valid_q);

  --! @brief: Compare current value to calculated value from previous value to detect a bit error.
  ber_gen : for index_lane in 0 to (NB_LANES - 1) generate
    signal sb_ber : std_logic_vector(DESER_WIDTH/16-1 downto 0);
  begin

    dl_gen : for idx in 0 to DESER_WIDTH/16-1 generate

      delay_slv_2 : entity work.delay_slv
        generic map (
          DATA_WIDTH => RAMP_DATA_WIDTH,
          LATENCY    => 1)
        port map (
          clk => clk,
          d   => frame_out_d(index_lane)(idx)(RAMP_DATA_WIDTH-1 downto 0),
          q   => data_out_qdl(index_lane)(idx));
      u_data_out_qdl(index_lane)(idx) <= unsigned(data_out_qdl(index_lane)(idx));

      adder_1 : entity work.add_u12
        port map(
          A   => frame_out_d(index_lane)(idx)(RAMP_DATA_WIDTH-1 downto 0),
          B   => STEP,
          CLK => clk,
          S   => data_a(index_lane)(idx));

      --subtract_1 : entity work.sub_u12
      --  port map(
      --    A   => frame_out_d(index_lane)(idx)(RAMP_DATA_WIDTH-1 downto 0),
      --    B   => STEP,
      --    CLK => clk,
      --    CE  => '1',
      --    S   => data_s(index_lane)(idx));

      u_data_a(index_lane)(idx) <= unsigned(data_a(index_lane)(idx));
      --u_data_s(index_lane)(idx) <= unsigned(data_s(index_lane)(idx));

    end generate dl_gen;

    process(clk)
    begin
      if rising_edge(clk) then
        if valid_q(index_lane) = '0' then sb_ber <= (others => '0');
        else
          for idx in 0 to DESER_WIDTH/16-1 loop
            if u_data_a(index_lane)(idx) = u_data_out_qdl(index_lane)(idx) then
              sb_ber(idx) <= '0';
            else
              sb_ber(idx) <= '1';
            end if;
          end loop;
        end if;
      end if;
    end process;
    ber(index_lane) <= or1(sb_ber);
  end generate ber_gen;

--! @brief: BER status should be reset to indicate a correct status.
--! When a bit error on useful data (14-bit) is detected, then ber_status is set to 1 until reset.
  p_ber_status : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ber_status <= '0';
      elsif ber /= BER_NO_ERROR then
        ber_status <= '1';
      -- else memorize value;
      end if;
    end if;
  end process;

  cb_gen : for index in 0 to (NB_LANES - 1) generate
  begin
    cb_p : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          cb(index) <= '0';
        else
          if frame_out_d(index)(1)(14) = frame_out_d(index)(0)(14) then
            cb(index) <= '1';  -- clock bit error
          else
            cb(index) <= '0';  -- clock bit ok 
          end if;
        end if;
      end if;
    end process;
  end generate;

  --! @brief: clock bit (CB) status should be reset to indicate a correct status.
  --! When a clock bit error is detected, then cb_status is set to 1 until reset.
  p_cb_status : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cb_status <= '0';
      elsif cb /= CB_NO_ERROR then
        cb_status <= '1';
      -- else memorize value;
      end if;
    end if;
  end process;

end architecture rtl;
