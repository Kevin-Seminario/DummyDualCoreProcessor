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
        
        -- 1.25 + 1.25 = 2.5
        -- 0 100_0000_0 100_0000_0000_0000_0000
        -- 0 100_0000_1 010_0000_0000
        check(x"60600000", x"60600000", '0', x"60A0_0000", "1.25 + 1.25"); 

        report "Testbench finished" severity note;
        wait;
    end process stimulus;
end architecture sim;
