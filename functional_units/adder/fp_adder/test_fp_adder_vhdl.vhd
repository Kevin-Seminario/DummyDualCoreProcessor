library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity test_fp_adder_vhdl is
end test_fp_adder_vhdl;

architecture sim of test_fp_adder_vhdl is 
    signal num1        : std_logic_vector(31 downto 0) := (others => '0');
    signal num2        : std_logic_vector(31 downto 0) := (others => '0');
    signal sub         : std_logic := '0';
    signal out_vec     : std_logic_vector(31 downto 0);
    
begin
    fp_adder_test  : entity work.fp_adder_vhdl
        generic map (
            E_VALUE => 8,
	        M_VALUE => 23
        )
        port map (
            num1    => num1,
            num2    => num2,
            sub     => sub,
            out_vec => out_vec
        );

    stimulus: process
        procedure check(
            a, b        : std_logic_vector(31 downto 0);
            s           : std_logic;
            exp_res     : std_logic_vector(31 downto 0);
            name        : string) is
        begin
            num1 <= a;
            num2 <= b;
            sub <= s;
            wait for 20 ns;
            assert out_vec = exp_res
                report name & ": wrong result, expected: " & to_hstring(exp_res) & ", actual: " & to_hstring(out_vec) severity error;        
        end procedure;

    begin
        check(x"3FE00000", x"3FE00000", '0', x"40600000", "1.75 + 1.75 = 3.5"); 
        check(x"3F800000", x"3F800000", '0', x"40000000", "1.0 + 1.0 = 2.0");
        check(x"3FA00000", x"3FA00000", '0', x"40200000", "1.25 + 1.25 = 2.5");
        check(x"3FC00000", x"40200000", '0', x"40800000", "1.5 + 2.5 = 4.0");
        check(x"3F000000", x"3E800000", '0', x"3F400000", "0.5 + 0.25 = 0.75");
        check(x"40600000", x"3FC00000", '0', x"40A00000", "3.5 + 1.5 = 5.0");
        check(x"41200000", x"3F000000", '0', x"41280000", "10.0 + 0.5 = 10.5");
        check(x"41000000", x"3E000000", '0', x"41020000", "8.0 + 0.125 = 8.125");
        check(x"BFC00000", x"BFC00000", '0', x"C0400000", "-1.5 + -1.5 = -3.0");

        check(x"40200000", x"3FA00000", '1', x"3FA00000", "2.5 - 1.25 = 1.25");
        check(x"40800000", x"3F800000", '1', x"40400000", "4.0 - 1.0 = 3.0");
        check(x"3FC00000", x"3F000000", '1', x"3F800000", "1.5 - 0.5 = 1.0");
        check(x"40A00000", x"40000000", '1', x"40400000", "5.0 - 2.0 = 3.0");

        check(x"3F800000", x"40200000", '1', x"BFC00000", "1.0 - 2.5 = -1.5");
        check(x"BF800000", x"40200000", '0', x"3FC00000", "-1.0 + 2.5 = 1.5");
        check(x"40200000", x"40200000", '1', x"00000000", "2.5 - 2.5 = +0");

        report "Testbench finished" severity note;
        wait;
    end process stimulus;
end architecture sim;
