module reciever_top(pclk,presetn,rxd,pop_rx_fifo,enable,lcr,rx_idle,rx_fifo_empty,rx_fifo_count,rx_fifo_out,rx_fifo_full,rx_overrun,parity_error,framing_error,break_error,time_out,push_rx_fifo);
	input pclk,presetn,rxd,pop_rx_fifo,enable;
	input [7:0] lcr;
	output rx_idle,rx_fifo_empty,rx_fifo_full,rx_overrun,parity_error,framing_error,break_error,time_out;
	output reg push_rx_fifo;
	output [4:0] rx_fifo_count;
	output [7:0] rx_fifo_out;

	//Internal registers and wires
	reg [3:0] rx_state,rx_nextstate;
	reg [3:0] bit_counter;
	reg [7:0] rx_buffer;
	wire [7:0] brc_value;
	reg framing_error_temp,rxd_d,rxd_dd,parity_error_tmp;
	reg [9:0] toc_value;
	reg [7:0] counter_b;
	reg [9:0] counter_t;

	//fifo instantiation
	fifo16_8 Rx_FIFO(.clk_in(pclk),.rstn(presetn),.push(push_rx_fifo),.pop(pop_rx_fifo),.data_in(rx_buffer),.data_out(rx_fifo_out),.full(rx_fifo_full),.empty(rx_fifo_empty),.count(rx_fifo_count));
	
	localparam IDLE = 4'b0000,
		  START = 4'b0001,
		  BIT0 = 4'b0010,
		  BIT1 = 4'b0011,
		  BIT2 = 4'b0100,
		  BIT3 = 4'b0101,
		  BIT4 = 4'b0110,
		  BIT5 = 4'b0111,
		  BIT6 = 4'b1000,
		  BIT7 = 4'b1001,
		  PARITY = 4'b1010,
		  STOP1  = 4'b1011,
		  STOP2  = 4'b1100;

	//Present state logic
	always@(posedge pclk)
	begin
		if(!presetn)
			rx_state <= IDLE;
		else
			rx_state <= rx_nextstate;
	end

	//Bit counter
	always@(posedge pclk)
	begin
		if(!presetn)
			bit_counter <= 4'b0;
		else if((rx_state != rx_nextstate) && enable)
			bit_counter <= 4'b0;
		else if(enable && (rx_state != IDLE))
			bit_counter <= bit_counter + 1'b1;
	end

	//Dual flop syncronizer
	always@(posedge pclk)
	begin
		if(!presetn)
			rxd_d <= 1'b1;
		else
			rxd_d <= rxd;
	end

	always@(posedge pclk)
	begin
		if(!presetn)
			rxd_dd <= 1'b1;
		else
			rxd_dd <= rxd_d;
	end

	// rx_buffer logic
	always@(posedge pclk)
	begin
		if(!presetn)
			rx_buffer <= 8'b0;
		else if(bit_counter == 4'h7 && enable)
		begin
			case(rx_state)
				BIT0: rx_buffer[0] <= rxd_dd;
				BIT1: rx_buffer[1] <= rxd_dd;
				BIT2: rx_buffer[2] <= rxd_dd;
				BIT3: rx_buffer[3] <= rxd_dd;
				BIT4: rx_buffer[4] <= rxd_dd;
				BIT5: rx_buffer[5] <= rxd_dd;
				BIT6: rx_buffer[6] <= rxd_dd;
				BIT7: rx_buffer[7] <= rxd_dd;
			endcase
		end
	end
	
	//Next state logic
	always@(*)
	  begin
		rx_nextstate = rx_state;
		
		  case(rx_state)
			  IDLE: begin
				  if(rxd_dd == 1'b0 && !break_error)
				  begin
					  rx_nextstate = START;					  
				  end
				  else
					  rx_nextstate = IDLE;
				end

			   START: begin
				   if(bit_counter == 4'h8 && enable && rxd_dd == 1'b0)
				   begin
					   rx_nextstate = BIT0;					  
				   end
				   else if(enable == 1'b1)
				   begin
					   rx_nextstate = START;
				   end
				  end

			    BIT0: begin
				    if(bit_counter == 4'hf && enable)
				    begin
					    rx_nextstate = BIT1;					    
				    end
				    else if(enable == 1'b1)
				    begin
					    rx_nextstate = BIT0;
				    end
				  end

			    BIT1: begin
				    if(bit_counter == 4'hf && enable)
				    begin
					    rx_nextstate = BIT2;					    
				    end
				    else if(enable == 1'b1)
				    begin
					    rx_nextstate = BIT1;
				    end
				  end

			    BIT2: begin
				    if(bit_counter == 4'hf && enable)
				    begin
					    rx_nextstate = BIT3;					    
				    end
				    else if(enable == 1'b1)
				    begin
					    rx_nextstate = BIT2;
				    end
				  end

			    BIT3: begin
				    if(bit_counter == 4'hf && enable)
				    begin
					    rx_nextstate = BIT4;					    
				    end
				    else if(enable == 1'b1)
				    begin
					    rx_nextstate = BIT3;
				    end
				  end

			     BIT4: begin
				    if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b00)
				    begin
					    rx_nextstate = BIT5;					    
				    end
				    else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b00 && lcr[3] == 1)
					    rx_nextstate = PARITY;
				    else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b00 && lcr[3] == 0)
					    rx_nextstate = STOP1;
				    else if(enable == 1'b1)
				    begin
					    rx_nextstate = BIT4;
				    end
				  end

			      BIT5: begin
				      if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b01)
				      begin
					      rx_nextstate = BIT6;					      
				      end
				      else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b01 && lcr[3] == 1)
					      rx_nextstate = PARITY;
				      else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b01 && lcr[3] == 0)
					      rx_nextstate = STOP1;
				      else if(enable == 1'b1)
				      begin
				    	      rx_nextstate = BIT5;
				      end
				     end

			       BIT6: begin
				       if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b10)
				       begin
					       rx_nextstate = BIT7;					       
				       end
				       else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b10 && lcr[3] == 1)
				  	       rx_nextstate = PARITY;
				       else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b10 && lcr[3] == 0)
					       rx_nextstate = STOP1;
				       else if(enable == 1'b1)
				       begin
					       rx_nextstate = BIT6;
				       end
				      end

			        BIT7: begin
					if(bit_counter == 4'hf && enable && lcr[1:0] ==2'b11 && lcr[3] == 1'b1)
					begin
						rx_nextstate = PARITY;						
					end
				        else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b11 && lcr[3] == 1'b0)
					        rx_nextstate = STOP1;
				        else if(enable == 1'b1)
					begin
					        rx_nextstate = BIT7;
					end
				      end

				PARITY: begin
					  if(bit_counter == 4'hf && enable)
					  begin
						  rx_nextstate = STOP1;						  
					  end
					  else if(enable == 1'b1)
					  begin
						  rx_nextstate = PARITY;
					  end
					end

				STOP1: begin
					 if(bit_counter == 4'hf && enable && lcr[2] == 1'b0)
					 begin
						 rx_nextstate = STOP2;						 
					 end
					 else if(enable == 1'b1)
					 begin
						 rx_nextstate = STOP1;
					 end
				       end

				STOP2: begin
					  if(!break_error)
						  rx_nextstate = IDLE;
					  else
						  rx_nextstate = STOP2;
				       end
				default: rx_nextstate = IDLE;
		  endcase
	  end
	  
	  //parity logic
	  always@(posedge pclk)
	  begin
		if(rx_state == IDLE)
			parity_error_tmp <= 1'b0;
		else if(rx_state == PARITY && bit_counter == 4'h7 && enable)
		begin
			case(lcr[5:3])
				3'b001: parity_error_tmp <= ((~^rx_buffer) != rxd_dd);
				3'b011: parity_error_tmp <= ((^rx_buffer) != rxd_dd);
				3'b101: parity_error_tmp <= (1'b1 != rxd_dd);
				3'b111: parity_error_tmp <= (1'b0 != rxd_dd);
				default: parity_error_tmp <= 1'b0;
			endcase
		end
	  end
		
	  //framing_error
	  always@(posedge pclk)
	  begin
		if(rx_state == IDLE)
			framing_error_temp <= 1'b0;
		else if(bit_counter == 4'h7 && (rx_state == STOP1 || rx_state == STOP2))
			framing_error_temp <= (rxd_dd == 1'b0);
	  end

	  //counter for break interrupt error
	  always@(posedge pclk)
	  begin
		  if(!presetn)
			  counter_b <= 8'd159;
		  else if(rxd_dd)
			  counter_b <= brc_value;
		  else if(enable && (counter_b != 8'd0))
			  counter_b <= counter_b - 1'b1;
		  else
			  counter_b <= counter_b;
	  end

	  //Counter for time out
	  always@(posedge pclk)
	  begin
		  if(!presetn)
			  counter_t <= 10'd639;
		  else if(push_rx_fifo || pop_rx_fifo || (rx_fifo_count == 5'b0))
			  counter_t <= toc_value;
		  else if(enable && (counter_t != 10'd0))
			  counter_t <= counter_t - 1'b1;
		  else 
			  counter_t <= counter_t;
	  end

	  //toc values
	  always@(*)
	  begin
		  case(lcr[3:0])
			  4'b0000: toc_value = 10'd447;
			  4'b0001: toc_value = 10'd511;
			  4'b0010: toc_value = 10'd575;
			  4'b0011: toc_value = 10'd639;
			  4'b0100: toc_value = 10'd511;
			  4'b0101: toc_value = 10'd575;
			  4'b0110: toc_value = 10'd639;
			  4'b0111: toc_value = 10'd703;
			  4'b1000: toc_value = 10'd511;
			  4'b1001: toc_value = 10'd575;
			  4'b1010: toc_value = 10'd639;
			  4'b1011: toc_value = 10'd703;
			  4'b1100: toc_value = 10'd575;
			  4'b1101: toc_value = 10'd639;
			  4'b1110: toc_value = 10'd703;
			  4'b1111: toc_value = 10'd767;
			  default: toc_value = 10'd0;
		  endcase
	  end
	  
	  //logic for writing into fifo
	  always@(posedge pclk)
	  begin
	  if(!presetn)
			push_rx_fifo <= 1'b0;
	  else if((rx_state == STOP1) && !rx_fifo_full && bit_counter == 4'hf && enable)
			push_rx_fifo <= 1'b1;
	  else
	        push_rx_fifo <= 1'b0;
	  end

	  assign parity_error = parity_error_tmp;
	  assign framing_error = framing_error_temp;
	  assign break_error = (counter_b == 0)?1'b1:1'b0;
	  assign time_out = (counter_t == 0)?1'b1:1'b0;
	  assign brc_value = toc_value[9:2];
	  assign rx_overrun = (rx_fifo_full);
	  assign rx_idle = (rx_state == IDLE);
	  
endmodule
