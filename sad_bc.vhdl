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
        entradas: in ent_controle;
        saidas: out saidas_controle;
        comandos: out controle_comandos;
        status: in controle_status
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
    
    prxm_estado: process(estado_atual, status.menor, entradas.iniciar)
    begin
        case estado_atual is
        when S0 =>
            if(entradas.iniciar) then
                proximo_estado <= S1;
            else
                proximo_estado <= estado_atual;
            end if;
        when S1 =>
            proximo_estado <= S2;
        when S2 =>
            if(status.menor) then
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
            saidas.pronto <= '1';
            saidas.ler <= '0'; 
            comandos.zi <= '-';
            comandos.ci <= '0';
            comandos.cpA <= '0';
            comandos.cpB <= '0';
            comandos.zsoma <= '-';
            comandos.csoma <= '0';
            comandos.csad_reg <= '0';
        when S1 =>
            saidas.pronto <= '0';
            saidas.ler <= '0';
            comandos.zi <= '1';
            comandos.ci <= '1';
            comandos.cpA <= '0';
            comandos.cpB <= '0';
            comandos.zsoma <= '1';
            comandos.csoma <= '1';
            comandos.csad_reg <= '0';
        when S2 =>
            saidas.pronto <= '0';
            saidas.ler <= '0';
            comandos.zi <= '0';
            comandos.ci <= '0';
            comandos.cpA <= '0';
            comandos.cpB <= '0';
            comandos.zsoma <= '0';
            comandos.csoma <= '0';
            comandos.csad_reg <= '0';
        when S3 =>
            saidas.pronto <= '0';
            saidas.ler <= '1';
            comandos.zi <= '0';
            comandos.ci <= '0';
            comandos.cpA <= '1';
            comandos.cpB <= '1';
            comandos.zsoma <= '0';
            comandos.csoma <= '0';
            comandos.csad_reg <= '0';
        when S4 =>
            saidas.pronto <= '0';
            saidas.ler <= '0';
            comandos.zi <= '0';
            comandos.ci <= '1';
            comandos.cpA <= '0';
            comandos.cpB <= '0';
            comandos.zsoma <= '0';
            comandos.csoma <= '1';
            comandos.csad_reg <= '0';
        when S5 =>
            saidas.pronto <= '0';
            saidas.ler <= '0';
            comandos.zi <= '1';
            comandos.ci <= '1';
            comandos.cpA <= '0';
            comandos.cpB <= '0';
            comandos.zsoma <= '1';
            comandos.csoma <= '1';
            comandos.csad_reg <= '1';
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
