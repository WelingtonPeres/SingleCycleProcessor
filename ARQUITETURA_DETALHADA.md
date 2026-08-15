# Arquitetura Detalhada - Single Cycle Processor

Análise profunda da microarquitetura do processador MIPS de ciclo único.

## 📐 Caminho de Dados (Datapath)

```
┌──────────┐
│Instruction│
│ Memory   │────────────────┐
└──────────┘                │
                            ↓
                    ┌───────────────┐
                    │  Instruction  │
                    │   [31:0]      │
                    └───────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
         ↓                  ↓                  ↓
    ┌────────┐        ┌────────┐        ┌────────┐
    │  Rs    │        │  Rt    │        │  Imm   │
    │[25:21] │        │[20:16] │        │[15:0]  │
    └────────┘        └────────┘        └────────┘
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
                    ┌───────────────┐
                    │ RegisterFile  │
                    │  Read Port 1  │────→ A
                    │  Read Port 2  │────→ B
                    └───────────────┘
                            │
         ┌──────────────────┼──────────────┐
         │                  │              │
         ↓                  ↓              ↓
    ┌────────┐       ┌────────┐     ┌──────────┐
    │ ALU    │       │  MUX   │     │ Extend   │
    │ A+B,   │       │ B or   │     │ Sign-ext │
    │ A-B,   │       │ Imm    │     │ Imm16→32 │
    │ A&B,   │       └────────┘     └──────────┘
    │ A|B,   │            │              │
    │ A<B    │            └──────────────┘
    └────────┘                    │
         │                        │
         ├────────────┬───────────┘
         │            │
         ↓            ↓
    ┌────────┐   ┌────────┐
    │ ALU    │   │ MUX    │────→ WriteData (para mem/regfile)
    │Result │   │ ALU or │
    │       │   │ MemData│
    └────────┘   └────────┘
         │            │
         └────────────┴───→ RegisterFile Write Port
                            (Back to Rt)
```

## 🎛️ Sinais de Controle

### MainDecoder (7 saídas)

```verilog
input  [5:0] op        // Opcode de 6 bits
output       MemtoReg  // 0: ALU result, 1: Memory data
output       MemWrite  // Habilita escrita em memória
output       Branch    // Sinal de branch (BEQ)
output       ALUSrc    // 0: Reg2, 1: Immediate
output       RegWrite  // Habilita escrita em registrador
output       Jump      // Sinal de salto (J, JAL)
output [1:0] ALUOp     // Tipo de operação ALU
```

### Codificação de Instruções

| Tipo | Opcode | RegWrite | MemtoReg | MemWrite | Branch | ALUSrc | Jump | ALUOp |
|------|--------|----------|----------|----------|--------|--------|------|-------|
| R-type | 000000 | 1 | 0 | 0 | 0 | 0 | 0 | 10 |
| ADDI | 001000 | 1 | 0 | 0 | 0 | 1 | 0 | 00 |
| ANDI | 001100 | 1 | 0 | 0 | 0 | 1 | 0 | 01 |
| ORI | 001101 | 1 | 0 | 0 | 0 | 1 | 0 | 01 |
| SLTI | 001010 | 1 | 0 | 0 | 0 | 1 | 0 | 00 |
| LW | 100011 | 1 | 1 | 0 | 0 | 1 | 0 | 00 |
| SW | 101011 | 0 | X | 1 | 0 | 1 | 0 | 00 |
| BEQ | 000100 | 0 | X | 0 | 1 | 0 | 0 | 01 |
| J | 000010 | 0 | X | 0 | 0 | X | 1 | XX |

### ALUDecoder

```
Entrada: funct[5:0] + ALUOp[1:0]
Saída: ALUControl[3:0]

ALUOp = 00 (ADD/ADDI):  ALUControl = 0010 (ADD)
ALUOp = 01 (Subtract):  ALUControl = 0110 (SUB)
ALUOp = 10 (R-type):
  funct=32 (100000):  ALUControl = 0010 (ADD)
  funct=34 (100010):  ALUControl = 0110 (SUB)
  funct=36 (100100):  ALUControl = 0000 (AND)
  funct=37 (100101):  ALUControl = 0001 (OR)
  funct=42 (101010):  ALUControl = 0111 (SLT)
  funct=39 (100111):  ALUControl = 1100 (NOR)
```

## 💾 Memória

### Instruction Memory
```
Tamanho: 1024 instruções (4 KB)
Profundidade: 1024 × 32 bits
Inicialização: via $readmemh("program.hex")

Endereçamento:
PC[31:2] → Índice de instrução
PC[1:0]  → Sempre 00 (word-aligned)
```

### Data Memory
```
Tamanho: 256 palavras (1 KB)
Profundidade: 256 × 32 bits

Operações:
- Leitura: Assíncrona
- Escrita: Síncrona (na borda de clock)

Endereçamento:
ALUResult[9:2] → Índice
ALUResult[1:0]  → Sempre 00 (word-aligned)
```

### Register File
```
Registradores: 32 × 32 bits
Porta 1 de Leitura: Rs → ReadData1
Porta 2 de Leitura: Rt → ReadData2
Porta de Escrita: Rd ← WriteData

Convenção MIPS:
R[0]  = $zero (sempre 0)
R[1]  = $at
R[2-3] = $v0, $v1 (valores de retorno)
R[4-7] = $a0-$a3 (argumentos)
R[8-15] = $t0-$t7 (temporários)
R[16-23] = $s0-$s7 (salvos)
R[24-25] = $t8, $t9 (temporários)
R[26-27] = $k0, $k1 (kernel)
R[28] = $gp (global pointer)
R[29] = $sp (stack pointer)
R[30] = $fp (frame pointer)
R[31] = $ra (return address)
```

## 🔄 Fluxo de Execução - Ciclo Único

### T=0: Fetch
```verilog
// Simultaneamente:
pc_current = PC (from register)
instr = InstructionMemory[pc_current]
pc_plus4 = pc_current + 4
```

### T=0-T: Decode
```verilog
// Combinacional, sem delay
op = instr[31:26]
rs = instr[25:21]
rt = instr[20:16]
rd = instr[15:11]
imm = instr[15:0]
funct = instr[5:0]

// Decodificação de controle
ctrl_signals = MainDecoder(op)
alu_ctrl = ALUDecoder(funct, ctrl_signals.ALUOp)

// Leitura do banco
regdata1 = RegisterFile[rs]
regdata2 = RegisterFile[rt]
```

### T=0-T: Execute
```verilog
// ALU (combinacional)
alu_in2 = ALUSrc ? SignExtend(imm) : regdata2
alu_out = ALU(regdata1, alu_in2, alu_ctrl)

// PC calculation
pc_branch = pc_plus4 + (SignExtend(imm) << 2)
branch_taken = (regdata1 == regdata2) && Branch
pc_jump = {pc_plus4[31:28], instr[25:0]<<2}

if (Jump)
    pc_next = pc_jump
else if (branch_taken)
    pc_next = pc_branch
else
    pc_next = pc_plus4
```

### T=0-T: Memory Access
```verilog
// Leitura (combinacional)
if (MemRead)
    mem_out = DataMemory[alu_out[9:2]]
else
    mem_out = 0

// Escrita (será escrita na próxima borda de clock)
if (MemWrite)
    DataMemory[alu_out[9:2]] <= regdata2
```

### T=0-T: Write-Back (combinacional até o clock)
```verilog
write_data = MemtoReg ? mem_out : alu_out

if (RegWrite && rd != 0)
    RegisterFile[rt_or_rd] <= write_data  // Clock
```

### T=Ciclo: Atualização de Estado
```verilog
@(posedge clk)
begin
    PC <= pc_next
    RegisterFile[write_addr] <= write_data
    DataMemory[mem_addr] <= write_data
end
```

## ⏱️ Análise de Timing

### Caminho Crítico Completo

```
InstructionMemory:
  Address setup → Data available: ~1-2 ns

→ MainDecoder:
  Opcode decode: ~0.5 ns

→ RegisterFile (leitura):
  Address setup → Data available: ~0.5 ns

→ ALU:
  Setup & Execute: ~2-3 ns (depends on operation)

→ DataMemory (leitura):
  Address setup → Data available: ~1-2 ns

→ Final Multiplexer:
  Select & propagate: ~0.2 ns

─────────────────────────────────────────
Total Critical Path: ~6-9 ns

Máximo Clock = 1 / (9×2) ns ≈ 55 MHz
```

## 🔀 Fluxos de Dados por Tipo de Instrução

### R-type (ADD $3, $1, $2)

```
PC → InstrMem → [0x00223820]
     ↓
Decode: op=0, rs=1, rt=2, rd=3, funct=32
     ↓
RegFile: R[1]=A, R[2]=B
     ↓
ALU: A + B = C
     ↓
RegFile Write: R[3] = C
```

### I-type Load (LW $2, 100($1))

```
PC → InstrMem → [0x8C220064]
     ↓
Decode: op=35, rs=1, rt=2, imm=100
     ↓
RegFile: R[1]=BASE
     ↓
ALU: BASE + 100 = ADDR
     ↓
DataMem: R[ADDR] = DATA
     ↓
RegFile Write: R[2] = DATA
```

### I-type Store (SW $2, 100($1))

```
PC → InstrMem → [0xAC220064]
     ↓
Decode: op=43, rs=1, rt=2, imm=100
     ↓
RegFile: R[1]=BASE, R[2]=DATA
     ↓
ALU: BASE + 100 = ADDR
     ↓
DataMem Write: Mem[ADDR] = DATA
```

### Branch (BEQ $1, $2, 10)

```
PC → InstrMem → [0x1022000A]
     ↓
Decode: op=4, rs=1, rt=2, imm=10
     ↓
RegFile: R[1], R[2]
     ↓
ALU: Compare (R[1] == R[2]?)
PCTarget: PC+4 + 10<<2 = PC+44
     ↓
PC_next = (Equal) ? PC+44 : PC+4
```

### Jump (J 1000)

```
PC → InstrMem → [0x080003E8]  (1000 em hex = 0x3E8)
     ↓
Decode: op=2, address=1000
     ↓
PCTarget: {PC[31:28], 1000<<2}
     ↓
PC_next = {PC[31:28], 0xFA0}
```

## 🎨 Técnicas de Otimização

### Sem Modificação (Simpleza)
- ✅ Single-cycle → Sem pipelin → Sem hazards
- ✅ Fácil debug
- ✅ Ótimo para educação

### Com Pipeline (Futuro)
- Dividir em 5 estágios
- Adicionar registradores entre estágios
- Hazard detection e forwarding

### Com Cache (Futuro)
- L1 I-cache para InstructionMemory
- L1 D-cache para DataMemory
- Reduzir latência de memória

### Com Predição de Branches (Futuro)
- Branch predictor
- Reduce stalls em branches

## 📊 Métricas de Performance

### Clock Cycles (CPI)
- Single Cycle: CPI = 1.0 (sempre 1 ciclo)
- Com Pipeline: CPI = 1.0 + stalls
- Com Cache: CPI = 1.0 + miss penalties

### Throughput
```
MIPS = Clock_Frequency / CPI / 1,000,000

Exemplo:
MIPS = 50 MHz / 1.0 = 50 MIPS
```

### Power Consumption
```
P = C × V² × f

Onde:
C = capacitância dinâmica
V = tensão de alimentação
f = frequência de clock
```

---

**Referência**: Computer Organization and Design, 5ª edição - Patterson & Hennessy
