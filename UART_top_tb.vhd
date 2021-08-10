-------------------------------------------------------------------------------
-- Title      : Testbench for design "UART_top"
-- Project    :
-------------------------------------------------------------------------------
-- File       : UART_top_tb.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-08-10
-- Last update: 2021-08-10
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-08-10  1.0      otutaysalgir	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity UART_top_tb is

end entity UART_top_tb;

-------------------------------------------------------------------------------

architecture tb of UART_top_tb is

  -- component ports
  signal clock  : std_logic;
  signal oTxOut : std_logic;
  signal iRxIn  : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture tb

  -- component instantiation
  DUT: entity work.UART_top
    port map (
      clock  => clock,
      oTxOut => oTxOut,
      iRxIn  => oTxOut
      );

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
  end process WaveGen_Proc;



end architecture tb;
