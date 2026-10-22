library ieee;
use ieee.std_logic_1164.all;

-- Registrador do PC (32 bits), reset assincrono para 0.
entity pc_register is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector(31 downto 0);
        Q      : out std_logic_vector(31 downto 0)
    );
end entity pc_register;

architecture behv1 of pc_register is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            Q <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end architecture behv1;
