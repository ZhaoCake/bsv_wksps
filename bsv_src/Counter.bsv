package Counter;

// Simple counter module for demonstration
interface Counter_IFC;
    method Action increment;
    method UInt#(8) get_count;
    method Action reset_count;
endinterface

module mkCounter (Counter_IFC);
    Reg#(UInt#(8)) count <- mkReg(0);
    
    method Action increment;
        count <= count + 1;
    endmethod
    
    method UInt#(8) get_count = count;
    
    method Action reset_count;
        count <= 0;
    endmethod
    
endmodule

endpackage
