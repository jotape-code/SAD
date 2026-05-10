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
        entradas: in entradas_geral(dados(A(CFG.bits_per_sample -1 downto 0), B(CFG.bits_per_sample - 1 downto 0)));
        saidas: out saidas_geral(dados(SAD(sad_length(CFG.bits_per_sample, CFG.samples_per_block)- 1 downto 0), address(address_length(CFG.samples_per_block, CFG.parallel_samples) - 1 downto 0)))
		
	);
end entity sadWrapped;

architecture arch of sadWrapped is
    signal comandos: controle_comandos;
    signal status: controle_status;
begin
	bc: ENTITY work.sad_bc
	port map(clk => clk, rst_a => rst_a, entradas => entradas.controle, comandos => comandos, 
	status => status, saidas => saidas.controle);
	
	bo: ENTITY work.sad_bo
	generic map(CFG => (
	    bits_per_sample => CFG.bits_per_sample,
	    samples_per_block => CFG.samples_per_block,
	    parallel_samples => CFG.parallel_samples
	  )
	)
	port map(
	    clk => clk,
	    entradas => entradas.dados,
	    comandos => comandos,
	    status => status,
	    saidas => saidas.dados
	);
end architecture arch; 