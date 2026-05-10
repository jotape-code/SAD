library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sad_pack.all;

Entity adressCa is
    generic(
        address_len: positive := 6
    );
   port(
    clk: in std_logic;
    enable: in std_logic;
    sel_mux: in std_logic;
    menor: out std_logic;
    address: out unsigned(address_len-1 downto 0)
   );
end adressCa;

architecture arch of adressCa is
    signal resul_soma: unsigned(address_len downto 0);
    signal mux_saida: std_logic_vector(address_len downto 0);
    signal reg_saida: unsigned(address_len downto 0);
begin
    mux: ENTITY work.mux_2to1
    GENERIC map(
        N =>address_len + 1
    )
    port map(
        sel => sel_mux, in_0 =>std_logic_vector(resul_soma), in_1 => std_logic_vector'(others => '0'), y => mux_saida
    );

    reg: ENTITY work.unsigned_register
    GENERIC map(
        N => address_len+1
    )
    PORT MAP(
     clk => clk, enable => enable, d => unsigned(mux_saida), q => reg_saida         
    );
    resul_soma <= reg_saida + 1;  

    menor <= not(reg_saida(reg_saida'HIGH));
    address <= reg_saida(address_len - 1 downto 0);
end architecture arch;