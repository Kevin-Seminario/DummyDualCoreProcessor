library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_vhdl is
    generic (
        E_VALUE : natural := 8;
        M_VALUE : natural := 23
    );
    Port (
        num1        : in std_logic_vector((E_VALUE + M_VALUE) downto 0);
        num2        : in std_logic_vector((E_VALUE + M_VALUE) downto 0);
        sub         : in std_logic;
        out_vec     : out std_logic_vector((E_VALUE + M_VALUE) downto 0)
    );
end entity fp_adder_vhdl;
architecture rtl of fp_adder_vhdl is
begin
    fp_addition: process(all)
        variable temp_mantissa  : unsigned((M_VALUE) downto 0) := (others => '0');
        variable num1_mantissa  : unsigned((M_VALUE) downto 0) := (others => '0');
        variable num2_mantissa  : unsigned((M_VALUE) downto 0) := (others => '0');
        variable temp_exp       : unsigned((E_VALUE - 1) downto 0) := (others => '0');
        variable num1_exp       : unsigned((E_VALUE - 1) downto 0) := (others => '0');
        variable num2_exp       : unsigned((E_VALUE - 1) downto 0) := (others => '0');
        variable temp_sign      : std_logic := '0';
        variable num1_sign      : std_logic := '0';
        variable num2_sign      : std_logic := '0';

        variable out_mantissa   : unsigned((M_VALUE + 1) downto 0);
        variable out_exp        : unsigned((E_VALUE) downto 0);
        variable out_sign       : std_logic;
        
        -- May delete as bias should not be necessary for FP addition
        -- variable bias           : unsigned(E_VALUE - 1 downto 0) := to_unsigned (2 ** (E_VALUE - 1) - 1, E_VALUE);
    begin 
        -- Fetches the most significant bit, the sign bit	       
        num1_sign := num1(M_VALUE + E_VALUE);
        num2_sign := not num2(M_VALUE + E_VALUE) when sub else num2(M_VALUE + E_VALUE);

        -- Fetches the mantissa without the sign bit and flips them according to sign and if subtracting
        num1_mantissa := (unsigned('1' & num1(M_VALUE - 1 downto 0)));
        num2_mantissa := (unsigned('1' & num2(M_VALUE - 1 downto 0)));

        -- Fetches the exponent with the bias not applied
        num1_exp := (unsigned(num1(M_VALUE + E_VALUE - 1 downto M_VALUE)));
        num2_exp := (unsigned(num2(M_VALUE + E_VALUE - 1 downto M_VALUE)));
        -- Might need to handle subnormals

        -- Checks to make sure that num1 is the larger number
        if num1_exp < num2_exp or (num1_exp = num2_exp and num1_mantissa < num2_mantissa) then
            temp_mantissa := num1_mantissa;
            num1_mantissa := num2_mantissa;
            num2_mantissa := temp_mantissa;
            temp_exp := num1_exp;
            num1_exp := num2_exp;
            num2_exp := temp_exp;
            temp_sign := num1_sign;
            num1_sign := num2_sign;
            num2_sign := temp_sign;
        end if;
         
        -- Subtracts only if the signs are mistmatched between the two numbers
        out_mantissa := (resize(num1_mantissa, M_VALUE + 2) - shift_right(num2_mantissa, to_integer(num1_exp - num2_exp))) when not (num1_sign = num2_sign) 
                        else (resize(num1_mantissa, M_VALUE + 2) + shift_right(num2_mantissa, to_integer(num1_exp - num2_exp)));
        out_exp := '0' & num1_exp;

        -- Checks if there was a carry out to shift the mantissa properly and increment the exponent
        if out_mantissa(M_VALUE + 1) = '1' then
            out_exp := out_exp + 1;
            out_mantissa := shift_right(out_mantissa, 1);
            if out_exp(E_VALUE) = '1' then
                out_exp := (others => '1');
            end if;
        -- Checks if there was a subtraction of the most significant bit and loops while decrementing the exponent
        elsif out_mantissa(M_VALUE) = '0' then
            while out_mantissa(M_VALUE) = '0' and (or out_exp) = '1' loop
                out_exp := out_exp - 1;
                out_mantissa := shift_left(out_mantissa, 1);
            end loop;
        end if;
        out_sign := num1_sign;
        out_vec <= std_logic_vector(out_sign & out_exp((E_VALUE - 1) downto 0) & out_mantissa((M_VALUE - 1) downto 0));
    end process fp_addition;  
end;
