----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Luis Haro
-- 
-- Create Date: 06/25/2026 03:38:08 PM
-- Design Name: TOP_Photoresistor
-- Module Name: TOP - Behavioral
-- Project Name: Potoresistor XADC test
-- Target Devices: 
-- Tool Versions: 
-- Description: This is to how light reacts to a photoresistor shown by using leds and the XADC wizard
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           vauxp6 : in STD_LOGIC; -- JXADC1
           vauxn6 : in STD_LOGIC; -- JXADC7
           led : out STD_LOGIC_VECTOR (15 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC
           );
end TOP;

architecture Behavioral of TOP is
 
component xadc_wiz_0 is
        port (
            daddr_in              : in  STD_LOGIC_VECTOR(6 downto 0);
            den_in                : in  STD_LOGIC;
            di_in                 : in  STD_LOGIC_VECTOR(15 downto 0);
            dwe_in                : in  STD_LOGIC;
            do_out                : out STD_LOGIC_VECTOR(15 downto 0);
            drdy_out              : out STD_LOGIC;
            dclk_in               : in  STD_LOGIC;
            reset_in              : in  STD_LOGIC;

            vauxp6                : in  STD_LOGIC;
            vauxn6                : in  STD_LOGIC;

            busy_out              : out STD_LOGIC;
            channel_out           : out STD_LOGIC_VECTOR(4 downto 0);
            eoc_out               : out STD_LOGIC;
            eos_out               : out STD_LOGIC;

            ot_out                : out STD_LOGIC;
            vccaux_alarm_out      : out STD_LOGIC;
            vccint_alarm_out      : out STD_LOGIC;
            user_temp_alarm_out   : out STD_LOGIC;
            alarm_out             : out STD_LOGIC;

            vp_in                 : in  STD_LOGIC;
            vn_in                 : in  STD_LOGIC
        );
    end component;
    
signal do_out : std_logic_vector (15 downto 0);
signal drdy_out : std_logic;
signal eoc_out : std_logic;
signal adc_value : unsigned(11 downto 0) := (others => '0');
signal mv_value : integer range 0 to 1000 := 0;

signal refresh_counter : unsigned(19 downto 0) := (others => '0');
signal digit_select    : unsigned(1 downto 0);

signal update_counter : unsigned(23 downto 0) := (others => '0');
constant UPDATE_MAX : unsigned(23 downto 0) := to_unsigned(9999999, 24);

signal adc_filtered : unsigned(11 downto 0) := (others => '0');

signal adc_sum      : unsigned(15 downto 0) := (others => '0');
signal sample_count : unsigned(3 downto 0) := (others => '0');

begin

xadc_inst : xadc_wiz_0
port map (
daddr_in => "0010110",
den_in => eoc_out,
di_in => x"0000",
dwe_in => '0',
do_out => do_out,
drdy_out => drdy_out,
dclk_in => clk,
reset_in => reset,
vauxp6 => vauxp6,
vauxn6  => vauxn6,

busy_out => open,
channel_out => open,
eoc_out => eoc_out,
eos_out => open,

ot_out => open,
vccaux_alarm_out => open,
vccint_alarm_out => open,
user_temp_alarm_out => open,
alarm_out => open,

vp_in                 => '0',
vn_in                 => '0'
);

process(clk)
variable new_sample : unsigned(11 downto 0);
variable next_sum   : unsigned(15 downto 0);

begin
if rising_edge(clk) then

if reset = '1' then
adc_value    <= (others => '0');
adc_filtered <= (others => '0');
adc_sum      <= (others => '0');
sample_count <= (others => '0');

elsif drdy_out = '1' then
new_sample := unsigned(do_out(15 downto 4));
adc_value <= new_sample;

next_sum := adc_sum + resize(new_sample, 16);

if sample_count = to_unsigned(15, 4) then
adc_filtered <= next_sum(15 downto 4);

adc_sum      <= (others => '0');
sample_count <= (others => '0');

else

adc_sum      <= next_sum;
sample_count <= sample_count + 1;

end if;
end if;
end if;
end process;


gen_leds : for i in 0 to 15 generate
led(i) <= '1' when  adc_filtered > to_unsigned((i+1)*80,12) else '0';
end generate;


process(clk)
begin
if rising_edge(clk) then
refresh_counter <= refresh_counter + 1;

if reset = '1' then
update_counter <= (others => '0');
mv_value <= 0;

elsif update_counter = UPDATE_MAX then
update_counter <= (others => '0');

          
mv_value <= ((to_integer( adc_filtered) * 1000) + 2047) / 4095;

else
update_counter <= update_counter + 1;
end if;
end if;
end process;

digit_select <= refresh_counter(15 downto 14);

process(digit_select, mv_value)
variable digit : integer range 0 to 9;
begin
an <= "1111";
dp <= '1';
seg <= "1111111";
digit := 0;

case digit_select is


when "00" =>
an <= "1110";
digit := mv_value mod 10;
dp <= '1';


when "01" =>
an <= "1101";
digit := (mv_value / 10) mod 10;
dp <= '1';


when "10" =>
an <= "1011";
digit := (mv_value / 100) mod 10;
dp <= '1';

        
when others =>
an <= "0111";
digit := mv_value / 1000;
dp <= '0'; -- decimal point ON
end case;

    
    case digit is
        when 0 => seg <= "1000000";
        when 1 => seg <= "1111001";
        when 2 => seg <= "0100100";
        when 3 => seg <= "0110000";
        when 4 => seg <= "0011001";
        when 5 => seg <= "0010010";
        when 6 => seg <= "0000010";
        when 7 => seg <= "1111000";
        when 8 => seg <= "0000000";
        when 9 => seg <= "0010000";
        when others => seg <= "1111111";
    end case;
end process;

end behavioral;

