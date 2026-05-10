--------------------------------------------------
--	Author:      Ismael Seidel (entidade)
--	Created:     May 1, 2025
--
--	Project:     Exercício 6 de INE5406
--	Description: Contém a descrição da entidade `sad_bo`, que representa o
--               bloco operativo (BO) do circuito para cálculo da soma das
--               diferenças absolutas (SAD - Sum of Absolute Differences).
--               Este bloco implementa o *datapath* principal do circuito e
--               realiza operações como subtração, valor absoluto e acumulação
--               dos valores calculados. Além disso, também será feito aqui o
--               calculo de endereçamento e do sinal de controle do laço de
--               execução (menor), que deve ser enviado ao bloco de controle (i.e.,
--               menor será um sinal de status gerado no BO).
--               A parametrização é feita por meio do tipo
--               `datapath_configuration_t` definido no pacote `sad_pack`.
--               Os parâmetros incluem:
--               - `bits_per_sample`: número de bits por amostra; (uso obrigatório)
--               - `samples_per_block`: número total de amostras por bloco; (uso 
--                  opcional, útil para definição do número de bits da sad e 
--                  endereço, conforme feito no top-level, i.e., no arquivo sad.vhdl)
--               - `parallel_samples`: número de amostras processadas em paralelo.
--                  (uso opcional)
--               A arquitetura estrutural instanciará os componentes necessários
--               à implementação completa do bloco operativo.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sad_pack.all;

-- Bloco Operativo (BO) do circuito SAD.
-- Responsável pelo processamento aritmético dos dados de entrada, incluindo
-- subtração, cálculo de valor absoluto e soma acumulada.
-- Totalmente parametrizável por meio do tipo `datapath_configuration_t`.
entity sad_bo is
	generic(
		CFG : datapath_configuration_t := (
			bits_per_sample   => 8,  -- número de bits por amostra
			samples_per_block => 64, -- número total de amostras por bloco
			parallel_samples  => 1   -- paralelismo no processamento
		)
	);
	port(
		clk : in std_logic;
		entradas: in ent_dados(A(CFG.bits_per_sample - 1 downto 0), B(CFG.bits_per_sample - 1 downto 0));
        comandos: in controle_comandos;
        saidas: out saidas_dados(SAD(sad_length(CFG.bits_per_sample, CFG.samples_per_block)- 1 downto 0), address(address_length(CFG.samples_per_block, CFG.parallel_samples) - 1 downto 0));
        status: out controle_status
	);
end entity;
-- Não altere o nome da entidade! Como você quem irá instanciar, neste caso podes
-- mudar o nome da arquitetura, embora isso não seja necessário. 
-- A arquitetura será estrutural, composta por instâncias de componentes auxiliares.

architecture structure OF sad_bo is
    -- Se precisar, podes adicionar declarações aqui (remova este comentário).
begin


     address_module: ENTITY work.adressCa
        generic map(
            address_len => address_length(CFG.samples_per_block, CFG.parallel_samples)
        )
        port map(
            clk        => clk,
            enable     => comandos.ci,
            sel_mux    => comandos.zi,
            address    => saidas.address,
            menor => status.menor
        );
     
    
    sad_module: ENTITY work.SadCa
        generic map(
            bits_per_sample   => CFG.bits_per_sample,
            samples_per_block => CFG.samples_per_block
        )
        port map(
            clk      => clk,
            cpA      => comandos.cpA,
            cpB      => comandos.cpB,
            csoma    => comandos.csoma,
            zsoma    => comandos.zsoma,
            csad_reg => comandos.csad_reg,
            A        => entradas.A,
            B        => entradas.B,
            SAD      => saidas.SAD
        );
    
end architecture structure;