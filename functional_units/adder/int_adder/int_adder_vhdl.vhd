library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity int_adder_vhdl is
    Port (
        num1         : in std_logic_vector(31 downto 0);
        num2         : in std_logic_vector(31 downto 0);
        sub          : in std_logic;
        out_vec      : out std_logic_vector(31 downto 0);
        nzcv         : out std_logic_vector(3 downto 0)
    );
end entity;
architecture rtl of int_adder_vhdl is
    signal acc_num2        : unsigned(31 downto 0);
    signal carry_out_vec    : unsigned(32 downto 0);
begin
    acc_num2        <= (unsigned(not num2)) when sub = '1' else (unsigned(num2));
    carry_out_vec   <= (('0' & unsigned(num1)) + ('0' & acc_num2) + to_unsigned(1, 33)) when sub = '1' else
                       (('0' & unsigned(num1)) + ('0' & acc_num2));

    out_vec         <= std_logic_vector(carry_out_vec(31 downto 0));

    -- NZCV(0) = Negative flag, NZCV(1) = Zero flag, NZCV(2) = Carry out flag, NZCV(3) = Overflow flag
    nzcv(0) <= (acc_num2(31) xnor num1(31)) and (num1(31) xor out_vec(31));
    nzcv(1) <= carry_out_vec(32);
    nzcv(2) <= '1' when carry_out_vec(31 downto 0) = 0 else '0';
    nzcv(3) <= carry_out_vec(31);
end architecture;

