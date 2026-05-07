# DummyDualCoreProcessor
# Credit to Nate Williams (https://github.com/sizeru) for providing schematic to construct the traces
This is a project outlining a simple structure for a CPU that uses two cores to simulate multi-threading behavior.

This "dummy" processor will be fabricated to work on a DE-10 Nano FPGA with the system being provided no disk, and so will only operate on physical memory. We will be 
implementing the Harvard Architecture for partitioning memory into different  hierarchies such that the iTLB only communicates with memory containing the flashed program 
while the dTLB communicates with the much larger portion of memory for storing values and state. For now, work will be done on getting a trace to be swapped to another core 
every 25 cycles it spends on one core to avoid complications brought on by instruction-level parallelism (this will be expanded on as the progress is made on the project). 
For simplicity, each L1 cache will be directly mapped with only the L2 cache evoking an eviction policy. Physical registers will be installed to deal with data dependencies 
as well as reservation stations that handle RAW hazards. Control dependencies will be expanded on later alongside methods for speculative instructions. To deal with 
swapping between cores, this project will utilize a MESI policy with swapping cycles denoting ownership between cores. The traces will be designed as using non-branching 
instructions and will turn off multi-threading. To reiterate, the purpose of this project is to design communication between cores while implementing Tomasulo's algorithm 
as you would on a single-core processor in order to gain an understanding of how to flush values from a core if need be.

The following are the current milestones for the project (all of these units must be functional):

- Implement a testbench for simple adder connected to an ROB
- Create a cycle-accurate software simulator that verifies commit order
- Review material provided by Nate for further details on using Verilator in RTL simulation

Memory Hierarchy
- Create a dTLB that coordinates translations between physical memory and virtual addresses
- Create a system for software page tabling
- Create a directly-mapped write-back L1 caches for each core
- Create a L2 cache unifying the two core's L1 caches
- Create an iTLB to decode PC values into physical addresses

Tomasulo Implementation
- Implement a fetch unit that reads the next instruction to read from the iTLB
- Implement a decode unit that fills instruction buffer with decoded micro ops from passed macro ops according to ARM-derived logic with clean field boundaries (called chARM v6) given in the resource folders
- Implement instruction buffer for loading in a single program from memory
- Implement an adder, address generation unit, load-store queue and multiplier functional unit for a single core.
- Implement the reservation stations WITHOUT rollback
- Implement a reorder buffer (ROB) to ensure instructions are committed in the order they were issued (will add rollback for speculative instructions)
- Implement a physical register table for register renaming containing 48 physical registers
- Implement a RAT for renaming (will add an RRAT for speculative renaming) with 16 architectural registers
- Append a top core module connecting the components belonging to Tomasulo's algorithm

Inter-Processor Communication
- Add functionality for an interconnect among different cores to communicate cache lines that were dirtied between L1 caches to enact MESI policy (further details will be explored more after having set up simulation and simple single-core processor functionality)
- Add clock that will call a swap between cores after 25 cycles (add parameterization for testing)
- Add flushing to each core for when a flush is called on it

Extra
- Compile using Altera Quartus to see if the processor fits the specifications of the DE-10 Nano. This step may be impossible for the size of the project, but it will be helpful in learning how to fit a design onto an FPGA

Resources from Claude for Building Traces

'''
For a bare-metal FPGA processor with a fixed instruction set, your traces are essentially hand-assembled binary programs. Here's how to approach it:
Conceptual starting point

Computer Organization and Design: ARM Edition — Patterson & Hennessy. Chapters on pipelining and memory hierarchy give you the instruction stream model your simulator expects.
Computer Architecture: A Quantitative Approach — Hennessy & Patterson. Chapter 3 covers Tomasulo in depth with worked trace examples you can directly adapt.

Tomasulo trace walkthroughs

The original Tomasulo 1967 IBM paper ("An Efficient Algorithm for Exploiting Multiple Arithmetic Units") shows how instruction streams are tracked through reservation stations — useful for validating your RS logic against known-good behavior.
ETH Zürich and CMU both have publicly available Tomasulo simulation assignments with sample traces: search "Tomasulo algorithm trace example site:cmu.edu" or "site:ethz.ch" — these give you concrete RAW hazard sequences to test with.

Trace format for your use case
Since you're non-branching, your trace is a flat sequence of load/store/add/mul instructions with explicit register operands. A minimal format is:

LOAD R1, 0x100
LOAD R2, 0x104
ADD R3, R1, R2
MUL R4, R3, R1
STORE R4, 0x108

You'll want to write traces that specifically exercise: RAW chains (to stress reservation stations), WAW sequences (to verify physical register renaming), and long-latency multiply followed by dependent adds (to verify ROB in-order commit while RS dispatches out of order).
Simulation before RTL
Before writing any Verilog/VHDL, implement a cycle-accurate software simulator of your pipeline in Python or C++. Feed it traces and verify ROB commit order, RS dispatch, and register rename behavior. This will save significant debugging time in RTL. SimpleScalar and gem5 source code are worth reading for how they model reservation station state machines, even if you don't use them directly.
'''
