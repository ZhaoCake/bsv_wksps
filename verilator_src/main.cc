#include <iostream>
#include <memory>
#include <cstdint>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VmkCounter.h"

class CounterSimulator {
private:
    std::unique_ptr<VmkCounter> dut;
    std::unique_ptr<VerilatedVcdC> trace;
    uint64_t sim_time;
    uint64_t max_sim_time;

public:
    CounterSimulator(uint64_t max_time = 1000) 
        : sim_time(0), max_sim_time(max_time) {
        
        // Initialize Verilator
        const char* argv[] = {"sim"};
        Verilated::commandArgs(1, argv);
        Verilated::traceEverOn(true);
        
        // Create DUT instance
        dut = std::make_unique<VmkCounter>();
        
        // Initialize tracing
        trace = std::make_unique<VerilatedVcdC>();
        dut->trace(trace.get(), 99);
        trace->open("waves/simulation.vcd");
        
        std::cout << "🚀 Starting mkCounter Verilator simulation..." << std::endl;
        std::cout << "📊 Waveform will be saved to: waves/simulation.vcd" << std::endl;
    }
    
    ~CounterSimulator() {
        if (trace) {
            trace->close();
        }
        dut->final();
        std::cout << "✅ Simulation completed after " << sim_time << " cycles" << std::endl;
    }
    
    void reset() {
        // Apply reset for a few cycles
        dut->RST_N = 0;
        dut->EN_increment = 0;
        dut->EN_reset_count = 0;
        
        for (int i = 0; i < 5; i++) {
            tick();
        }
        dut->RST_N = 1;
        std::cout << "🔄 Reset applied" << std::endl;
    }
    
    void tick() {
        // Rising edge
        dut->CLK = 1;
        dut->eval();
        trace->dump(sim_time * 2);
        
        // Falling edge  
        dut->CLK = 0;
        dut->eval();
        trace->dump(sim_time * 2 + 1);
        
        sim_time++;
    }
    
    bool should_continue() {
        return sim_time < max_sim_time;
    }
    
    void increment_counter() {
        dut->EN_increment = 1;
        dut->EN_reset_count = 0;
    }
    
    void reset_counter() {
        dut->EN_increment = 0;
        dut->EN_reset_count = 1;
    }
    
    void idle() {
        dut->EN_increment = 0;
        dut->EN_reset_count = 0;
    }
    
    uint8_t get_count() {
        return dut->get_count;
    }
    
    void run() {
        reset();
        
        std::cout << "🏃 Running Counter simulation..." << std::endl;
        std::cout << "📋 Test sequence:" << std::endl;
        std::cout << "   1. Increment counter 15 times" << std::endl;
        std::cout << "   2. Reset counter" << std::endl;
        std::cout << "   3. Increment counter 5 more times" << std::endl;
        std::cout << std::endl;
        
        // Test sequence
        for (int i = 0; i < 15 && should_continue(); i++) {
            increment_counter();
            tick();
            std::cout << "Cycle " << sim_time << ": Incrementing - Counter = " 
                      << (int)get_count() << std::endl;
        }
        
        // Reset the counter
        if (should_continue()) {
            std::cout << "\n🔄 Resetting counter..." << std::endl;
            reset_counter();
            tick();
            std::cout << "Cycle " << sim_time << ": After reset - Counter = " 
                      << (int)get_count() << std::endl;
        }
        
        // Increment a few more times
        std::cout << "\n📈 Incrementing after reset..." << std::endl;
        for (int i = 0; i < 5 && should_continue(); i++) {
            increment_counter();
            tick();
            std::cout << "Cycle " << sim_time << ": Incrementing - Counter = " 
                      << (int)get_count() << std::endl;
        }
        
        // Test overflow (8-bit counter should wrap around)
        std::cout << "\n🔄 Testing overflow..." << std::endl;
        // Set counter to near maximum (255)
        for (int i = get_count(); i < 253 && should_continue(); i++) {
            increment_counter();
            tick();
        }
        
        // Show the last few increments and overflow
        for (int i = 0; i < 5 && should_continue(); i++) {
            increment_counter();
            tick();
            std::cout << "Cycle " << sim_time << ": Near/at overflow - Counter = " 
                      << (int)get_count() << std::endl;
        }
        
        // Final idle cycles
        std::cout << "\n⏸️ Idle cycles..." << std::endl;
        for (int i = 0; i < 3 && should_continue(); i++) {
            idle();
            tick();
            std::cout << "Cycle " << sim_time << ": Idle - Counter = " 
                      << (int)get_count() << std::endl;
        }
    }
    
    uint64_t get_sim_time() const { return sim_time; }
};

int main(int argc, char** argv) {
    std::cout << "🧪 BSV mkCounter Verilator Simulation" << std::endl;
    std::cout << "=====================================" << std::endl;
    
    try {
        // Parse command line arguments for max simulation time
        uint64_t max_time = 1000;
        if (argc > 1) {
            max_time = std::stoull(argv[1]);
            std::cout << "📋 Max simulation time set to: " << max_time << " cycles" << std::endl;
        }
        
        // Create and run simulation
        CounterSimulator sim(max_time);
        sim.run();
        
        std::cout << std::endl;
        std::cout << "📊 Final Statistics:" << std::endl;
        std::cout << "   Total cycles: " << sim.get_sim_time() << std::endl;
        std::cout << "   Waveform: waves/simulation.vcd" << std::endl;
        std::cout << "   Use 'make wave' to view waveform" << std::endl;
        
        return 0;
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error: " << e.what() << std::endl;
        return 1;
    }
}
