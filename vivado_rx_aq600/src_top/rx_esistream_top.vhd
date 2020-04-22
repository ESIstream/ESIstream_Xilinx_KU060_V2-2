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

library work;
use work.esistream_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.VComponents.all;

entity rx_esistream_top is
  generic(
    GEN_ESISTREAM          : boolean                       := true;
    GEN_GPIO               : boolean                       := false;
    NB_LANES               : integer                       := 8;
    RST_CNTR_INIT          : std_logic_vector(11 downto 0) := x"FFF";
    NB_CLK_CYC             : std_logic_vector(31 downto 0) := x"00FFFFFF";
    CLK_MHz                : real                          := 100.0;
    SPI_CLK_MHz            : real                          := 5.0;
    SYNCTRIG_PULSE_WIDTH   : integer                       := 7;
    SYNCTRIG_MAX_DELAY     : integer                       := 16;
    SYNCTRIG_COUNTER_WIDTH : integer                       := 8;
    FIFO_DATA_WIDTH        : integer                       := 24;
    FIFO_DEPTH             : integer                       := 8
    );
  port (
    sso_n            : in  std_logic;                     -- mgtrefclk from transceiver clock input
    sso_p            : in  std_logic;                     -- mgtrefclk from transceiver clock input
    FABRIC_CLK_P     : in  std_logic;                     -- sysclk
    FABRIC_CLK_N     : in  std_logic;                     -- sysclk
    rxp              : in  std_logic_vector(NB_LANES-1 downto 0) := (others => '0');  -- lane serial input p
    rxn              : in  std_logic_vector(NB_LANES-1 downto 0) := (others => '0');  -- lane Serial input n
    --ASLp             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --ASLn             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --BSLp             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --BSLn             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --CSLp             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --CSLn             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --DSLp             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    --DSLn             : in  std_logic_vector(1 downto 0);  -- Serial input for NB_LANES lanes
    gpio_j20_10      : in  std_logic;                     --SW_C
    gpio_j20_8       : in  std_logic;                     --SW_S
    gpio_j20_6       : in  std_logic;                     --SW_W
    gpio_j20_4       : in  std_logic;                     --SW_N
    gpio_j20_2       : in  std_logic;                     --dipswitch(4) 
    led_usr          : out std_logic_vector(7 downto 0);
    UART_TX          : in  std_logic;                     -- CP2105 USB to UART output 
    UART_RX          : out std_logic;                     -- CP2105 USB to UART input
    aq600_rstn       : out std_logic;
    spi_sclk         : out std_logic;
    spi_csn          : out std_logic;                     -- EV12AQ600  
    CSN_PLL          : out std_logic;                     -- LMX2592 PLL
    spi_mosi         : out std_logic;
    spi_miso         : in  std_logic;                     --  
    --VTEMP_DUT          : in  std_logic; -- Not connected on KCU105 
    --Viref_RTH          : in  std_logic; -- Not connected on KCU105 
    PLL_LOCK         : in  std_logic;
    aq600_synco_p    : in  std_logic;
    aq600_synco_n    : in  std_logic;
    aq600_synctrig_p : out std_logic;
    aq600_synctrig_n : out std_logic
    );
end entity rx_esistream_top;


architecture rtl of rx_esistream_top is

  --------------------------------------------------------------------------------------------------------------------
  --! signal name description:
  -- _sr = _shift_register
  -- _re = _rising_edge (one clk period pulse generated on the rising edge of the initial signal)
  -- _fe = _falling_edge (one clk period pulse generated on the falling edge of the initial signal)
  -- _d  = _delay
  -- _2d = _delay x2
  -- _ba = _bitwise_and
  -- _sw = _slide_window
  -- _o  = _output
  -- _i  = _input
  -- _t  = _temporary or _tristate pin (OBUFT)
  -- _a  = _asychronous (fsm output decode signal)
  -- _s  = _synchronous (fsm synchronous output signal)
  -- _rs = _resynchronized (when there is a clock domain crossing)
  --------------------------------------------------------------------------------------------------------------------
  --attribute KEEP                : string;
  --constant NB_LANES             : natural                               := 8;
  constant ALL_LANES_ON      : std_logic_vector(NB_LANES-1 downto 0) := (others => '1');
  constant ALL_LANES_OFF     : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');
  signal sysrst              : std_logic                             := '0';
  signal sysclk              : std_logic                             := '0';
  signal syslock             : std_logic                             := '0';
  signal rx_clk              : std_logic                             := '0';
  signal reg_rst             : std_logic                             := '0';
  signal reg_rst_check       : std_logic                             := '0';
  signal sw_rst              : std_logic                             := '0';
  signal sw_rst_check        : std_logic                             := '0';
  signal rst                 : std_logic                             := '0';
  signal rst_re              : std_logic                             := '0';
  signal rst_check           : std_logic                             := '0';
  signal rst_check_rs        : std_logic                             := '0';
  signal rst_check_re        : std_logic                             := '0';
  signal sync_in             : std_logic                             := '0';
  signal sync_in_rs          : std_logic                             := '0';
  signal sync_in_re          : std_logic                             := '0';
  signal synctrig            : std_logic                             := '0';
  signal synctrig_re         : std_logic                             := '0';
  signal ip_ready            : std_logic                             := '0';
  signal lanes_ready         : std_logic                             := '0';
  signal release_data        : std_logic                             := '0';
  signal prbs_en             : std_logic                             := '1';
  signal dsw_prbs_en         : std_logic                             := '1';
  --
  signal frame_out           : rx_frame_array(NB_LANES-1 downto 0);
  --signal data_out            : rx_data_array(NB_LANES-1 downto 0);
  signal valid_out           : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');
  --
  signal fifo_dout           : data_array(NB_LANES-1 downto 0);
  signal fifo_rd_en          : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');
  signal fifo_empty          : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');
  --
  signal ber_status          : std_logic                             := '0';
  signal cb_status           : std_logic                             := '0';
  --
  --signal rxp                 : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');  -- lane serial input p
  --signal rxn                 : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');  -- lane Serial input n
  --
  signal aq600_prbs_en       : std_logic                             := '1';
  signal clk_acq             : std_logic                             := '0';
  signal s_rst_cntr          : std_logic_vector(11 downto 0)         := RST_CNTR_INIT;
  signal s_reset_i           : std_logic                             := '0';
  signal s_resetn_i          : std_logic                             := '0';
  signal s_resetn_re         : std_logic                             := '0';
  signal rx_rst              : std_logic                             := '0';
  signal rx_sync_rst         : std_logic                             := '0';
  signal rx_sync_rst_rs      : std_logic                             := '0';
  signal rx_sync_rst_re      : std_logic                             := '0';
  signal reg_aq600_rstn      : std_logic;

  type rx_data_array_12b is array (natural range <>) of slv_12_array_n(DESER_WIDTH/16-1 downto 0);
  signal data_out_12b : rx_data_array_12b(NB_LANES-1 downto 0);

  signal m_axi_addr                    : std_logic_vector(3 downto 0)  := (others => '0');
  signal m_axi_strb                    : std_logic_vector(3 downto 0)  := (others => '0');
  signal m_axi_wdata                   : std_logic_vector(31 downto 0) := (others => '0');
  signal m_axi_rdata                   : std_logic_vector(31 downto 0) := (others => '0');
  signal m_axi_wen                     : std_logic                     := '0';
  signal m_axi_ren                     : std_logic                     := '0';
  signal m_axi_busy                    : std_logic                     := '0';
  signal s_interrupt                   : std_logic                     := '0';
  --
  signal reg_0                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_1                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_2                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_3                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_4                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_5                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_6                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_7                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_8                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_9                         : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_10                        : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_11                        : std_logic_vector(31 downto 0) := (others => '0');
--
  signal spi_ss                        : std_logic;
  signal spi_start                     : std_logic;
  signal spi_start_re                  : std_logic;
  signal fifo_in_wr_en                 : std_logic;
  signal fifo_in_din                   : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
  signal fifo_in_full                  : std_logic;
  signal fifo_out_rd_en                : std_logic;
  signal fifo_out_dout                 : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
  signal fifo_out_empty                : std_logic;
--
  signal sync_rst                      : std_logic                     := '0';
  signal sync_delay                    : std_logic_vector(integer(floor(log2(real(SYNCTRIG_MAX_DELAY-1)))) downto 0);
  signal sync_mode                     : std_logic;
  signal sync_en                       : std_logic;
  signal sync_wr_en                    : std_logic;
  signal sync_wr_counter               : std_logic_vector(SYNCTRIG_COUNTER_WIDTH-1 downto 0);
  signal sync_rd_counter               : std_logic_vector(SYNCTRIG_COUNTER_WIDTH-1 downto 0);
  signal sync_counter_busy             : std_logic;
  signal sync_counter_busy_rs          : std_logic;
  signal send_sync                     : std_logic;
  signal send_sync_rs                  : std_logic;
  signal sync_wr_en_rs                 : std_logic;
  --
  signal uart_ready                    : std_logic                     := '0';
  --
  signal reg_4_os                      : std_logic                     := '0';
  signal reg_5_os                      : std_logic                     := '0';
  signal reg_6_os                      : std_logic                     := '0';
  signal reg_7_os                      : std_logic                     := '0';
  signal reg_10_os                     : std_logic                     := '0';
--
  attribute MARK_DEBUG                 : string;
  attribute MARK_DEBUG of sync_in      : signal is "true";
  attribute MARK_DEBUG of ip_ready     : signal is "true";
  attribute MARK_DEBUG of lanes_ready  : signal is "true";
  attribute MARK_DEBUG of cb_status    : signal is "true";
  attribute MARK_DEBUG of ber_status   : signal is "true";
  attribute MARK_DEBUG of data_out_12b : signal is "true";
  attribute MARK_DEBUG of valid_out    : signal is "true";
--
begin
  --
  --------------------------------------------------------------------------------------------
  -- User interface:
  --------------------------------------------------------------------------------------------
  --############################################################################################################################
  --############################################################################################################################
  -- System PLL / Reset
  --############################################################################################################################
  --############################################################################################################################  
  --============================================================================================================================
  --  clk_out1 : 100.0MHz (must be consistent with C_SYS_CLK_PERIOD)
  --============================================================================================================================  
  i_pll_sys : entity work.clk_wiz_0
    port map (
      -- Clock out ports  
      clk_out1  => sysclk,
      -- Status and control signals                
      reset     => sysrst,
      locked    => syslock,
      -- Clock in ports
      clk_in1_p => FABRIC_CLK_P,
      clk_in1_n => FABRIC_CLK_N
      );


  process(syslock, sysclk)
  begin
    if syslock = '0' then
      s_rst_cntr <= RST_CNTR_INIT;
      s_reset_i  <= '1';
      s_resetn_i <= '0';

    elsif rising_edge(sysclk) then
      if s_rst_cntr /= x"000" then
        s_rst_cntr <= std_logic_vector(unsigned(s_rst_cntr) - 1);
      end if;

      -- Global POR reset.
      if s_rst_cntr /= x"000" then
        s_reset_i  <= '1';
        s_resetn_i <= '0';
      else
        s_reset_i  <= '0';
        s_resetn_i <= '1';
      end if;
    end if;
  end process;
  -------------------------
  -- reset
  -------------------------
  aq600_rstn <= reg_aq600_rstn;
  rst        <= sw_rst or reg_rst;
  rx_rst     <= rst_re or s_reset_i;
  rst_check  <= sw_rst_check or reg_rst_check;

  gen_gpio_false_hdl : if GEN_GPIO = false generate
    -------------------------
    -- Push buttons
    -------------------------
    sw_rst       <= '0';  
    sync_in      <= '0'; 
    sw_rst_check <= '0'; 
    sysrst       <= '0'; 
    -- 
    -------------------------
    -- SW2 switch
    -------------------------
    dsw_prbs_en  <= '1'; 
  end generate gen_gpio_false_hdl;
  
  gen_gpio_true_hdl : if GEN_GPIO = true generate
    -------------------------
    -- Push buttons
    -------------------------
    sw_rst       <= gpio_j20_10; --SW_C 
    sync_in      <= gpio_j20_8;  --SW_S 
    sw_rst_check <= gpio_j20_6;  --SW_W 
    sysrst       <= gpio_j20_4;  --SW_N 
    --                     
    -------------------------
    -- SW2 switch
    -------------------------
    dsw_prbs_en  <= gpio_j20_2; --dipswitch(4)
  end generate gen_gpio_true_hdl;
  --
  -- leds
  led_usr(0) <= uart_ready;
  led_usr(1) <= ip_ready;
  led_usr(2) <= lanes_ready;
  led_usr(3) <= cb_status;
  led_usr(4) <= ber_status;
  led_usr(5) <= '0';
  led_usr(6) <= reg_0(0);
  led_usr(7) <= reg_0(1);

  --------------------------------------------------------------------------------------------
  -- sysclk rising edge:
  --------------------------------------------------------------------------------------------
  risingedge_array_1 : entity work.risingedge_array
    generic map (
      D_WIDTH => 3)
    port map (
      rst   => s_reset_i,
      clk   => sysclk,
      d(0)  => rst,
      d(1)  => s_resetn_i,
      d(2)  => spi_start,
      re(0) => rst_re,
      re(1) => s_resetn_re,
      re(2) => spi_start_re);
  --------------------------------------------------------------------------------------------
  -- rx_clk rising edge from sysclk:
  --------------------------------------------------------------------------------------------

  ff_synchronizer_array_1 : entity work.ff_synchronizer_array
    generic map (
      REG_WIDTH => 5)
    port map (
      clk          => rx_clk,
      reg_async(0) => sync_in,
      reg_async(1) => rst_check,
      reg_async(2) => rx_sync_rst,
      reg_async(3) => send_sync,
      reg_async(4) => sync_wr_en,
      reg_sync(0)  => sync_in_rs,
      reg_sync(1)  => rst_check_rs,
      reg_sync(2)  => rx_sync_rst_rs,
      reg_sync(3)  => send_sync_rs,
      reg_sync(4)  => sync_wr_en_rs);

  risingedge_array_2 : entity work.risingedge_array
    generic map (
      D_WIDTH => 3)
    port map (
      rst   => '0',
      clk   => rx_clk,
      d(0)  => sync_in_rs,
      d(1)  => rst_check_rs,
      d(2)  => rx_sync_rst_rs,
      re(0) => sync_in_re,
      re(1) => rst_check_re,
      re(2) => rx_sync_rst_re);
  --------------------------------------------------------------------------------------------
  -- ESIstream, receiver (rx) IP: 
  --------------------------------------------------------------------------------------------
  --rxn(2) <= ASLn(0);
  --rxp(2) <= ASLp(0);
  --rxn(3) <= ASLn(1);
  --rxp(3) <= ASLp(1);
  --rxn(0) <= BSLn(0);
  --rxp(0) <= BSLp(0);
  --rxn(1) <= BSLn(1);
  --rxp(1) <= BSLp(1);
  --rxn(6) <= CSLn(0);
  --rxp(6) <= CSLp(0);
  --rxn(5) <= CSLn(1);
  --rxp(5) <= CSLp(1);
  --rxn(4) <= DSLn(0);
  --rxp(4) <= DSLp(0);
  --rxn(7) <= DSLn(1);
  --rxp(7) <= DSLp(1);
  --
  --============================================================================================================================
  -- ESIstream RX IP
  --============================================================================================================================
  gen_esistream_hdl : if GEN_ESISTREAM = true generate
    rx_esistream_inst : entity work.rx_esistream_with_xcvr
      generic map(
        NB_LANES => NB_LANES,
        COMMA    => x"FF0000FF"
        )
      port map(
        rst          => rx_rst,
        sysclk       => sysclk,
        refclk_n     => sso_n,
        refclk_p     => sso_p,
        rxn          => rxn,
        rxp          => rxp,
        sync_in      => synctrig_re,
        prbs_en      => prbs_en,
        lanes_on     => ALL_LANES_ON,
        read_data_en => release_data,
        clk_acq      => rx_clk,
        rx_frame_clk => rx_clk,
        sync_out     => open,
        frame_out    => frame_out,
        --data_out     => data_out,
        valid_out    => valid_out,
        ip_ready     => ip_ready,
        lanes_ready  => lanes_ready
        );
  end generate gen_esistream_hdl;

  -- Used for ILA only to display the ramp waveform using analog view in vivado simulator:
  lanes_assign : for i in 0 to NB_LANES-1 generate
    channel_assign : for j in 0 to DESER_WIDTH/16-1 generate
      process(rx_clk)
      begin
        if rising_edge(rx_clk) then
          data_out_12b(i)(j) <= frame_out(i)(j)(12-1 downto 0);
        end if;
      end process;
    end generate channel_assign;
  end generate lanes_assign;

  --============================================================================================================================
  -- Received data check module
  --============================================================================================================================
  rx_check_1 : entity work.rx_check_aq600
    generic map (
      NB_LANES => NB_LANES)
    port map (
      rst        => rst_check_rs,
      clk        => rx_clk,
      frame_out  => frame_out,
      --data_out   => data_out,
      valid_out  => valid_out,
      ber_status => ber_status,
      cb_status  => cb_status);

  --============================================================================================================================
  -- SYNC generator and SYNC counter
  --============================================================================================================================
  sync_generator_1 : entity work.sync_generator
    generic map (
      SYNCTRIG_PULSE_WIDTH   => SYNCTRIG_PULSE_WIDTH,
      SYNCTRIG_MAX_DELAY     => SYNCTRIG_MAX_DELAY,
      SYNCTRIG_COUNTER_WIDTH => SYNCTRIG_COUNTER_WIDTH)
    port map (
      clk          => rx_clk,
      rst          => rx_sync_rst_rs,
      sync_delay   => sync_delay,
      mode         => sync_mode,
      sync_en      => sync_en,
      lanes_ready  => lanes_ready,
      release_data => release_data,
      wr_en        => sync_wr_en,
      wr_counter   => sync_wr_counter,
      rd_counter   => sync_rd_counter,
      counter_busy => sync_counter_busy,
      send_sync    => send_sync,
      sw_sync      => sync_in_re,
      synctrig     => synctrig,
      synctrig_re  => synctrig_re);

  obufds_1 : OBUFDS
    port map (
      O  => aq600_synctrig_p,
      OB => aq600_synctrig_n,
      I  => synctrig
      );
  --============================================================================================================================
  -- SPI Master, dual slave: EV12AQ600 & LMX2592
  --============================================================================================================================
  spi_dual_master_1 : entity work.spi_dual_master
    generic map (
      CLK_MHz         => CLK_MHz,
      SPI_CLK_MHz     => SPI_CLK_MHz,
      FIFO_DATA_WIDTH => FIFO_DATA_WIDTH,
      FIFO_DEPTH      => FIFO_DEPTH)
    port map (
      clk            => sysclk,
      rst            => s_reset_i,
      spi_ncs1       => spi_csn,          -- EV12AQ600
      spi_ncs2       => CSN_PLL,          -- LMX2592
      spi_sclk       => spi_sclk,
      spi_mosi       => spi_mosi,
      spi_miso       => spi_miso,
      spi_ss         => spi_ss,           -- from register
      spi_start      => spi_start_re,     -- from register
      spi_busy       => open,
      fifo_in_wr_en  => fifo_in_wr_en,    -- from register
      fifo_in_din    => fifo_in_din,      -- from register
      fifo_in_full   => fifo_in_full,     -- to register
      fifo_out_rd_en => fifo_out_rd_en,   -- from register
      fifo_out_dout  => fifo_out_dout,    -- to register
      fifo_out_empty => fifo_out_empty);  -- from register

  --============================================================================================================================
  -- UART 8 bit 115200 and Register map
  --============================================================================================================================
  uart_wrapper_1 : entity work.uart_wrapper
    port map (
      clk         => sysclk,
      rstn        => s_resetn_i,
      m_axi_addr  => m_axi_addr,
      m_axi_strb  => m_axi_strb,
      m_axi_wdata => m_axi_wdata,
      m_axi_rdata => m_axi_rdata,
      m_axi_wen   => m_axi_wen,
      m_axi_ren   => m_axi_ren,
      m_axi_busy  => m_axi_busy,
      interrupt   => s_interrupt,
      tx          => UART_RX,
      rx          => UART_TX);

  register_map_1 : entity work.register_map
    generic map (
      CLK_FREQUENCY_HZ => 100000000,
      TIME_US          => 1000000)
    port map (
      clk          => sysclk,
      rstn         => s_resetn_i,
      interrupt_en => s_resetn_re,
      m_axi_addr   => m_axi_addr,
      m_axi_strb   => m_axi_strb,
      m_axi_wdata  => m_axi_wdata,
      m_axi_rdata  => m_axi_rdata,
      m_axi_wen    => m_axi_wen,
      m_axi_ren    => m_axi_ren,
      m_axi_busy   => m_axi_busy,
      interrupt    => s_interrupt,
      uart_ready   => uart_ready,
      reg_0        => reg_0,
      reg_1        => reg_1,
      reg_2        => reg_2,
      reg_3        => reg_3,
      reg_4        => reg_4,
      reg_5        => reg_5,
      reg_6        => reg_6,
      reg_7        => reg_7,
      reg_8        => reg_8,
      reg_9        => reg_9,
      reg_10       => reg_10,
      reg_11       => reg_11,
      reg_4_os     => reg_4_os,
      reg_5_os     => reg_5_os,
      reg_6_os     => reg_6_os,
      reg_7_os     => reg_7_os,
      reg_10_os    => reg_10_os);

  prbs_en        <= reg_1(0) or dsw_prbs_en;
  --
  reg_rst        <= reg_2(0);
  reg_rst_check  <= reg_2(1);
  reg_aq600_rstn <= reg_2(2);
  rx_sync_rst    <= reg_2(3);
  --
  spi_ss         <= reg_3(0);
  spi_start      <= reg_3(1);
  --
  fifo_in_din    <= reg_4(23 downto 0);
  --
  sync_mode      <= reg_5(0);
  sync_delay     <= reg_5(7 downto 4);
  sync_en        <= reg_5_os;

  send_sync           <= reg_6(0);
  --
  sync_wr_counter     <= reg_7(7 downto 0);
  sync_wr_en          <= reg_7(8);
  -- firmware version --
  reg_8               <= x"00000220";
  --
  reg_9(0)            <= fifo_in_full;
  reg_9(1)            <= fifo_out_empty;
  --
  reg_10(23 downto 0) <= fifo_out_dout;
  --
  reg_11(7 downto 0)  <= sync_rd_counter;
  reg_11(8)           <= sync_counter_busy;
  --
  fifo_in_wr_en       <= reg_4_os;
  fifo_out_rd_en      <= reg_10_os;
end architecture rtl;
