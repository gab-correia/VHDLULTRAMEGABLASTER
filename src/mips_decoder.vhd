library ieee;
use ieee.std_logic_1164.all;

-- Decodificador do MIPS so-word.
--   alu_op       : codigo da ULA (000 ADD, 001 SUB, 100 AND, 101 OR, 110 XOR, 111 NOR)
--   rd_src       : 0 = rd, 1 = rt
--   alu_src2     : 0 = B_data, 1 = sign_ext(imm16), 2 = zero_ext(imm16)
--   control_type : 0 = PC+4, 1 = branch, 2 = jump, 3 = jr
--   mem_read     : 0 = alu_out, 1 = RAM
entity mips_decoder is
    port (
        opcode       : in  std_logic_vector(5 downto 0);
        funct        : in  std_logic_vector(5 downto 0);
        zero         : in  std_logic;
        alu_op       : out std_logic_vector(2 downto 0);
        write_enable : out std_logic;
        rd_src       : out std_logic;
        alu_src2     : out std_logic_vector(1 downto 0);
        control_type : out std_logic_vector(1 downto 0);
        mem_read     : out std_logic;
        word_we      : out std_logic
    );
end entity mips_decoder;

architecture behv1 of mips_decoder is
begin
    process(opcode, funct, zero)
    begin
        -- valores padrao: nao escreve nada e segue para PC+4
        alu_op       <= "000";
        write_enable <= '0';
        rd_src       <= '0';
        alu_src2     <= "00";
        control_type <= "00";
        mem_read     <= '0';
        word_we      <= '0';

        case opcode is
            when "000000" =>  -- tipo R
                write_enable <= '1';
                case funct is
                    when "100000" => alu_op <= "000";  -- add
                    when "100010" => alu_op <= "001";  -- sub
                    when "100100" => alu_op <= "100";  -- and
                    when "100101" => alu_op <= "101";  -- or
                    when "100110" => alu_op <= "110";  -- xor
                    when "100111" => alu_op <= "111";  -- nor
                    when "001000" =>                   -- jr
                        write_enable <= '0';
                        control_type <= "11";
                    when others => write_enable <= '0';
                end case;

            when "001000" =>  -- addi
                alu_op <= "000"; alu_src2 <= "01"; rd_src <= '1'; write_enable <= '1';
            when "001100" =>  -- andi
                alu_op <= "100"; alu_src2 <= "10"; rd_src <= '1'; write_enable <= '1';
            when "001101" =>  -- ori
                alu_op <= "101"; alu_src2 <= "10"; rd_src <= '1'; write_enable <= '1';
            when "001110" =>  -- xori
                alu_op <= "110"; alu_src2 <= "10"; rd_src <= '1'; write_enable <= '1';

            when "100011" =>  -- lw
                alu_op <= "000"; alu_src2 <= "01"; rd_src <= '1'; write_enable <= '1';
                mem_read <= '1';
            when "101011" =>  -- sw
                alu_op <= "000"; alu_src2 <= "01";
                word_we <= '1';

            when "000100" =>  -- beq
                alu_op <= "001";
                if zero = '1' then control_type <= "01"; end if;
            when "000101" =>  -- bne
                alu_op <= "001";
                if zero = '0' then control_type <= "01"; end if;

            when "000010" =>  -- j
                control_type <= "10";

            when others => null;
        end case;
    end process;
end architecture behv1;
