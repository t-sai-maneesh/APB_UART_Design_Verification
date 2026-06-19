module transmitter_top(pclk,presetn,pwdata,tx_fifo_push,enable,lcr,tx_fifo_count,busy,tx_fifo_full,tx_fifo_empty,txd);
	input pclk,presetn,tx_fifo_push,enable;
	input [7:0] pwdata,lcr;
	output busy,tx_fifo_full,tx_fifo_empty,txd;
	output [4:0] tx_fifo_count;

	// registers & wires
	wire [7:0] tx_fifo_out;
	reg pop_tx_fifo;
	reg [3:0] tx_state,tx_nextstate,bit_counter;
	reg [7:0] tx_buffer;
	reg txd_tmp;

	fifo16_8 Tx_FIFO(.clk_in(pclk),.rstn(presetn),.push(tx_fifo_push),.pop(pop_tx_fifo),.data_in(pwdata),.data_out(tx_fifo_out),.full(tx_fifo_full),.empty(tx_fifo_empty),.count(tx_fifo_count));
	
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

	  always@(posedge pclk)
	  begin
		  if(!presetn)
		  begin
			  tx_state <= IDLE;
			  //txd_tmp <= 1'b1;
			  //tx_buffer<=8'd0;
			  //pop_tx_fifo <= 1'b0;
			  //busy <= 1'b0;
			  //txd <= 1'b0;
		  end
		  else 
			  tx_state <= tx_nextstate;
	  end

	  always@(posedge pclk)
	  begin
		if(!presetn)
			bit_counter <= 4'b0;	
		else if(tx_state != tx_nextstate)
			bit_counter <= 4'b0;
		else if(enable && (tx_state != IDLE))
			bit_counter <= bit_counter + 1'b1;
		end
		
	  always@(posedge pclk)
	  begin
		if(!presetn)
			pop_tx_fifo <= 1'b0;
		else
			pop_tx_fifo <= ((tx_state == IDLE) && !tx_fifo_empty && enable);
	  end
	  
	  always@(posedge pclk)
	  begin
		if(!presetn)
			tx_buffer <= 8'b0;
		else if((tx_state == START) && enable)
			tx_buffer <= tx_fifo_out;
	  end
		
	  always@(*)
	  begin
	  //pop_tx_fifo=0;
	  txd_tmp = 1'b1;
	  tx_nextstate = tx_state;
		  case(tx_state)
			  IDLE: begin
				  //txd_tmp = 1'b1;
				  if(tx_fifo_empty == 1'b0 && enable)
				  begin
					  tx_nextstate = START;
					  
				  end
				  else
					  tx_nextstate = IDLE;
				end

			   START: begin 
				  //pop_tx_fifo = 1'b0;
				  //tx_buffer = tx_fifo_out;  
				   txd_tmp = 1'b0;
					if(bit_counter == 4'hf && enable)
				   begin
					   tx_nextstate = BIT0;
					  
				   end
					else if(enable == 1'b1)
				   begin
					   tx_nextstate = START;
					   //bit_counter = bit_counter + 1'b1;
				   end				   
					else
						tx_nextstate = START;
				  end

			    BIT0: begin
					 txd_tmp = tx_buffer[0];
				    if(bit_counter == 4'hf && enable)
				    begin
					    tx_nextstate = BIT1;
					    
				    end
				    else if(enable == 1'b1)
				    begin
					    tx_nextstate = BIT0;
					    //bit_counter = bit_counter + 1'b1;
				    end
					 else
						tx_nextstate = BIT0;
				  end

			    BIT1: begin
					 txd_tmp = tx_buffer[1];
				    if(bit_counter == 4'hf && enable)
				    begin
					    tx_nextstate = BIT2;
					    
				    end
				    else if(enable == 1'b1)
				    begin
					    tx_nextstate = BIT1;
					    //bit_counter = bit_counter + 1'b1;
				    end
					 else
						tx_nextstate = BIT1;
				  end

			    BIT2: begin
					 txd_tmp = tx_buffer[2];
				    if(bit_counter == 4'hf && enable)
				    begin
					    tx_nextstate = BIT3;
					    
				    end
				    else if(enable == 1'b1)
				    begin
					    tx_nextstate = BIT2;
					   // bit_counter = bit_counter + 1'b1;
				    end
					 else
						tx_nextstate = BIT2;
				  end

			    BIT3: begin
					 txd_tmp = tx_buffer[3];
				    if(bit_counter == 4'hf && enable)
				    begin
					    tx_nextstate = BIT4;
					    
				    end
				    else if(enable == 1'b1)
				    begin
					    tx_nextstate = BIT3;
					   // bit_counter = bit_counter + 1'b1;
				    end
					 else
						tx_nextstate = BIT3;
				  end

			     BIT4: begin
					 txd_tmp = tx_buffer[4];
				    if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b00)
				    begin
					    tx_nextstate = BIT5;
					    
				    end
				    else if(bit_counter == 4'hf && enable && lcr[1:0] == 0 && lcr[3] == 1)
					    tx_nextstate = PARITY;
				    else if(bit_counter == 4'hf && enable && lcr[1:0] == 0 && lcr[3] == 0)
					    tx_nextstate = STOP1;
				    else if(enable == 1'b1)
				    begin
					    tx_nextstate = BIT4;
					    //bit_counter = bit_counter + 1'b1;
				    end
					 else
						tx_nextstate = BIT4;
				  end

			      BIT5: begin
						txd_tmp = tx_buffer[5];
				      if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b01)
				      begin
					      tx_nextstate = BIT6;
					      
				      end
				      else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b01 && lcr[3] == 1)
					      tx_nextstate = PARITY;
				      else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b01 && lcr[3] == 0)
					      tx_nextstate = STOP1;
				      else if(enable == 1'b1)
				      begin
				    	      tx_nextstate = BIT5;
					     // bit_counter = bit_counter + 1'b1;
				      end
						else
							tx_nextstate = BIT5;
				     end

			       BIT6: begin
						 txd_tmp = tx_buffer[6];
				       if(bit_counter == 4'hf && enable && lcr[1:0] > 2'b10)
				       begin
					       tx_nextstate = BIT7;
					       
				       end
				       else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b10 && lcr[3] == 1)
				  	       tx_nextstate = PARITY;
				       else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b10 && lcr[3] == 0)
					       tx_nextstate = STOP1;
				       else if(enable == 1'b1)
				       begin
					       tx_nextstate = BIT6;
					      // bit_counter = bit_counter + 1'b1;
				       end
						 else
							tx_nextstate = BIT6;
				      end

			        BIT7: begin
					  txd_tmp = tx_buffer[7];
					if(bit_counter == 4'hf && enable && lcr[1:0] ==2'b11 && lcr[3] == 1'b1)
					begin
						tx_nextstate = PARITY;
						
					end
				        else if(bit_counter == 4'hf && enable && lcr[1:0] == 2'b11 && lcr[3] == 1'b0)
					        tx_nextstate = STOP1;
				        else if(enable == 1'b1)
					begin
					        tx_nextstate = BIT7;
						//bit_counter = bit_counter + 1'b1;
					end
					else
						tx_nextstate = BIT7;
				      end

				PARITY: begin
					  case(lcr[5:3])
								3'b001: txd_tmp = (~^tx_buffer);
								3'b011: txd_tmp = (^tx_buffer);
								3'b101: txd_tmp = 1'b1;
								3'b111: txd_tmp = 1'b0;
								default: txd_tmp = 1'b0;
							endcase
					  if(bit_counter == 4'hf && enable)
					  begin
						  tx_nextstate = STOP1;
						  
					  end
					  //else if(bit_counter == 4'hf && enable && lcr[3] == 1'b0)
						 // tx_nextstate = STOP2;
					  else if(enable == 1'b1)
					  begin
						  tx_nextstate = PARITY;
						  //bit_counter = bit_counter + 1'b1;
					  end
					  else
						tx_nextstate = PARITY;
					end

				STOP1: begin
					 txd_tmp = 1'b1;
					 if(bit_counter == 4'hf && enable && lcr[2] == 1'b1)
					 begin
						 tx_nextstate = STOP2;
						 
					 end
					 else if(bit_counter == 4'hf && enable && lcr[2] == 1'b0)
						 tx_nextstate = IDLE;
					 else if(enable == 1'b1)
					 begin
						 tx_nextstate = STOP1;
						 //bit_counter = bit_counter + 1'b1;
					 end
					 else
						tx_nextstate = STOP1;
				       end

				STOP2: begin
					  if(bit_counter == 4'hf && enable)
						  tx_nextstate = IDLE;
					  else
						  tx_nextstate = STOP2;
				       end
				default: tx_nextstate = STOP2;
		  endcase
	  end

	  assign busy = (tx_state == IDLE)?1'b0:1'b1;
	  assign txd = (lcr[6])?1'b0:txd_tmp;

endmodule


/*module transmitter_top(
    input        pclk,
    input        presetn,
    input  [7:0] pwdata,
    input        tx_fifo_push,
    input        enable,
    input  [7:0] lcr,
    output [4:0] tx_fifo_count,
    output       busy,
    output       tx_fifo_full,
    output       tx_fifo_empty,
    output       txd
);

  //---------------- Internal Signals ---------------- 
  wire [7:0] tx_fifo_out;
  reg        pop_tx_fifo;

  reg [3:0]  tx_state, tx_nextstate;
  reg [3:0]  bit_counter;
  reg [7:0]  tx_buffer;
  reg        txd_tmp;

  // ---------------- FIFO ---------------- /
  fifo16_8 Tx_FIFO (
    .clk_in  (pclk),
    .rstn    (presetn),
    .push    (tx_fifo_push),
    .pop     (pop_tx_fifo),
    .data_in (pwdata),
    .data_out(tx_fifo_out),
    .full    (tx_fifo_full),
    .empty   (tx_fifo_empty),
    .count   (tx_fifo_count)
  );

  // ---------------- FSM States ---------------- 
  localparam IDLE   = 4'd0,
             START  = 4'd1,
             BIT0   = 4'd2,
             BIT1   = 4'd3,
             BIT2   = 4'd4,
             BIT3   = 4'd5,
             BIT4   = 4'd6,
             BIT5   = 4'd7,
             BIT6   = 4'd8,
             BIT7   = 4'd9,
             PARITY = 4'd10,
             STOP1  = 4'd11,
             STOP2  = 4'd12;

  // ---------------- State Register ---------------- 
  always @(posedge pclk) begin
    if (!presetn)
      tx_state <= IDLE;
    else
      tx_state <= tx_nextstate;
  end

  // ---------------- Bit Counter ---------------- 
  always @(posedge pclk) begin
    if (!presetn)
      bit_counter <= 4'd0;
    else if (tx_state != tx_nextstate)
      bit_counter <= 4'd0;
    else if (enable)
      bit_counter <= bit_counter + 1'b1;
  end

  // ---------------- FIFO Pop (Registered) ---------------- 
  always @(posedge pclk) begin
    if (!presetn)
      pop_tx_fifo <= 1'b0;
    else
      pop_tx_fifo <= (tx_state == IDLE && !tx_fifo_empty && enable);
  end

  // ---------------- TX Buffer ---------------- 
  always @(posedge pclk) begin
    if (!presetn)
      tx_buffer <= 8'd0;
    else if (pop_tx_fifo)
      tx_buffer <= tx_fifo_out;
  end

  // ---------------- FSM Combinational Logic ---------------- 
  always @(*) begin
    tx_nextstate = tx_state;
    txd_tmp      = 1'b1;

    case (tx_state)

      IDLE: begin
        if (!tx_fifo_empty && enable)
          tx_nextstate = START;
      end

      START: begin
        txd_tmp = 1'b0;
        if (enable && bit_counter == 4'hF)
          tx_nextstate = BIT0;
      end

      BIT0: begin
        txd_tmp = tx_buffer[0];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = BIT1;
      end

      BIT1: begin
        txd_tmp = tx_buffer[1];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = BIT2;
      end

      BIT2: begin
        txd_tmp = tx_buffer[2];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = BIT3;
      end

      BIT3: begin
        txd_tmp = tx_buffer[3];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = BIT4;
      end

      BIT4: begin
        txd_tmp = tx_buffer[4];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = (lcr[1:0] > 2'b00) ? BIT5 :
                         (lcr[3])           ? PARITY : STOP1;
      end

      BIT5: begin
        txd_tmp = tx_buffer[5];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = (lcr[1:0] > 2'b01) ? BIT6 :
                         (lcr[3])           ? PARITY : STOP1;
      end

      BIT6: begin
        txd_tmp = tx_buffer[6];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = (lcr[1:0] > 2'b10) ? BIT7 :
                         (lcr[3])           ? PARITY : STOP1;
      end

      BIT7: begin
        txd_tmp = tx_buffer[7];
        if (enable && bit_counter == 4'hF)
          tx_nextstate = (lcr[3]) ? PARITY : STOP1;
      end

      PARITY: begin
        case (lcr[5:3])
          3'b001: txd_tmp = ~^tx_buffer; // even
          3'b011: txd_tmp =  ^tx_buffer; // odd
          3'b101: txd_tmp = 1'b1;
          3'b111: txd_tmp = 1'b0;
          default: txd_tmp = 1'b0;
        endcase
        if (enable && bit_counter == 4'hF)
          tx_nextstate = STOP1;
      end

      STOP1: begin
        txd_tmp = 1'b1;
        if (enable && bit_counter == 4'hF)
          tx_nextstate = (lcr[2]) ? STOP2 : IDLE;
      end

      STOP2: begin
        txd_tmp = 1'b1;
        if (enable && bit_counter == 4'hF)
          tx_nextstate = IDLE;
      end

      default: tx_nextstate = IDLE;
    endcase
  end

  // ---------------- Outputs ---------------- 
  assign busy = (tx_state != IDLE);
  assign txd  = (lcr[6]) ? 1'b0 : txd_tmp;

endmodule*/
