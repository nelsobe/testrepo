library ieee;
use ieee.std_logic_1164.all;

entity lfsr is
    port (
	clk: in std_logic;
	rst: in std_logic;
	load: in std_logic;
	din : in std_logic;
	dout: out std_logic
	);
end entity;

architecture rtl of lfsr is 
	signal sr : std_logic_vector(63 downto 0);
	signal xor_bits : std_logic_vector(63 downto 0);
	signal partials : std_logic_vector(0 to 3);
	signal next_bit : std_logic;
begin

	process(clk) 
		variable nb: std_logic;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				next_bit <= '0';
			else
				if xor_bits(0) = '1' then
					nb := next_bit;
				else
					nb := '0';
				end if;
				next_bit <= not (nb xor partials(0) xor partials(1) xor partials(2) xor partials(3));
			end if;
		end if;
	end process;

	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				sr <= (others => '0');
			elsif load = '0' then
				sr <= sr(62 downto 0) & next_bit;
			end if;
		end if;
	end process;

	process(clk) 
        variable sum: std_logic := '0';
        variable k,m : integer;
	begin
		if rising_edge(clk) then
			for j in 1 to 15 loop
				if xor_bits(j) = '1' then
					if j = 1 then
						sum := sum xor next_bit;
					else
						sum := sum xor sr(j - 2);
					end if;
				end if;

				partials(0) <= sum;
			end loop;
		
            for i in 1 to 3 loop
                sum := '0';
                for j in 0 to 15 loop
                    k := i * 16 + j - 2;
                    m := i * 16 + j;
                    if xor_bits(m) = '1' then
                        sum := sum xor sr(k);
                    end if;
                end loop;
                partials(i) <= sum;
            end loop;
		end if;	
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				xor_bits <= (others => '0');
			elsif load = '1' then
				xor_bits <= xor_bits(62 downto 0) & din;
			end if;
		end if;
	end process;
	
	dout <= sr(0);
	
end architecture rtl;

