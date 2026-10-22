library ieee;
use ieee.std_logic_1164.all;

-- MIPS simplificado que so opera com word.
entity mips_word_toplevel is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        PC_out     : out std_logic_vector(31 downto 0);
        inst_out   : out std_logic_vector(31 downto 0);
        alu_out_o  : out std_logic_vector(31 downto 0);
        W_data_out : out std_logic_vector(31 downto 0)
    );
end entity mips_word_toplevel;

architecture behv1 of mips_word_toplevel is
    -- PC e proximo PC
    signal PC, nextPC, pc_plus4      : std_logic_vector(31 downto 0);
    signal BranchAddr, branch_target : std_logic_vector(31 downto 0);
    signal jump_target               : std_logic_vector(31 downto 0);

    -- instrucao e campos
    signal inst            : std_logic_vector(31 downto 0);
    signal opcode, funct   : std_logic_vector(5 downto 0);
    signal rs, rt, rd      : std_logic_vector(4 downto 0);
    signal imm16           : std_logic_vector(15 downto 0);
    signal imm_sext        : std_logic_vector(31 downto 0);
    signal imm_zext        : std_logic_vector(31 downto 0);

    -- banco de registradores
    signal W_addr                 : std_logic_vector(4 downto 0);
    signal A_data, B_data, W_data : std_logic_vector(31 downto 0);

    -- ULA principal
    signal alu_B, alu_out          : std_logic_vector(31 downto 0);
    signal zero, negative, overflow : std_logic;

    -- memoria de dados
    signal ram_out : std_logic_vector(31 downto 0);

    -- sinais de controle
    signal alu_op       : std_logic_vector(2 downto 0);
    signal alu_src2     : std_logic_vector(1 downto 0);
    signal control_type : std_logic_vector(1 downto 0);
    signal write_enable, rd_src, mem_read, word_we : std_logic;
begin
    ---------------------------------------------------------------- PC
    PC_REG : entity work.pc_register
        port map (clk => clk, reset => reset, enable => '1', D => nextPC, Q => PC);

    ALU1 : entity work.ULA  -- PC + 4
        port map (A => PC, B => x"00000004", control => "000", result => pc_plus4,
                  flag_neg => open, flag_zero => open, flag_overflow => open);

    BranchAddr <= imm_sext(29 downto 0) & "00";

    ALU2 : entity work.ULA  -- PC + 4 + BranchAddr
        port map (A => pc_plus4, B => BranchAddr, control => "000", result => branch_target,
                  flag_neg => open, flag_zero => open, flag_overflow => open);

    jump_target <= pc_plus4(31 downto 28) & inst(25 downto 0) & "00";

    with control_type select
        nextPC <= pc_plus4      when "00",
                  branch_target when "01",
                  jump_target   when "10",
                  A_data        when others;  -- "11" = jr

    ---------------------------------------------------------------- ROM
    ROM : entity work.mips_rom
        port map (addr => PC(11 downto 2), data => inst);

    opcode <= inst(31 downto 26);
    rs     <= inst(25 downto 21);
    rt     <= inst(20 downto 16);
    rd     <= inst(15 downto 11);
    imm16  <= inst(15 downto 0);
    funct  <= inst(5 downto 0);

    ---------------------------------------------------------------- Decoder
    DEC : entity work.mips_decoder
        port map (opcode => opcode, funct => funct, zero => zero,
                  alu_op => alu_op, write_enable => write_enable, rd_src => rd_src,
                  alu_src2 => alu_src2, control_type => control_type,
                  mem_read => mem_read, word_we => word_we);

    ---------------------------------------------------------------- Banco de registradores
    W_addr <= rd when rd_src = '0' else rt;

    REGS : entity work.reg_file
        port map (clk => clk, rst => reset,
                  A_addr => rs, B_addr => rt, W_addr => W_addr,
                  W_data => W_data, W_en => write_enable,
                  A_data => A_data, B_data => B_data);

    ---------------------------------------------------------------- ULA principal
    SEXT : entity work.sign_extender
        port map (a => imm16, y => imm_sext);

    imm_zext <= x"0000" & imm16;

    with alu_src2 select
        alu_B <= B_data         when "00",
                 imm_sext       when "01",
                 imm_zext       when "10",
                 (others => '0') when others;

    ALU : entity work.ULA
        port map (A => A_data, B => alu_B, control => alu_op, result => alu_out,
                  flag_neg => negative, flag_zero => zero, flag_overflow => overflow);

    ---------------------------------------------------------------- RAM
    -- a mips_ram recebe o endereco em bytes (32 bits) e usa addr(11 downto 2) internamente
    RAM : entity work.mips_ram
        port map (clk => clk, addr => alu_out, data_in => B_data, data_out => ram_out,
                  word_we => word_we, reset => reset);

    W_data <= alu_out when mem_read = '0' else ram_out;

    ---------------------------------------------------------------- saidas
    PC_out     <= PC;
    inst_out   <= inst;
    alu_out_o  <= alu_out;
    W_data_out <= W_data;
end architecture behv1;
