## Implementation of Boolean Function Using a 4×1 Multiplexer | Verilog

A Verilog implementation of a **Boolean function using a 4×1 multiplexer with enable**, developed and simulated in the Vivado IDE. This project shows how to:

- Realize a **four-variable Boolean function** using a **single 4×1 MUX**.
- Derive the function from **minterms and Karnaugh map (K‑map)**.
- Map the function into **MUX data inputs and select lines**.
- Verify correctness using a **self-checking testbench** and waveform simulation.

---

## Table of Contents

- [Project Overview](#project-overview)
- [What Is a 4×1 Multiplexer?](#what-is-a-4×1-multiplexer)
- [Target Boolean Function](#target-boolean-function)
- [K‑Map and Function Grouping](#k-map-and-function-grouping)
- [Implementing the Function with a 4×1 MUX](#implementing-the-function-with-a-4×1-mux)
- [Boolean Equation Realized by the MUX](#boolean-equation-realized-by-the-mux)
- [Circuit and Waveform](#circuit-and-waveform)
- [Testbench and Output](#testbench-and-output)
- [Running the Project in Vivado](#running-the-project-in-vivado)
- [Project Files](#project-files)
- [Learning Resources](#learning-resources)
- [Author](#author)

---

## Project Overview

This project demonstrates how a **4×1 multiplexer** can be used to implement a given **four‑variable Boolean function**:

- **Variables:** A, B, C, D  
- **Function:**  
  \[
  F(A,B,C,D) = \sum m(1,4,5,7,9,12,13)
  \]

Rather than implementing the function directly with AND/OR/NOT gates, we:

- Use **A** and **B** as select inputs of a **4×1 MUX**.
- Encode the dependence on **C** and **D** into the **MUX data inputs**.
- Map the function into a compact, easily scalable structure using the module `fourToOneMultiplexer`.

This is a classic example of using **multiplexers as universal building blocks** for logic realization.

---

## What Is a 4×1 Multiplexer?

A **multiplexer (MUX)** is a combinational circuit that selects **one of several input signals** and forwards it to a **single output**, based on the value of **selector inputs**.

For a 4×1 MUX:

- **Data inputs:** I₀, I₁, I₂, I₃  
- **Select lines:** S₁, S₀ (2 bits)  
- **Optional enable:** E  
- **Output:** Y

Selection behavior when **E = 1**:

| S₁ | S₀ | Selected Output |
|----|----|-----------------|
| 0  | 0  | Y = I₀          |
| 0  | 1  | Y = I₁          |
| 1  | 0  | Y = I₂          |
| 1  | 1  | Y = I₃          |

Including enable:

- **E = 0 → Y = 0** (MUX disabled)  
- **E = 1 → Y = I\_k** for the selected input.

In this project:

- `S1 = A`  
- `S0 = B`  
- The enable `E` is tied to logic 1 (`1'b1`), so the MUX is always enabled.

---

## Target Boolean Function

We want to implement the Boolean function:

- **Function definition:**  
  \[
  F(A,B,C,D) = \sum m(1,4,5,7,9,12,13)
  \]

Using standard minterm numbering (A as MSB, D as LSB), the minterms correspond to the following input combinations:

| A | B | C | D | m | F(A,B,C,D) |
|---|---|---|---|---|------------|
| 0 | 0 | 0 | 1 | 1 | 1          |
| 0 | 1 | 0 | 0 | 4 | 1          |
| 0 | 1 | 0 | 1 | 5 | 1          |
| 0 | 1 | 1 | 1 | 7 | 1          |
| 1 | 0 | 0 | 1 | 9 | 1          |
| 1 | 1 | 0 | 0 | 12| 1          |
| 1 | 1 | 0 | 1 | 13| 1          |

All other input combinations give **F = 0**.

For reference, the **full truth table** observed by the testbench is:

```text
A B C D | F
--------|--
0 0 0 0 | 0
0 0 0 1 | 1
0 0 1 0 | 0
0 0 1 1 | 0
0 1 0 0 | 1
0 1 0 1 | 1
0 1 1 0 | 0
0 1 1 1 | 1
1 0 0 0 | 0
1 0 0 1 | 1
1 0 1 0 | 0
1 0 1 1 | 0
1 1 0 0 | 1
1 1 0 1 | 1
1 1 1 0 | 0
1 1 1 1 | 0
```

This is exactly what the Verilog testbench prints to the simulation console.

---

## K‑Map and Function Grouping

To implement the function using a MUX, we first visualize it using a **four‑variable K‑map** with variables grouped as **AB** (rows) and **CD** (columns):

```text
        CD
       00  01  11  10
AB
00      0   1   0   0
01      1   1   1   0
11      1   1   0   0
10      0   1   0   0
```

Next, we choose which variables will be the **select lines** of the 4×1 multiplexer.

- **Select lines:** A, B  
  - S₁ = A  
  - S₀ = B  
- Remaining variables C, D are used to define the **input expressions** I₀–I₃.

Each **row** of the K‑map (fixed A,B) gives the behavior of the function as a function of C and D only, which becomes the corresponding **data input** to the MUX.

---

## Implementing the Function with a 4×1 MUX

With `S1 = A` and `S0 = B`, the four MUX inputs correspond to the four rows of the K‑map:

| A (S₁) | B (S₀) | Selected input | Row function of C,D | MUX input |
|--------|--------|----------------|---------------------|-----------|
| 0      | 0      | I₀             | F(0,0,C,D)          | I₀        |
| 0      | 1      | I₁             | F(0,1,C,D)          | I₁        |
| 1      | 0      | I₂             | F(1,0,C,D)          | I₂        |
| 1      | 1      | I₃             | F(1,1,C,D)          | I₃        |

From the K‑map rows, we derive the C,D‑only expressions:

| A | B | F as function of C,D | Simplified expression |
|---|---|----------------------|-----------------------|
| 0 | 0 | 0 1 0 0              | **C̄D**               |
| 0 | 1 | 1 1 1 0              | **C̄ + D**            |
| 1 | 0 | 0 1 0 0              | **C̄D**               |
| 1 | 1 | 1 1 0 0              | **C̄**                |

So we map:

- **I₀ = C̄D**  
- **I₁ = C̄ + D**  
- **I₂ = C̄D**  
- **I₃ = C̄**

This is exactly what the Verilog module `boolMultiplexer` implements:

- `S0 = B`  
- `S1 = A`  
- `I0 = ~C & D`  
- `I1 = ~C | D`  
- `I2 = ~C & D`  
- `I3 = ~C`

Then a single instance of `fourToOneMultiplexer` realizes the full function.

---

## Boolean Equation Realized by the MUX

The generic equation for a 4×1 MUX with enable **E** is:

\[
Y = E(\overline{S_1}\,\overline{S_0}I_0 + \overline{S_1}S_0I_1 + S_1\overline{S_0}I_2 + S_1S_0I_3)
\]

Substituting:

- \( S_1 = A \), \( S_0 = B \)  
- \( I_0 = \overline{C}D \)  
- \( I_1 = \overline{C} + D \)  
- \( I_2 = \overline{C}D \)  
- \( I_3 = \overline{C} \)  
- \( E = 1 \)

we obtain:

\[
F(A,B,C,D) =
\overline{A}\,\overline{B}\,\overline{C}D
+
\overline{A}B(\overline{C} + D)
+
A\overline{B}\,\overline{C}D
+
AB\,\overline{C}
\]

which simplifies exactly to:

\[
F(A,B,C,D) = \sum m(1,4,5,7,9,12,13)
\]

matching the original specification.

---

## Circuit and Waveform

### Conceptual Circuit

The top‑level circuit can be viewed as:

- **Input decoding stage:**  
  - Generates the four C,D‑dependent signals:  
    - \(I_0 = \overline{C}D\)  
    - \(I_1 = \overline{C} + D\)  
    - \(I_2 = \overline{C}D\)  
    - \(I_3 = \overline{C}\)
- **4×1 MUX core:**  
  - Uses `A` and `B` as select inputs.  
  - Routes one of I₀–I₃ to the output `Y`.  
  - Enable `E` is tied high.

If you have schematic images or waveform screenshots, you can place them in an `imageAssets/` folder and embed them here, for example:

```markdown
![4×1 MUX‑based Boolean Function Circuit](imageAssets/bool-mux-circuit.png)
![4×1 MUX Waveform](imageAssets/bool-mux-waveform.png)
```

### Waveform Behavior

The simulation waveform should show:

- A, B, C, D cycling through all **16 possible combinations**.  
- Output **Y** (or F) going high **only** for the specified minterms:
  - 0001, 0100, 0101, 0111, 1001, 1100, 1101.

This matches the truth table and confirms that the implemented circuit realizes the desired Boolean function.

---

## Testbench and Output

The testbench module `boolMultiplexer_tb`:

- Declares **A, B, C, D** as `reg` and **Y** as `wire`.  
- Instantiates the DUT:
  - `boolMultiplexer uut(A,B,C,D,Y);`
- Uses an `integer i` loop from 0 to 15:
  - Assigns `{A,B,C,D} = i;`  
  - Waits for a simulation time step.  
  - Prints the input and output values to the console.

A representative log from the simulator is:

```text
A B C D | Y
--------|--
0 0 0 0 | 0
0 0 0 1 | 1
0 0 1 0 | 0
0 0 1 1 | 0
0 1 0 0 | 1
0 1 0 1 | 1
0 1 1 0 | 0
0 1 1 1 | 1
1 0 0 0 | 0
1 0 0 1 | 1
1 0 1 0 | 0
1 0 1 1 | 0
1 1 0 0 | 1
1 1 0 1 | 1
1 1 1 0 | 0
1 1 1 1 | 0
```

This confirms that the Verilog implementation and the theoretical function are in complete agreement.

---

## Running the Project in Vivado

### Prerequisites

- **Xilinx Vivado** installed (any recent version with RTL simulation support).

### 1. Launch Vivado

1. Open Vivado from the Start Menu (Windows).  
2. Select the main **Vivado** IDE.

### 2. Create a New RTL Project

1. Click **Create Project** (or **File → Project → New**).  
2. Click **Next** on the welcome page.  
3. Choose **RTL Project**.  
4. Uncheck **Do not specify sources at this time** if you plan to add Verilog files immediately.  
5. Click **Next** to proceed.

### 3. Add Design and Simulation Sources

1. In the **Add Sources** step, add:
   - **Design sources:**
     - `fourToOneMultiplexer.v` — generic 4×1 MUX with enable:
       - Inputs: `S1`, `S0`, `I0`, `I1`, `I2`, `I3`, `E`
       - Output: `Y`
     - `boolMultiplexer.v` — Boolean function realization using the 4×1 MUX:
       - Inputs: `A`, `B`, `C`, `D`
       - Output: `Y`
   - **Simulation sources:**
     - `boolMultiplexer_tb.v` — testbench that iterates through all input combinations.
2. After adding sources, in the **Sources** window:
   - Under **Simulation Sources**, right‑click `boolMultiplexer_tb.v` and choose **Set as Top**.
3. Select a suitable **target device** (for simulation, any supported device is fine), then click **Next** and **Finish**.

### 4. Run Behavioral Simulation

1. In the **Flow Navigator** under **Simulation**, click **Run Behavioral Simulation**.  
2. Vivado will:
   - Elaborate `boolMultiplexer` as the DUT.  
   - Compile sources and open the waveform window.
3. In the waveform viewer, add the signals **A, B, C, D, Y** and verify that:
   - The **console log** matches the truth table above.  
   - The **waveform** shows Y = 1 exactly at the specified minterms.

### 5. (Optional) Synthesis, Implementation, and Bitstream

If you want to map the design to FPGA hardware:

1. In **Sources**, set `boolMultiplexer` as **Top** for synthesis.  
2. Run **Synthesis** and then **Implementation**.  
3. Create a constraints file (e.g., `.xdc`) to assign FPGA pins for:
   - Inputs: `A`, `B`, `C`, `D`  
   - Output: `Y`
4. Run **Generate Bitstream** to produce the FPGA configuration file.

---

## Project Files

- **`fourToOneMultiplexer.v`**  
  - Generic **4×1 multiplexer with enable**:  
    \[
    Y = E(\overline{S_1}\,\overline{S_0}I_0 + \overline{S_1}S_0I_1 + S_1\overline{S_0}I_2 + S_1S_0I_3)
    \]

- **`boolMultiplexer.v`**  
  - Uses `fourToOneMultiplexer` to implement:  
    \[
    F(A,B,C,D) = \sum m(1,4,5,7,9,12,13)
    \]
  - Signal mapping:
    - `S1 = A`, `S0 = B`  
    - `I0 = ~C & D`, `I1 = ~C | D`, `I2 = ~C & D`, `I3 = ~C`  
    - `E = 1'b1`

- **`boolMultiplexer_tb.v`**  
  - Testbench that:
    - Drives all 16 combinations of A,B,C,D.  
    - Prints the formatted truth table to the console.  
    - Confirms functional correctness of the implementation.

---

## Learning Resources

| Resource | Description |
|----------|-------------|
| [Multiplexer Basics (YouTube)](https://www.youtube.com/results?search_query=multiplexer+basics) | Introductory explanation of multiplexers, select lines, truth tables, and basic applications. |
| [Implementing Boolean Functions Using MUXes (YouTube)](https://www.youtube.com/results?search_query=implement+boolean+function+using+multiplexer) | Step‑by‑step examples of realizing Boolean functions with 4×1 and 8×1 multiplexers. |
| [4×1 Multiplexer in Verilog (YouTube)](https://www.youtube.com/results?search_query=4+to+1+multiplexer+verilog) | Verilog design and simulation of a 4×1 MUX. |
| [Vivado RTL Simulation Tutorials (YouTube)](https://www.youtube.com/results?search_query=vivado+rtl+simulation+tutorial) | Guides on creating projects, adding sources, and running behavioral simulations in Vivado. |

---

## Author

**Kadhir Ponnambalam**

Implementation of Boolean function using a **4×1 multiplexer** in Verilog, with full K‑map derivation and simulation.
