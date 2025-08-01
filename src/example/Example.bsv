package Example;

// Simple counter module as an example
interface Counter;
    method Action increment();
    method Action decrement();
    method ActionValue#(UInt#(8)) read();
    method Action reset();
endinterface

module mkCounter (Counter);
    Reg#(UInt#(8)) count <- mkReg(0);
    
    method Action increment();
        count <= count + 1;
    endmethod
    
    method Action decrement();
        if (count > 0)
            count <= count - 1;
    endmethod
    
    method ActionValue#(UInt#(8)) read();
        return count;
    endmethod
    
    method Action reset();
        count <= 0;
    endmethod
endmodule

// Top-level module
module mkExample (Empty);
    Counter counter <- mkCounter();
    Reg#(UInt#(8)) cycle <- mkReg(0);
    
    rule increment_cycle;
        cycle <= cycle + 1;
        if (cycle < 10)
            counter.increment();
        else if (cycle < 15)
            counter.decrement();
        else if (cycle == 15)
            counter.reset();
    endrule
    
    rule display;
        let val <- counter.read();
        $display("Cycle %d: Counter = %d", cycle, val);
        if (cycle >= 20)
            $finish();
    endrule
endmodule

endpackage