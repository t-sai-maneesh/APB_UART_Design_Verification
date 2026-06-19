class fcr_reg extends uvm_reg;
        `uvm_object_utils(fcr_reg)

        rand uvm_reg_field no_of_char;
        uvm_reg_field reserved;
        rand uvm_reg_field tx_fifo_empty;
        rand uvm_reg_field rx_fifo_empty;
        uvm_reg_field reserved2;

        //Constructor function
        function new(string name = "fcr_reg")
                super.new(name,8,uvm_no_coverage);
        endfunction

        //Build function
        virtual function void build();
                no_of_char = uvm_reg_field::type_id::create("no_of_char");
                reserved   = uvm_reg_field::type_id::create("reserved");
                tx_fifo_empty = uvm_reg_field::type_id::create("tx_fifo_empty");
                rx_fifo_empty = uvm_reg_field::type_id::create("rx_fifo_empty");
                reserved2     = uvm_reg_field::type_id::create("reserved2");

                no_of_char.configure(this,2,6,"W",0,2'd0,1,1,0);
                reserved.configure(this,3,3,"w",0,3'd0,1,1,0);
                tx_fifo_empty.configure(this,1,2,"W",0,1'b0,1,1,0);
                rx_fifo_empty.configure(this,1,1,"W",0,1'b0,1,1,0);
                reserved2.configure(this,1,0,"W",0,1'b0,1,1,0);
        endfunction
endclass

