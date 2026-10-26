library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity int_adder_vhdl is
    generic (
        WIDTH : natural := 32
    );
    Port (
        num1         : in std_logic_vector((WIDTH - 1) downto 0);
        num2         : in std_logic_vector((WIDTH - 1) downto 0);
        sub          : in std_logic;
        out_vec      : out std_logic_vector((WIDTH - 1) downto 0);
        nzcv         : out std_logic_vector(3 downto 0)
    );
end entity int_adder_vhdl;
architecture rtl of int_adder_vhdl is
    signal acc_num2         : unsigned((WIDTH - 1) downto 0);
    signal carry_out_vec    : unsigned(WIDTH downto 0);
begin
    acc_num2        <= (unsigned(not num2)) when sub = '1' else (unsigned(num2));
    carry_out_vec   <= (('0' & unsigned(num1)) + ('0' & acc_num2) + to_unsigned(1, WIDTH + 1)) when sub = '1' else
                       (('0' & unsigned(num1)) + ('0' & acc_num2));

    out_vec         <= std_logic_vector(carry_out_vec(31 downto 0));

    -- NZCV(0) = Negative flag, NZCV(1) = Zero flag, NZCV(2) = Carry out flag, NZCV(3) = Overflow flag
    nzcv(0) <= (acc_num2((WIDTH - 1)) xnor num1((WIDTH - 1))) and (num1((WIDTH - 1)) xor out_vec((WIDTH - 1)));
    nzcv(1) <= carry_out_vec(WIDTH);
    nzcv(2) <= '1' when carry_out_vec(31 downto 0) = 0 else '0';
    nzcv(3) <= carry_out_vec((WIDTH - 1));
end architecture;

