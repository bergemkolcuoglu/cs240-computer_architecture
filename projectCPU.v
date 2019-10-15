// Nuri Bergem Kolcuoğlu S004608 Department of Computer Science
`timescale 1ns / 1ps
module projectCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM, pCounter);
 
parameter SIZE = 10;

input clk, rst;
input wire [15:0] data_fromRAM;
output reg wrEn;
output reg [SIZE-1:0] addr_toRAM;
output reg [15:0] data_toRAM;
output reg [SIZE-1:0] pCounter;


reg [2:0]  opcode, opcodeNext;
reg [5:0]  w, operand, wNext, operandNext;
reg [SIZE-1:0] /*pCounter,*/ pCounterNext;
reg [15:0] num1, num1Next;
reg [4:0]  state, stateNext;


always @(posedge clk)begin
	state    <= #1 stateNext;
	pCounter <= #1 pCounterNext;
	opcode   <= #1 opcodeNext;
	w        <= #1 wNext;
	operand  <= #1 operandNext;
	num1     <= #1 num1Next;
	end

always @*begin
	stateNext    = state;
	pCounterNext = pCounter;
	opcodeNext   = opcode;
	wNext        = w;
	operandNext  = operand;
	num1Next     = num1;
	addr_toRAM   = 0;
	wrEn         = 0;
	data_toRAM   = 0;
if(rst)
	begin
	stateNext    = 0;
	pCounterNext = 0;
	opcodeNext   = 0;
	wNext        = 0;
	operandNext  = 0;
	num1Next     = 0;
	addr_toRAM   = 0;
	wrEn         = 0;
	data_toRAM   = 0;
	end
else 
	case(state)                       
		0: begin // reset to default
			pCounterNext = pCounter;
			opcodeNext   = opcode;
			wNext        = 0;
			operandNext  = 0;
			addr_toRAM   = pCounter;
			num1Next     = 0;
			wrEn         = 0;
			data_toRAM   = 0;
			stateNext    = 1;
		end
		1:begin // get operand
			opcodeNext   = {data_fromRAM[12], data_fromRAM[15:13]};
			wNext = data_fromRAM[11:6];
			operandNext = data_fromRAM[5: 0];
			addr_toRAM   = data_fromRAM[11:6];
			stateNext = 2;
		end
		2: begin // get w
			addr_toRAM   = w;
			num1Next     = data_fromRAM;
			stateNext = 3;
		end
		3: begin
			addr_toRAM   = w;
			num1Next     = data_fromRAM;

			if (opcodeNext == 4'b0000) // ADD
				stateNext = 4;
			else if (opcodeNext == 4'b0110) // BZ
				stateNext = 5;
			else if (opcodeNext == 4'b0101) // CP2W
				stateNext = 6;
			else if (opcodeNext == 4'b0010) // SRL
				stateNext = 7;
			else if (opcodeNext == 4'b0001) // NAND
				stateNext = 8;
			else if (opcodeNext == 4'b0011) // LT
				stateNext = 9;
			else if (opcodeNext == 4'b0111) // MUL
				stateNext = 10;
			else if (opcodeNext == 4'b0110) // CPfW
				stateNext = 11;
		end

		4: begin // ADD
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = w + num1;
			wrEn = 1;
			stateNext = 0;
		end
		5: begin // BZ 
			pCounterNext = num1;
			stateNext = 0;
		end
		6: begin // CP2W
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = num1;
			wrEn = 1;
			stateNext = 0;
		end
		7: begin // SRL
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			
			if (num2 < 32)
				data_toRAM = w >> num1;
			else
				data_toRAM = w << (num1 - 16);
				
			wrEn = 1;
			stateNext = 0;
		end
		8: begin // NAND
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = ~(w & num1);
			wrEn = 1;
			stateNext = 0;
		end
		9: begin // LT
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = w < num1;
			wrEn = 1;
			stateNext = 0;
		end
		10: begin // MUL
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = w * num1;
			wrEn = 1;
			stateNext = 0;
		end
		11: begin // CPfW PART 1
			addr_toRAM   = num1;
			stateNext = 12;
		end
		12: begin // CPfW PART 2
			num1Next = data_fromRAM;
			stateNext = 13;
		end
		13: begin // CPfW PART 3
			pCounterNext = pCounter + 1;
			addr_toRAM = w;
			data_toRAM = num1;
			wrEn = 1;
			stateNext = 0;
		end
		default: begin
			stateNext    = 0;
			pCounterNext = 0;
			opcodeNext   = 0;
			operand1Next = 0;
			wNext        = 0;
			num1Next     = 0;
			addr_toRAM   = 0;
			wrEn         = 0;
			data_toRAM   = 0;
		end
	endcase

end

endmodule




