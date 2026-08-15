# Single Cycle Processor (MIPS)

Implementação completa de um processador MIPS de ciclo único em Verilog, sintetizável em FPGA Cyclone V com ambiente de simulação ModelSim.

## 🎯 Visão Geral

Um processador **MIPS de ciclo único** onde todas as operações (fetch, decode, execute, memory access, write-back) completam em **um único ciclo de clock**. Ideal para entender arquitetura de processadores e projeto digital.

### Características

- ✅ **Arquitetura MIPS de 32 bits**
- ✅ **Ciclo único** - Simplicidade (vs pipeline)
- ✅ **26 módulos Verilog** - Altamente modular
- ✅ **Testbenches completos** - Cada módulo testado
- ✅ **Síntese FPGA** - Quartus Prime para Cyclone V
- ✅ **Simulação** - ModelSim para validação RTL

## 📚 Arquitetura

### Hierarquia de Módulos

```
┌─────────────────────────────────────────────────┐
│      SCProcessor (Top Level)                    │
│  ┌───────────────────────────────────────────┐  │
│  │ Program Counter + Fetch Stage             │  │
│  │  - ProgramCounter: Contador PC            │  │
│  │  - PCPlus4: Calcula PC+4                  │  │
│  │  - InstructionMemory: Memória de código   │  │
│  └───────────────────────────────────────────┘  │
│                    ↓ (32-bit instruction)       │
│  ┌───────────────────────────────────────────┐  │
│  │ Decode Stage                              │  │
│  │  - MainDecoder: Sinais de controle        │  │
│  │  - ALUDecoder: Operação ALU               │  │
│  │  - RegisterFile: Banco de registradores   │  │
│  │  - Extend: Extensão de sign               │  │
│  └───────────────────────────────────────────┘  │
│                    ↓ (dados + controle)         │
│  ┌───────────────────────────────────────────┐  │
│  │ Execute Stage                             │  │
│  │  - ALU: Unidade aritmética/lógica         │  │
│  │  - PCTarget: Calcula endereço de branch   │  │
│  │  - Multiplexadores (MUX2x1, MUX3x1)      │  │
│  └───────────────────────────────────────────┘  │
│                    ↓ (resultado)                │
│  ┌───────────────────────────────────────────┐  │
│  │ Memory Stage                              │  │
│  │  - DataMemory: Memória de dados (RAM)     │  │
│  └───────────────────────────────────────────┘  │
│                    ↓ (dado lido/escrito)        │
│  ┌───────────────────────────────────────────┐  │
│  │ Write-Back Stage                          │  │
│  │  - Multiplexador: Resultado ou MEM dato   │  │
│  │  - RegisterFile: Escreve no registrador   │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## 🔧 Módulos Principais

### Memória

#### `InstructionMemory.v`
- **Função**: Armazena instruções MIPS de 32 bits
- **Interface**:
  - IN: `pc[31:0]` - Endereço da instrução
  - OUT: `instr[31:0]` - Instrução de 32 bits
- **Inicialização**: Arquivo `.hex` com programa

#### `DataMemory.v`
- **Função**: RAM para dados durante execução
- **Operações**: Leitura síncrona, escrita síncrona
- **Sinais de Controle**:
  - `MemWrite` - Habilita escrita
  - `MemRead` - Seleciona saída

### Lógica de Controle

#### `MainDecoder.v`
- **Função**: Decodifica o opcode da instrução
- **Entradas**: `op[5:0]` (6 bits de opcode)
- **Saídas**:
  - `MemtoReg` - Mux entre ALU resultado e memória
  - `MemWrite` - Habilita escrita em memória
  - `Branch` - Sinal de desvio condicional
  - `ALUSrc` - Mux entre Reg2 e Extend
  - `RegWrite` - Habilita escrita em registrador
  - `Jump` - Sinal de salto incondicional
  - `ALUOp[1:0]` - Tipo de operação ALU

#### `ALUDecoder.v`
- **Função**: Decodifica campos func e ALUOp
- **Mapeia**:
  - `funct[5:0]` + `ALUOp[1:0]` → `ALUControl[3:0]`
- **Operações**: ADD, SUB, AND, OR, SLT, NOR, etc.

#### `ControlUnit.v`
- **Combinação** de MainDecoder + ALUDecoder
- **Centraliza** todos os sinais de controle

### Banco de Registradores

#### `RegisterFile.v`
- **32 registradores de 32 bits** (R0-R31)
- **Operações**:
  - Leitura assíncrona de 2 registradores
  - Escrita síncrona em 1 registrador
- **R0** é sempre 0 (convenção MIPS)

### Unidade Aritmética e Lógica

#### `ALU.v`
- **Função**: Executa operações aritméticas/lógicas
- **Operações** (4-bit ALUControl):
  - `0000` - ADD (A + B)
  - `0001` - SUB (A - B)
  - `0010` - AND (A & B)
  - `0011` - OR (A | B)
  - `0100` - SLT (A < B ? 1 : 0)
  - `0101` - NOR (~(A | B))

### Lógica do Program Counter

#### `ProgramCounter.v`
- **Registrador** que armazena PC
- **Escreve** novo PC a cada ciclo
- **Reset** para endereço 0

#### `PCPlus4.v`
- **Calcula** PC + 4 (próxima instrução sequencial)
- **Combinacional**

#### `PCTarget.v`
- **Calcula** endereço de branch
- **Formula**: `PC + 4 + (SignExtend(immed) << 2)`
- **Combinacional**

### Extensão de Constantes

#### `Extend.v`
- **Extensão de sign** para imediatos de 16 bits
- **Entrada**: `immed[15:0]`
- **Saída**: `extended[31:0]`

### Multiplexadores

#### `MUX2x1.v`
- **Seletor de 2 entradas**
- **Genérico**: Param `WIDTH` configurável

#### `MUX3x1.v`
- **Seletor de 3 entradas**
- **Usado para**: NextPC (PC+4 / PC_target / JumpAddress)

## 📋 Instruções Suportadas

### Tipo R (Registro-Registro)
```
Format: [31:26]=opcode [25:21]=rs [20:16]=rt [15:11]=rd [10:6]=shamt [5:0]=funct
ADD, SUB, AND, OR, SLT, NOR
Exemplo: ADD $1, $2, $3   → R[1] = R[2] + R[3]
```

### Tipo I (Registro-Imediato)
```
Format: [31:26]=opcode [25:21]=rs [20:16]=rt [15:0]=immediate
ADDI, ANDI, ORI, SLTI, LW, SW, BEQ
Exemplo: ADDI $1, $2, 100 → R[1] = R[2] + 100
```

### Tipo J (Salto)
```
Format: [31:26]=opcode [25:0]=address
J, JAL
Exemplo: J 1000 → PC = {PC[31:28], 1000*4}
```

### Instruções de Desvio
- **BEQ** - Branch if Equal: `if (R[rs]==R[rt]) PC=PCTarget else PC=PC+4`
- **BEQZ** - Branch if Zero

### Instruções de Memória
- **LW** - Load Word: `R[rt] = Mem[R[rs] + immed]`
- **SW** - Store Word: `Mem[R[rs] + immed] = R[rt]`

## 🧪 Testbenches

Cada módulo tem seu testbench correspondente:

| Módulo | Testbench | Testa |
|--------|-----------|-------|
| ALU.v | ALUTB.v | Operações aritméticas |
| ALUDecoder.v | ALUDecoderTB.v | Mapeamento funct→ALUControl |
| ControlUnit.v | ControlUnitTB.v | Decodificação de instruções |
| RegisterFile.v | RegisterFileTB.v | Leitura/escrita de registros |
| InstructionMemory.v | InstructionMemoryTB.v | Carregamento de programa |
| DataMemory.v | DataMemoryTB.v | Acesso à memória de dados |
| ProgramCounter.v | ProgramCounterTB.v | Incremento do PC |
| PCPlus4.v | PCPlus4TB.v | Cálculo PC+4 |
| PCTarget.v | PCTargetTB.v | Endereço de branch |
| Extend.v | ExtendTB.v | Extensão de sign |
| MUX2x1.v | MUX2x1TB.v | Seleção 2-to-1 |
| MUX3x1.v | MUX3x1TB.v | Seleção 3-to-1 |
| **SCProcessor.v** | **ProcessorTB.v** | **Integração completa** |

## 🚀 Como Usar

### 1. Simular um Módulo Individual

```bash
cd SCProcessor

# Compilar testbench do ALU
vlog ALU.v ALUTB.v

# Simular
vsim -gui work.ALUTB
run 100 ns
```

### 2. Simular o Processador Completo

```bash
# Compilar todos os módulos
vlog *.v

# Simular processador
vsim -gui work.ProcessorTB
run 1000 ns
```

### 3. Sintetizar para FPGA

```bash
# Abrir projeto
quartus SCProcessor.qpf

# Ou via linha de comando
quartus_sh -t compile.tcl

# Gerar arquivo de programação
quartus_pgm -m jtag -o "p;output_files/SCProcessor.sof"
```

## 📊 Exemplo de Execução

### Programa: Soma Simples
```mips
ADDI $1, $0, 5    # R[1] = 0 + 5 = 5
ADDI $2, $0, 3    # R[2] = 0 + 3 = 3
ADD  $3, $1, $2   # R[3] = 5 + 3 = 8
SW   $3, 0($0)    # Mem[0] = 8
```

### Ciclo a Ciclo (Single Cycle)

**Ciclo 1 (ADDI $1, $0, 5)**
```
Fetch:  PC=0, Instr=0x20010005
Decode: op=8 (ADDI), rs=0, rt=1, imm=5
        RegWrite=1, ALUSrc=1
Execute: ALU: R[0] + SignExt(5) = 5
Mem:     -
WB:      R[1] = 5
NextPC:  PC = 4
```

**Ciclo 2 (ADDI $2, $0, 3)**
```
Fetch:  PC=4, Instr=0x20020003
Decode: op=8 (ADDI), rs=0, rt=2, imm=3
Execute: ALU: R[0] + SignExt(3) = 3
WB:      R[2] = 3
NextPC:  PC = 8
```

**Ciclo 3 (ADD $3, $1, $2)**
```
Fetch:  PC=8, Instr=0x00223820
Decode: op=0 (R-type), rs=1, rt=2, rd=3, funct=32
Execute: ALU: R[1] + R[2] = 5 + 3 = 8
WB:      R[3] = 8
NextPC:  PC = 12
```

## 🎨 Características de Design

### Vantagens do Single Cycle
- ✅ **Simples** - Fácil de entender e debugar
- ✅ **Sem hazards** - Não há dependências entre ciclos
- ✅ **Didático** - Excelente para aprendizado

### Desvantagens
- ❌ **Ciclo longo** - Limitado pelo caminho crítico
- ❌ **Ineficiente** - Muitos estágios ociosos
- ❌ **Performance baixa** - CPI = 1, mas clock baixo

### Otimizações Possíveis
```
1. Pipeline (3-5 estágios)
2. Hazard detection e forwarding
3. Branch prediction
4. Memória cache
```

## 📁 Estrutura de Arquivos

```
SingleCycleProcessor/
├── SCProcessor/                 # Projeto Quartus
│   ├── *.v                     # 26 módulos Verilog
│   ├── *TB.v                   # 12 testbenches
│   ├── SCProcessor.qpf         # Projeto Quartus
│   ├── SCProcessor.qsf         # Configurações
│   ├── c5_pin_model_dump.txt  # Pin mapping
│   └── db/, output_files/      # Artifacts de build
├── README.md                   # Este arquivo
├── GUIA_SIMULACAO.md          # Como simular
├── ARQUITETURA.md             # Detalhe arquitetônico
└── INSTRUCOES_SUPORTADAS.md   # Referência ISA
```

## 🔍 Análise de Timing

### Caminho Crítico (Cyclone V)
```
InstructionMemory.outDelay
+ MainDecoder.delay
+ RegisterFile.readDelay
+ ALU.delay
+ DataMemory.readDelay
+ MUX (write-back).delay
─────────────────────────────
Máximo Clock: ~50-70 MHz (estimado)
```

### Tabela de Timings
| Operação | Latência |
|----------|----------|
| Mem Read | 2 ns |
| ALU Add | 3 ns |
| RegisterFile Read | 2 ns |
| Total | ~8-10 ns → ~100-125 MHz teórico |

## 🛠️ Ferramentas Necessárias

- **Quartus Prime** (síntese)
- **ModelSim** (simulação)
- **Verilog** compiler (vlog)
- **FPGA Cyclone V** (opcional, para programação)

## 📚 Referências

### Livros
- "Computer Organization and Design" - Patterson & Hennessy
- "Digital Design" - Frank Vahid

### Padrões
- MIPS ISA (32-bit)
- IEEE Verilog 2017

### Recursos
- [MIPS Reference](https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats)
- [Quartus User Guide](https://www.intel.com/content/www/us/en/programmable/documentation/mwh1410387601/17.0/mwh1410388062/17.0/mqh1448907746/17.0/mqh1448907744/17.0/lfm1448907746/17.0/lfm1448907745/17.0/lfm1410385947/17.0/mcuh1446480058.html)

## 🚦 Status do Projeto

- ✅ Arquitetura base completa
- ✅ Todos os módulos implementados
- ✅ Testbenches unitários
- ✅ Integração ProcessorTB
- ✅ Síntese Quartus validada
- 🔄 Documentação em desenvolvimento
- ⏳ Teste em FPGA (futuro)

## 👤 Autor

Welington Peres Léo

---

**Nota**: Este é um projeto educacional para ensino de arquitetura de computadores. Para produção, considere usar processadores comerciais ou designs de código aberto como RISC-V.
