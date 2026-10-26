library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity test_int_adder_vhdl is
end test_int_adder_vhdl;

architecture sim of test_int_adder_vhdl is
    signal num1, num2, out_vec  : std_logic_vector(31 downto 0) := (others => '0');
    signal sub                  : std_logic := '0';
    signal nzcv                 : std_logic_vector(3 downto 0) := (others => '0');
begin
    int_adder_test  : entity work.int_adder_vhdl
        generic map (
            WIDTH => 32
        )
        port map (
            num1    => num1,
            num2    => num2,
            sub     => sub,
            out_vec => out_vec,
            nzcv    => nzcv
        );

    stimulus: process
        procedure check(
            a, b        : std_logic_vector(31 downto 0);
            s           : std_logic;
            exp_res     : std_logic_vector(31 downto 0);
            exp_nzcv    : std_logic_vector(3 downto 0);
            name        : string) is
        begin
            num1 <= a;
            num2 <= b;
            sub <= s;
            wait for 10 ns;
            assert out_vec = exp_res
                report name & ": wrong result" severity error;
            assert nzcv = exp_nzcv
                report name & ": wrong flags" severity error;
        end procedure;

    begin
        
        check(x"0000_0001", x"0000_0001", '0', x"0000_0002", "0000", "1 + 1");
        check(x"0000_0001", x"0000_0001", '1', x"0000_0000", "0110", "1 - 1");
        check(x"0000_0001", x"0000_0001", '1', x"0000_0001", "0110", "1 - 1 bad"); -- Fails on purpose

        report "Testbench finished" severity note;
        wait;
    end process stimulus;
end architecture;