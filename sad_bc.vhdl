--------------------------------------------------
--	Author:      Ismael Seidel (entity)
--	Created:     May 1, 2025
--
--	Project:     Exercício 6 de INE5406
--	Description: Contém a descrição da entidade `sad_bc`, que representa o
--               bloco de controle (BC) do circuito para cálculo da soma das
--               diferenças absolutas (SAD - Sum of Absolute Differences).
--               Este bloco é responsável pela geração dos sinais de controle
--               necessários para coordenar o funcionamento do bloco operativo
--               (BO), como enable de registradores, seletores de multiplexadores,
--               sinais de início e término de processamento, etc.
--               A arquitetura é comportamental e deverá descrever uma máquina
--               de estados finitos (FSM) adequada ao controle do datapath.
--               Os sinais adicionais de controle devem ser definidos conforme
--               a necessidade do projeto. PS: já foram definidos nos slides
--               da aula 6T.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.sad_pack.all;

-- Bloco de Controle (BC) do circuito SAD.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- geralmente por meio de uma FSM.
entity sad_bc is
	port(
		clk   : in std_logic;  -- clock (sinal de relógio)
		rst_a : in std_logic;   -- reset assíncrono ativo em nível alto
        iniciar: in std_logic;
        pronto: out std_logic;
        ler: out std_logic;
        zi: out std_logic;
        ci: out std_logic;
        cpA: out std_logic;
        cpB: out std_logic;
        zsoma: out std_logic;
        csoma: out std_logic;
        csad_reg: out std_logic;
        menor: in std_logic
		-- defina os demais sinais necessários
		-- não esqueça de colocar o ; no final da linha que declara o rst_a :)
	);
end entity;
-- Não altere o nome da entidade nem da arquitetura!

architecture behavior of sad_bc is
    -- Se necessário, declare sinais internos aqui.
    type ESTADOS is (S0, S1, S2, S3, S4, S5);
    signal estado_atual, proximo_estado: ESTADOS;
begin
    
    prxm_estado: process(estado_atual, menor, iniciar)
    begin
        case estado_atual is
        when S0 =>
            if(iniciar = '1') then
                proximo_estado <= S1;
            else
                proximo_estado <= estado_atual;
            end if;
        when S1 =>
            proximo_estado <= S2;
        when S2 =>
            if(menor ='1') then
                proximo_estado <= S3;
            else 
                proximo_estado <= S5;
            end if;
        when S3 =>
            proximo_estado <= S4;
        when S4 =>
            proximo_estado <= S2;
        when S5 =>
            proximo_estado <= S0;
        end case;
    end process prxm_estado;

    saida_process: process(estado_atual)
    begin
        case estado_atual is
        when S0 =>
            pronto <= '1';
            ler <= '0'; 
            zi <= '-';
            ci <= '0';
            cpA <= '0';
            cpB <= '0';
            zsoma <= '-';
            csoma <= '0';
            csad_reg <= '0';
        when S1 =>
            pronto <= '0';
            ler <= '0';
            zi <= '1';
            ci <= '1';
            cpA <= '0';
            cpB <= '0';
            zsoma <= '1';
            csoma <= '1';
            csad_reg <= '0';
        when S2 =>
            pronto <= '0';
            ler <= '0';
            zi <= '-';
            ci <= '0';
            cpA <= '0';
            cpB <= '0';
            zsoma <= '-';
            csoma <= '0';
            csad_reg <= '0';
        when S3 =>
            pronto <= '0';
            ler <= '1';
            zi <= '-';
            ci <= '0';
            cpA <= '1';
            cpB <= '1';
            zsoma <= '-';
            csoma <= '0';
            csad_reg <= '0';
        when S4 =>
            pronto <= '0';
            ler <= '0';
            zi <= '0';
            ci <= '1';
            cpA <= '0';
            cpB <= '0';
            zsoma <= '0';
            csoma <= '1';
            csad_reg <= '0';
        when S5 =>
            pronto <= '0';
            ler <= '0';
            zi <= '-';
            ci <= '0';
            cpA <= '0';
            cpB <= '0';
            zsoma <= '-';
            csoma <= '0';
            csad_reg <= '1';
        end case;
    end process saida_process;

    reg_process: process(clk, rst_a)
    begin
        if(rst_a = '1') then
            estado_atual <= S0;
        elsif rising_edge(clk) then
            estado_atual <= proximo_estado;
        end if;
    end process reg_process;


    -- Dica: separar em 3 processos:
    -- 1) carga e reset do registrador de estado;
    -- 2) LPE;
    -- 3) LS.
end architecture;
