library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sad_pack.all;

entity sadWrapped is
    generic(
        CFG : datapath_configuration_t := (
			bits_per_sample   => 8,  
			samples_per_block => 64, 
			parallel_samples  => 1   
		)
    );
	port(
        clk: in std_logic;
        rst_a: in std_logic;
        A, B: in unsigned(CFG.bits_per_sample - 1 downto 0);
        iniciar: in std_logic;
	SAD: out unsigned(sad_length(CFG.bits_per_sample, CFG.samples_per_block) - 1 downto 0);
        address: out unsigned(address_length(CFG.samples_per_block, CFG.parallel_samples) - 1 downto 0);
        pronto: out std_logic;
        ler: out std_logic
	);
end entity sadWrapped;

architecture arch of sadWrapped is
      signal  zi: std_logic;
      signal  ci: std_logic;
      signal  cpA: std_logic;
      signal  cpB: std_logic;
      signal  zsoma: std_logic;
      signal  csoma: std_logic;
      signal  csad_reg: std_logic;
      signal menor: std_logic;
begin
	bc: ENTITY work.sad_bc
	port map(clk => clk, rst_a => rst_a, iniciar => iniciar, pronto => pronto, zi => zi, ci => ci, cpA => cpA, cpB => cpB, ler => ler,
                zsoma => zsoma, csoma => csoma, csad_reg => csad_reg, menor => menor
	);
	
	bo: ENTITY work.sad_bo
	generic map(CFG => (
	    bits_per_sample => CFG.bits_per_sample,
	    samples_per_block => CFG.samples_per_block,
	    parallel_samples => CFG.parallel_samples
	  )
	)
	port map(
	    clk => clk,
	    A => A,
            B => B,
            zi => zi,
            ci => ci,
            cpA => cpA,
            cpB => cpB,
            zsoma => zsoma,
            csoma => csoma,
            csad_reg => csad_reg,
            SAD => SAD,
            address => address,
            menor => menor
	);
end architecture arch; 