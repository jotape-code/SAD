library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sad_pack.all;

Entity SadCa is
    generic(
        bits_per_sample: positive := 8;
        samples_per_block: positive := 64
    );
    port(
        clk: in std_logic;
        cpA, cpB, csoma, zsoma, csad_reg: in std_logic;
        A: in unsigned(bits_per_sample - 1 downto 0);
        B: in unsigned(bits_per_sample - 1 downto 0);
        SAD: out unsigned(sad_length(bits_per_sample, samples_per_block) - 1 downto 0)
    );
end entity SadCa;

architecture arch of SadCa is
    signal regpA_saida: unsigned(A'range);
    signal regpB_saida: unsigned(B'range);
    signal diferenca_absoluta: unsigned(bits_per_sample - 1 downto 0);
    signal saida_acumulador: unsigned(sad_length(bits_per_sample, samples_per_block) - 1 downto 0);
    signal mux_saida: std_logic_vector(sad_length(bits_per_sample, samples_per_block) - 1 downto 0);
    signal saida_final: unsigned(sad_length(bits_per_sample, samples_per_block) - 1 downto 0);
    
begin
    pA: ENTITY work.unsigned_register
        generic map(
            N => bits_per_sample
        )
        port map(
            clk    => clk,
            enable => cpA,
            d      => A,
            q      => regpA_saida
        );
    pB: ENTITY work.unsigned_register
        generic map(
            N => bits_per_sample
        )
        port map(
            clk    => clk,
            enable => cpB,
            d      => B,
            q      => regpB_saida
        );
    absol: ENTITY work.absolute_difference
        generic map(
            N => bits_per_sample
        )
        port map(
                input_a  => regpA_saida,
                input_b  => regpB_saida,
                abs_diff => diferenca_absoluta
        );
    
        
    mux_acumulador: ENTITY work.mux_2to1
        generic map(
            N => sad_length(bits_per_sample, samples_per_block)
        )
        port map(
            sel  => zsoma,
            in_0 => std_logic_vector(resize(diferenca_absoluta, sad_length(bits_per_sample, samples_per_block)) + saida_acumulador),
            in_1 => (others => '0'),
            y    => mux_saida
        );
    

    reg_acumulador: ENTITY work.unsigned_register
        generic map(
            N => sad_length(bits_per_sample, samples_per_block)
        )
        port map(
            clk    => clk,
            enable => csoma,
            d      => unsigned(mux_saida),
            q      => saida_acumulador
        );
    
    reg_saida: ENTITY work.unsigned_register
        generic map(
            N => sad_length(bits_per_sample, samples_per_block)
        )
        port map(
            clk => clk,
            enable => csad_reg,
            d => saida_acumulador,
            q => saida_final

        );
    sad <= saida_final;
end architecture arch;

