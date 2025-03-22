--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : [Your name here]
--| CREATED       : [Current date]
--| DESCRIPTION   : This file tests the thunderbird_fsm module.
--|
--|                 Test cases include:
--|                 1. Reset functionality
--|                 2. Left turn signal sequence
--|                 3. Right turn signal sequence
--|                 4. Hazard lights (both signals on)
--|                 5. Changing input during sequence
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm.vhd
--|
--+----------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
        port (
            i_clk, i_reset  : in    std_logic;
            i_left, i_right : in    std_logic;
            o_lights_L      : out   std_logic_vector(2 downto 0);
            o_lights_R      : out   std_logic_vector(2 downto 0)
        );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	signal w_left : std_logic := '0'; 
	signal w_right : std_logic := '0';
	
	-- Outputs
	signal w_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_lights_R : std_logic_vector(2 downto 0) := "000";
	
	
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	
    uut: thunderbird_fsm port map (
          i_left => w_left,
          i_right => w_right,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L => w_lights_L,
          o_lights_R => w_lights_R
    );
	
	
	-----------------------------------------------------
	
	clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	
	sim_proc: process
	begin
		w_reset <= '1';
		wait for k_clk_period*2;
		assert w_lights_L = "000" report "Reset failed for left lights" severity failure;
		assert w_lights_R = "000" report "Reset failed for right lights" severity failure;
		
		w_reset <= '0';
		wait for k_clk_period;
		
		w_left <= '1';
		w_right <= '0';
		
		wait for k_clk_period;
		assert w_lights_L = "001" report "L1 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_L = "011" report "L2 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_L = "111" report "L3 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_L = "000" report "Back to OFF incorrect" severity failure; 
		
		w_left <= '0';
		wait for k_clk_period * 3; 
		wait for k_clk_period;
		assert w_lights_L = "000" report "Sequence didn't complete after turning off" severity failure;
		
		w_left <= '0';
		w_right <= '1';
		
		wait for k_clk_period;
		assert w_lights_R = "001" report "R1 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_R = "011" report "R2 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_R = "111" report "R3 incorrect" severity failure; 
		
		wait for k_clk_period;
		assert w_lights_R = "000" report "Back to OFF incorrect" severity failure; 
		
		w_left <= '1';
		w_right <= '1';
		wait for k_clk_period;
		assert w_lights_L = "111" and w_lights_R = "111" 
		       report "Hazard lights not functioning correctly" severity failure;
		
		wait for k_clk_period;
		assert w_lights_L = "000" and w_lights_R = "000" 
		       report "Hazard lights off state incorrect" severity failure;
		
		wait for k_clk_period*2; 
		w_reset <= '1';
		wait for k_clk_period;
		assert w_lights_L = "000" and w_lights_R = "000" 
		       report "Reset during sequence failed" severity failure;
		
		wait;
	end process;
	
end test_bench;